import strutils, base64, htmlgen, dom, times, algorithm, math, tables
import code128  # for barcode


# result field, was missing from dom module
proc `result`*(f: FileReader): cstring {.importcpp: "#.result", nodecl.}


const
  # Consts for interaction with HTML element

  inputId = "fileInput"  ## id of file <input> element

  gapdhMeanId = "gapdhMean"  ## id of GAPDH mean element
  rhdMeanId = "rhdMean"  ## id of RHD mean element

  gapdhMinDiffId = "gapdhMinDiff"  ## id of GAPDH min element
  gapdhMaxDiffId = "gapdhMaxDiff"  ## id of GAPDH max element

  gapdhIntervalId = "gapdhInterval"  ## id of GAPDH interval output

  gaphdControlId = "gapdhControl"  ## if of GAPDH negative control element
  rhdControlId = "rhdControl"  ## if of RHD negative control element

  barcodeId = "checkBarcode"  ## id of barcode checkbox

  sampleOutputId = "sampleOutput"  ## id of div element for samples output(/input)

  fileOutputId = "fileOutput"  ## id of div element for file output


  # const strings, for comparison and output

  sNTC = "NTC"
  sPC = "PC"
  sRHD = "RHD"
  sGAPDH = "GAPDH"

  # prefix for options
  optionPrefix = "option"


type
  RawWell = object  ## raw data for a well
    gene: string
    ct: float

  Well = object  ## results for an individual well
    rhd: float
    gapdh: float

  Sample = object  ## a sample with values
    sampleId: string  ## the sample identifier
    wells: seq[Well]  ## this sample's wells

  Result = enum  ## possible results for a sample
    Pos = "",  ## positive result
    Neg = "",  ## negative result
    IncOnePositive = "endast en positiv reaktion",  ## inconclusive with one positive reaction (or unclear reaction)
    IncDnaLow = "låg DNA konc",  ## inconclusive with low DNA conc
    IncDnaHigh = "hög DNA konc",  ## inconclusive with high DNA conc
    IncRhdHigh = "DNA konc RHD > GAPDH"  ## inconclusive with RHD > GAPDH
    IncRhdWeak = "RHD-värde >45.0"  ## inconclusive with weak RHD amplification

  WellResult = enum  ## possible results for a well, based on RHD alone
    wellPos = "+"
    wellNeg = "–"  # en dash

  Interpretation = object  ## object for sample interpretation output
    interp: Result
    wellResults: array[3, WellResult]  # exactly three results


var
  # global seq of Samples. Why global? Sample data will never change after
  # initial parsing, but the interpretation is subject to change if the user
  # decices to change parameters. Since we need to access the sample data on
  # parameter change, we keep the data accessible as a global and not as a
  # proc parameter.
  globalSamples: seq[Sample]

  # global vars for GAPDH limits. By saving them here, we don't need to recalc
  # when samples are (re-)interpreted, which otherwise would involve parsing a
  # form value from HTML
  gapdhMean: float
  gapdhMin: float
  gapdhMax: float

  # name of the currently loaded file
  filename: string


proc outputAndRaise(error: string) =
  ## Helpet to output an error message and raise
  const prefix = b("Fel vid inläsning av filen: ")
  getElementById(sampleOutputId).innerHTML = cstring(prefix & error)
  raise newException(ValueError, error)


proc parseExportFile(contents: string): seq[Sample] =
  ## Parse the export file
  # File contains at least 4 comma/semicolon-separated fields per row, some
  # fields are quoted

  # a temp table with sampleId as key, value is another Table with
  # position as key and "raw" wells as values.
  # Tricky, maybe ugly but should work
  var sampleWells: Table[string, Table[string, seq[RawWell]]]

  for i, line in pairs(splitLines(contents)):
    if line.len == 0:
      continue

    # echo metadata
    if line[0] == '#':
      echo line
      continue

    let
      # file is sometimes unquoted, with semicolon separators - normalize to comma
      normalized = line.replace(';', ',')
      fields = normalized.split(',')

    # rough check for errors
    if fields.len < 4:
      outputAndRaise("fel antal fält (n="  & $fields.len & ") på rad " & $i & ": " & line)

    # skip header row, field is sometimes quoted so cannot compare directly
    if "Well Position" in fields[0]:
      continue

    # data rows, strip quoting chars
    const quoteChars = {'\"'}
    let
      position = fields[0]
      sampleId = fields[1].strip(chars=quoteChars)
      gene = fields[2].strip(chars=quoteChars)
      ctRaw = fields[3].strip(chars=quoteChars)

    # parse ct value
    var ct: float
    if ctRaw == "Undetermined":
      ct = NaN
    else:
      try:
        ct = ctRaw.parseFloat
      except ValueError:
        outputAndRaise(
          "inget giltigt Ct-värde ('" & ctRaw & "') på rad " & $i & ": " & line
        )

    if gene notin [sRHD, sGAPDH]:
      outputAndRaise("okänd gen \"" & gene & "\" på rad " & $i & ": " & line)

    # save well to sample
    if sampleId notin sampleWells:
      sampleWells[sampleId] = initTable[string, seq[RawWell]]()

    if position notin sampleWells[sampleId]:
      sampleWells[sampleId][position] = @[]

    sampleWells[sampleId][position].add RawWell(gene: gene, ct: ct)


  # we have now saved wells by sample id and position,
  # move through the wells and merge them
  for sampleId, positions in sampleWells.pairs:
    # init a Sample
    var sample = Sample(sampleId: sampleId, wells: @[])

    # loop through the values in positions; these are RawWells in a seq
    for position, wells in positions.pairs:
      var well = Well()
      # we expected RHD and GAPDH for all positions, length 2
      if wells[0].gene == sRHD:

        if wells.len == 1 or wells[1].gene != sGAPDH:
          outputAndRaise("inget värde för GAPDH i position " & position)

        # value for RHD
        well.rhd = wells[0].ct
        # value for GAPDH, at next index
        well.gapdh = wells[1].ct

      elif wells[0].gene == sGAPDH:

        if wells.len == 1 or wells[1].gene != sRHD:
          outputAndRaise("inget värde för RHD i position " & position)

        # value for GAPDH
        well.gapdh = wells[0].ct
        # value for RHD, at next index
        well.rhd = wells[1].ct

      # add Well to sample
      sample.wells.add well

    # add sample to result
    result.add sample


func cmpSample(s1, s2: Sample): int =
  ## Comparison for sorting samples by sample. The sorting omits the first char.
  # TODO: check need to adapt to future sample id formats?
  let
    s1start = max(s1.sampleId.len - 11, 0)
    s2start = max(s2.sampleId.len - 11, 0)
  cmp(
    s1.sampleId[s1start ..< s1.sampleId.len],
    s2.sampleId[s2start ..< s2.sampleId.len]
  )


proc checkControlsPresent(samples: seq[Sample]) =
  ## Assert that controls are always present

  var
    ntc = false
    pc = false

  for sample in samples:
    if sample.sampleId == sNTC:
      ntc = true
    elif sample.sampleId == sPC:
      pc = true

  const
    ntcExpected = "en negativ kontroll \"" & sNTC & "\" fanns inte i filen"
    pcExpected = "en positiv kontroll \"" & sPC & "\" fanns inte i filen"

  if not ntc:
    outputAndRaise(ntcExpected)
  elif not pc:
    outputAndRaise(pcExpected)


proc checkAndOutputNegativeControl(samples: seq[Sample]) =
  ## Verify that the negative control is... negative. Output to document

  for sample in samples:
    if sample.sampleId == sNTC:
      for well in sample.wells:
        if not well.rhd.isNaN:
          outputAndRaise("negativ RHD-kontroll är positiv: " & $well.rhd)
        if not well.gapdh.isNaN:
          outputAndRaise("negativ GAPDH-kontroll är positiv " & $well.gapdh)
      break

  const negativeResult = cstring("negativ")
  getElementById(gaphdControlId).innerHTML = negativeResult
  getElementById(rhdControlId).innerHTML = negativeResult


proc checkTriplicates(samples: seq[Sample]) =
  ## Assert that all samples are triplicates
  for sample in samples:

    # skip controls
    if sample.sampleId == sNTC or sample.sampleId == sPC:
      echo sample.sampleId, ", n = ", sample.wells.len

    const minLen = 3
    if sample.wells.len != minLen:
      outputAndRaise(
        "prov " & sample.sampleId & " hade bara " & $sample.wells.len &
        " värden men minsta antal är " & $minLen
      )


proc checkDataCompleteness(samples: seq[Sample]) =
  ## Quality control of the parsed data

  # check for controls
  checkControlsPresent(samples)

  # check NTC
  checkAndOutputNegativeControl(samples)

  # check that all samples are complete
  checkTriplicates(samples)


template getGapdhMinDiff(): float =
  ## Returns the min GAPDH difference from mean, typically -1.5
  # cast to access .value, returns a cstring that must be parsed
  parseFloat $InputElement(getElementById(gapdhMinDiffId)).value


template getGapdhMaxDiff(): float =
  ## Returns the max GAPDH difference from mean, typically 6.4
  # cast to access .value, .value returns a cstring that must be parsed
  parseFloat $InputElement(getElementById(gapdhMaxDiffId)).value


proc setGapdhInterval() =
  ## Calculate and set the GAPDH interval limits
  let
    gapdhMinDiff = getGapdhMinDiff()
    gapdhMaxDiff = getGapdhMaxDiff()

  # save to global variables
  gapdhMin = gapdhMean + gapdhMinDiff  # YES + since diff value is negative
  gapdhMax = gapdhMean + gapdhMaxDiff


proc interpretSample(sample: Sample): Interpretation =
  ## Interpret sample reactions according to SOP.
  var
    minRhdCt = NaN
    maxGapdhCt = NaN  # some extremes
    nweak, npos = 0  # number of weak or positive wells

  for i, well in pairs(sample.wells):
    if well.rhd <= 45.0:
      # positive reaction
      inc npos
      result.wellResults[i] = wellPos
    elif well.rhd > 45.0 and well.rhd < 50.0:
      # not positive nor negative
      inc nweak
      # but "positive" in a sense
      result.wellResults[i] = wellPos
    else:
      # negative NaN
      result.wellResults[i] = wellNeg


    # save for pos samples
    minRhdCt = min(well.rhd, minRhdCt)
    maxGapdhCt = max(well.gapdh, maxGapdhCt)

  if npos == 2 or npos == 3:
    # putative positive sample, check DNA concentration
    # RHDct < GAPDHct  == RHDconc > GAPDHconc
    if minRhdCt < maxGapdhCt:
      echo "IncRhdHigh: ", sample.sampleId, " minRhdCt ", minRhdCt, " maxGapdhCt ", maxGapdhCt
      result.interp = IncRhdHigh
      return
    else:
      # approved
      result.interp = Pos
      return
  elif npos == 1:
    # early return for inconclusive pos
    echo "IncOnePositive: ", sample.sampleId
    result.interp = IncOnePositive
    return

  # putative negative sample, check gapdh controls again
  for well in sample.wells:
    if well.gapdh > gapdhMax:
      echo "IncDnaLow: ", sample.sampleId, " well: ", well
      result.interp = IncDnaLow
      return
    elif well.gapdh < gapdhMin:
      echo "IncDnaHigh: ", sample.sampleId, " well: ", well
      result.interp = IncDnaHigh
      return

  # finally check if there were weak signals present
  if nweak > 0:
    echo "IncRhdWeak: ", sample.sampleId, " wells: ", sample.wells
    result.interp = IncRhdWeak
    return

  # all controls passed - negative sample
  result.interp = Neg


template sampleSelectGroup(sample: Sample): string =
  ## Returns the select group name for sample
  optionPrefix & sample.sampleId


iterator getSampleInterpretations(samples: seq[Sample]): tuple[sampleId: string, value: string] =
  ## Returns the current selected interpretations for all samples listed in the
  ## results table. We accomplish this by iterating through the global list of
  ## samples and fetching the selected interpretation from the input elements
  ## in the table.
  ## Returns a seq of (sampleId, value) tuple, where value is in {P, I, N}

  for sample in samples:
    # elements for this sample are in the same option group, set with the
    # name="optionGroupName" property
    let
      selectGroup = sampleSelectGroup(sample).cstring
      elements = getElementById(selectGroup)

    # controls have no elements
    if elements.isNil:
      continue

    # iterate options
    var value = ""  # default empty, in case of value error it will not import

    for option in elements.options:
      # cast to access selected and value
      if option.selected:
        value = $option.value
        break

    yield (sample.sampleId, value)


const header = ["Prov-ID", "1", "2", "3", "Anmärkning", "Svar", "Sign 1", "Sign 2"]


proc sampleHtml(sample: Sample, barcode=false): string =
  ## Generate HTML row for sample
  let sampleResult = interpretSample(sample)

  var row = ""

  if barcode:
    let
      encoded = sample.sampleId.toCode128
      # parameters by trial and error
      svg = encoded.toSvg(
        height="1.5cm", width="width=3.5cm", textSize=11, fontFamily="sans-serif",
        showFrame=false, showText=true, debug=false
      )

      # make cell more compact
      row.add td(svg, style="padding: 0; line-height: 1.0;")
  else:
    row.add td(sample.sampleId)

  for i, well in pairs(sample.wells):
    row.add td($sampleResult.wellResults[i])  # '+' and '-' (en dash)
  row.add td($sampleResult.interp)

  var optGroup = ""

  for code in ["P", "I", "N"]:
    if
      code == "P" and sampleResult.interp == Pos or
      code == "I" and sampleResult.interp notin [Pos, Neg] or
      code == "N" and sampleResult.interp == Neg:
      optGroup.add option(code, selected="true")
    else:
      optGroup.add option(code)

  # id selectGroup is important since we use it to generate file output later
  let selectGroup = sampleSelectGroup(sample)
  row.add td(select(optGroup, id=selectGroup))

  # two signature cells
  row.add td()
  row.add td()

  # end
  result = tr(row)


proc useBarcode(): bool =
  ## Check whether or not bar code should be used in table
  let elem = getElementById(barcodeId)

  # check so that we don't crash if element is removed for some reason
  result = if elem.isNil: false else: elem.checked


proc toHtmlTable(samples: seq[Sample]): string =
  ## Convert results to HTML table
  var
    body = ""
    row = ""
  let barcode = useBarcode()
  for field in header:
    row.add th(field)
  let head = thead(tr(row))
  for sample in samples:
    # skip controls
    if sample.sampleId in [sNTC, sPC]: continue

    body.add sampleHtml(sample, barcode=barcode)
  result = table(head, tbody(body))


proc toFileOutputTable(samples: seq[Sample]): string =
  ## Convert results to text output format
  ## The output format is sample id and interpretation, separated by a tab
  ## character
  for sampleId, interpretation in getSampleInterpretations(samples):
    # skip samples where an interpretation is absent
    if interpretation == "":
      continue
    result.add sampleId
    result.add "\t"
    result.add interpretation
    result.add "\n"


template toDataUrl(contents: string): string =
  ## Converts `contents` into a data URL
  # https://developer.mozilla.org/en-US/docs/web/http/basics_of_http/data_urls
  const prefix = "data:text/plain;base64,"
  prefix & encode(contents)


template linkFileName(name: string): string =
  ## Generate link file name based on date and time
  # inplace trimming
  var trimmed = name
  trimmed.removeSuffix(".csv")

  let currTime = now().format("yyyyMMdd'_'HHmmss")
  trimmed & "_" & currTime & ".txt"


proc outputHtmlTable(samples: seq[Sample]) =
  ## Output samples as HTML table
  let htmlTable = toHtmlTable(samples)
  # set HTML
  getElementById(sampleOutputId).innerHTML = htmlTable.cstring


proc outputFile(samples: seq[Sample]) =
  ## Output file contents
  let
    fileOutputTable = toFileOutputTable(samples)  # make a file output results table
    dataUrl = toDataUrl(fileOutputTable)  # make a file link from data
    linkText = linkFileName(filename)  # linkname

  var fileOutput = ""

  fileOutput.add h3("Resultatfil")
  fileOutput.add p(a(href=dataUrl, download=linkText, linkText))
  fileOutput.add p(details(
    summary("Visa innehåll"),
    pre(code(fileOutputTable))
  ))

  # set HTML
  getElementById(fileOutputId).innerHTML = fileOutput.cstring


proc onInterpretationChange*() {.exportc.} =
  ## Called interpretation of sample data (may) have changed in any way.
  outputFile(globalSamples)


proc outputIntervalHtml() =
  ## Output the GAPDH interval string
  # don't pass gapdhMin/Max as parameters, to ensure that the global
  # value (used for analyses) is shown
  let
    minFormat = gapdhMin.formatFloat(ffDecimal, 1)
    maxFormat = gapdhMax.formatFloat(ffDecimal, 1)
    s = minFormat & " &ndash; " & maxFormat
  getElementById(gapdhIntervalId).innerHTML = s.cstring


proc outputMeansHtml(samples: seq[Sample]) =
  ## Output values for control to document

  # first run: calculate means
  var
    gapdhSum = 0.0
    rhdSum = 0.0
    rhdMean = 0.0

  for sample in samples:
    if sample.sampleId == sPC:
      for well in sample.wells:
        gapdhSum += well.gapdh
        rhdSum += well.rhd

      # set global var, round to one decimal as you would do on paper
      gapdhMean = round(gapdhSum / sample.wells.len.float, 1)

      # local var
      rhdMean = round(rhdSum / sample.wells.len.float, 1)

      break

  let
    gapdhOut = gapdhMean.formatFloat(ffDecimal, 1).cstring
    rhdOut = rhdMean.formatFloat(ffDecimal, 1).cstring

  getElementById(gapdhMeanId).innerHTML = gapdhOut
  getElementById(rhdMeanId).innerHTML = rhdOut


proc onParameterChange*() {.exportc.} =
  ## Called when parameters have changed. This will always affect sample
  ## interpretation so onInterpretationChange is called from here.

  # the only parameters that can be changed are the min/max diff
  # save to global variables. Recalculate and output
  setGapdhInterval()
  outputIntervalHtml()
  outputHtmlTable(globalSamples)

  # update outputs
  onInterpretationChange()


proc loadExportFile(contents, name: string) =
  ## Load and parse data, output parameter and sample tables, create and output
  ## results file.

  # set global file name
  filename = name

  # parse the file and load the global samples seq
  globalSamples = parseExportFile(contents)
  checkDataCompleteness(globalSamples)

  # we want the list sorted for practical reasons. could be removed
  globalSamples.sort(cmpSample)

  outputMeansHtml(globalSamples)

  # interpret and update output data
  onParameterChange()



proc fileLoaded*() {.exportc.} =
  ## Called when file input element is changed:
  ##
  ##   <input type="file" onchange="fileLoaded()" id="fileInput" accept=".csv" />

  # cast to InputElement to access fields
  let fileInput = InputElement(getElementById(inputId))

  # no file
  if fileInput.files.len == 0:
    return

  # since files is an array of length 1, extract the one file
  let file = dom.File(fileInput.files[0])

  # when file is loaded, return the contents as text, parse, analyze and output
  var reader = newFileReader()
  reader.addEventListener("load",
    proc (ev: Event) =
      loadExportFile($reader.`result`, $file.name)
  )

  reader.readAsText(file)
