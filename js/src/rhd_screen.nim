import strutils, base64, htmlgen, dom, tables, times, algorithm, sequtils, math

const
  inputId = "fileInput"
  outputId = "showcontent"

type
  Result = enum  ## possible results for a sample
    Pos = "P",  ## positive result
    Neg = "N",  ## negative result
    IncOnePositive = "I",  ## inconclusive with one positive reaction (or unclear reaction)
    IncDnaLow = "I",  ## inconclusive with low DNA conc
    IncDnaHigh = "I",  ## inconclusive with high DNA conc
    IncRhdHigh = "I"  ## inconclusive with RHD > GAPDH

  RawSample = object  ## a sample with values
    sampleId: string
    rhdCts: seq[float]
    gapdhCts: seq[float]

  Sample = object
    sampleId: string
    pattern: string  # eg., "+ + -"
    status: Result

# explanations for inconclusive results
const codes: array[Result, string] =
  [
    "",
    "",
    "endast en positiv reaktion",
    "låg DNA konc",
    "hög DNA konc",
    "RHD > GAPDH"
  ]

# result field, was missing from stdlib dom module
proc `result`*(f: FileReader): cstring {.importcpp: "#.result", nodecl.}


proc outputAndRaise(error: string) =
  ## Output an error message and raise
  const prefix = b("Fel vid inläsning av filen: ")
  document.getElementById(outputId).innerHtml = cstring(prefix & error)
  raise newException(ValueError, error)


proc assertControlsPresent(samples: Table[string, RawSample]) =
  ## Assert that controls are always present
  if "NTC" notin samples:
    outputAndRaise("förväntades en negativ kontroll \"NTC\" men det fanns ingen i filen")
  elif "PC" notin samples:
    outputAndRaise("förväntades en positiv kontroll \"PC\" men det fanns ingen i filen")


proc assertTriplicates(samples: Table[string, RawSample]) =
  ## Assert that all samples are triplicates
  for sample in samples.values:
    let minLen = if sample.sampleId == "NTC":
      1
    elif sample.sampleId == "PC":
      2
    else:
      3
    if sample.rhdCts.len != minLen:
      outputAndRaise("provet " & sample.sampleId & " hade bara " & $sample.rhdCts.len & " värden för RHD men minsta antal är " & $minLen)
    if sample.gapdhCts.len != minLen:
      outputAndRaise("provet " & sample.sampleId & " hade bara " & $sample.gapdhCts.len & " värden för GAPDH men minsta antal är " & $minLen)


proc parseExportFile(contents: string): Table[string, RawSample] =
  ## Parse the export file
  # File contains at least 4 comma/semicolon-separated fields per row, some fields are quoted

  for (i, line) in pairs(splitLines(contents)):
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

    # skip header row, field is sometimes quoted so cannot compare directly
    if "Well Position" in fields[0]:
      continue

    # rough check for errors
    if fields.len < 4:
      outputAndRaise("fel antal fält (n="  & $fields.len & ") på rad " & $i & ": " & line)

    # data rows
    let
      sampleId = fields[1].strip(chars={'\"'})
      gene = fields[2].strip(chars={'\"'})
      ctRaw = fields[3].strip(chars={'\"'})
    var ct: float
    if ctRaw == "Undetermined":
      ct = NaN
    else:
      try:
        ct = ctRaw.parseFloat
      except ValueError:
        outputAndRaise("inget giltigt Ct-värde (" & ctRaw & ") på rad " & $i & ": " & line)

    if sampleId notin result:
      result[sampleId] = RawSample(sampleId: sampleId, rhdCts: @[], gapdhCts: @[])

    # add result depending on gene name
    case gene
    of "RHD":
      result[sampleId].rhdCts.add ct
    of "GAPDH":
      result[sampleId].gapdhCts.add ct
    else:
      outputAndRaise("okänd gen \"" & gene & "\" på rad " & $i & ": " & line)

  # checks
  assertControlsPresent(result)
  assertTriplicates(result)


proc toDataUrl(contents: string): string =
  ## Converts `contents` into a data URL
  # https://developer.mozilla.org/en-US/docs/web/http/basics_of_http/data_urls
  const prefix = "data:text/plain;base64,"
  result = prefix & encode(contents)


proc linkFileName(file: string): string =
  ## Generate link file name based on date and time
  # inplace trimming
  var trimmed = file
  trimmed.removeSuffix(".csv")

  let currTime = now().format("yyyyMMdd'_'HHmmss")
  result = trimmed & "_" & currTime & ".txt"


proc checkPosNeg(sample: var Sample, rawSample: RawSample) =
  ## Determine if sample is positive or negative, or inconclusive
  var npos = 0
  for res in rawSample.rhdCts:
    if res.isNan or res >= 45.0:
      # no signal or too many cycles
      sample.pattern.add "- "
    elif res < 45.0:
      # detectable signal
      inc npos
      sample.pattern.add "+ "

  # some output string trimming
  sample.pattern = sample.pattern.strip()

  if npos == 0:
    # no signal at all
    sample.status = Neg
  elif npos == 1:
    # only one positive
    sample.status = IncOnePositive
  elif npos > 1:
    # positive by majority vote
    sample.status = Pos


proc checkDnaIsLow(sample: var Sample; rawSample: RawSample; gapdhMax: float): bool =
  ## Check if DNA conc is too low for negative or inconclusive samples
  if sample.status in [Neg, IncOnePositive]:
    for ct in rawSample.gapdhCts:
      if ct > gapdhMax:
        echo "checkDnaIsLow sample: ", sample.sampleId, " prev status: ", sample.status, " ct: ", ct, " gapdhMax: ", gapdhMax
        sample.status = IncDnaLow
        return true


proc checkDnaIsHigh(sample: var Sample; rawSample: RawSample; gapdhMin: float): bool =
  ## Check if DNA conc is too high for negative or inconclusive samples
  if sample.status in [Neg, IncOnePositive]:
    for ct in rawSample.gapdhCts:
      if ct < gapdhMin:
        echo "checkDnaIsHigh sample: ", sample.sampleId, " prev status: ", sample.status, " ct: ", ct, " gapdhMin: ", gapdhMin
        sample.status = IncDnaHigh
        return true


proc checkRhdHigh(sample: var Sample; rawSample: RawSample): bool =
  ## Check if ctRHD > ctGAPDH, suggesting a maternal gene
  # make it simple, check if the lowest RHD is lower than the highest ct
  if sample.status == Pos:
    if min(rawSample.rhdCts) < max(rawSample.gapdhCts):
      echo "checkRhdHigh sample: ", sample.sampleId, " prev status: ", sample.status, " min(rhdCts): ", min(rawSample.rhdCts), " max(gapdhCts): ", max(rawSample.gapdhCts)
      sample.status = IncRhdHigh
      return true


proc analyzeSample(rawSample: RawSample; gapdhMin, gapdhMax: float): Sample =
  ## Analyze one sample
  result.sampleId = rawSample.sampleId

  # it is ugly to modify objects inplace, but it works

  # initial status
  checkPosNeg(result, rawSample)

  # further checking
  if checkDnaIsLow(result, rawSample, gapdhMax):
    return
  if checkDnaIsHigh(result, rawSample, gapdhMin):
    return
  if checkRhdHigh(result, rawSample):
    return


func cmpSampleId(s1, s2: string): int =
  ## Comparison for sorting sample ids, omitting the first char
  # TODO: adapt to future sample id formats
  let
    s1start = max(s1.len - 11, 0)
    s2start = max(s2.len - 11, 0)
  cmp(s1[s1start..<s1.len], s2[s2start..<s2.len])


iterator sortedSamples(samples: Table[string, RawSample]): RawSample =
  ## Returns tuples of sample id and Sample in sorted order
  var sampleIds = toSeq(samples.keys).sorted(cmpSampleId)
  for sampleId in sampleIds:
    yield samples[sampleId]


proc verifyNegativeControl(ntcsample: RawSample) =
  ## Verify that the negative control is negative
  for res in ntcsample.rhdCts:
    if not res.isNaN:
      outputAndRaise("negativ RHD-kontroll är positiv: " & $res)
  for res in ntcsample.gapdhCts:
    if not res.isNaN:
      outputAndRaise("negativ GAPDH-kontroll är positiv: " & $res)


proc analyzeResults(samples: Table[string, RawSample]): seq[Sample] =
  ## Parse raw results and make sense of the numbers

  # save range
  let
    gapdhSum = sum(samples["PC"].gapdhCts)
    gapdhMean = gapdhSum / 2.0
    gapdhMin = gapdhMean - 1.5
    gapdhMax = gapdhMean + 6.4

  # some logging
  echo "gapdh mean: ", gapdhMean
  echo "gapdh min:  ", gapdhMin
  echo "gapdh max:  ", gapdhMax

  # TODO: what does the PC RHD control do?

  # check NTC
  verifyNegativeControl(samples["NTC"])

  # analyze samples
  for sample in sortedSamples(samples):
    # skip controls
    if sample.sampleId == "NTC" or sample.sampleId == "PC":
      continue
    let final = analyzeSample(sample, gapdhMin, gapdhMax)
    result.add final


const header = ["Prov-ID", "Resultat", "Svar", "Kommentar"]

proc toResultTable(samples: seq[Sample]): string =
  ## Convert results to text output format, tab-separated
  for sample in samples:
    result.add sample.sampleId
    result.add "\t"
    result.add codes[sample.status]
    result.add "\n"


proc sampleHtml(sample: Sample): string =
  ## Generate HTML row for sample
  let pattern = sample.pattern.replace("-", "&minus;")
  result = tr(
    td(sample.sampleId),
    td(pattern),
    td($sample.status),
    td(codes[sample.status])
  )


proc toHtmlTable(samples: seq[Sample]): string =
  ## Convert results to HTML table
  var
    body = ""
    row = ""
  for field in header:
    row.add th(field)
  body = tr(row)
  for sample in samples:
    body.add sampleHtml(sample)
  result = table(body)


proc htmlResult(contents, file: string): cstring =
  let
    sampleTable = parseExportFile(contents)  # parse raw input
    samples = analyzeResults(sampleTable)  # generate a run from collected samples

    resultTable = toResultTable(samples)  # make a text results table
    dataUrl = toDataUrl(resultTable)  # make a file link from data
    linkText = linkFileName(file)  # linkname

    htmlTable = toHtmlTable(samples)  # as HTML


  # the HTML result string, conversion upon return from proc
  var s: string

  s.add p(
    htmlTable
  )

  s.add h3("Länk till resultatfil")
  s.add p(a(href=dataUrl, download=linkText, linkText))

  s.add p(details(
    summary("Visa filens innehåll"),
    pre(code(resultTable))  # code or any html-like content will be rendered
  ))


  result = s.cstring


proc parseAndOutput(c, file: string) =
  ## Do the work
  document.getElementById("showcontent").innerHtml = htmlResult(c, file)


proc fileLoaded*() {.exportc.} =

  let fileInput = InputElement(document.getElementById(inputId))
  if fileInput.files.len == 0:
    return
  let file = dom.File(fileInput.files[0])

  var reader = newFileReader()
  reader.addEventListener("load",
    proc (ev: Event) =
      parseAndOutput($reader.`result`, $file.name)
  )

  reader.readAsText(file)
