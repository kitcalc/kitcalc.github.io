import strutils, base64, htmlgen, dom, tables, times, algorithm, sequtils

# General idea: parse the raw data, save each data row by sample id in a table
# Next, generate a Run where each sample has a final status (P, N, I;
# additionally, "I" samples have a reason enum attached) and where controls are
# checked and removed

const
  inputId = "fileInput"
  outputId = "showcontent"

type
  Sample = object  ## a sample with values
    rhdCts: seq[float]
    gapdhCts: seq[float]

  Run = object  ## master object for RHD screening run
    gapdhMin: float
    gapdhMax: float
    samples: Table[string, Sample]


# result field, was missing from stdlib dom module
proc `result`*(f: FileReader): cstring {.importcpp: "#.result", nodecl.}


proc outputAndRaise(error: string) =
  ## Output an error message and raise
  const prefix = b("Fel vid inläsning av filen: ")
  document.getElementById(outputId).innerHtml = cstring(prefix & error)
  raise newException(ValueError, error)


proc parseExportFile(contents: string): Table[string, Sample] =
  ## Parse the export file
  # File contains 4 comma-separated fields per row, some fields are quoted

  for (i, line) in pairs(splitLines(contents)):
    if line.len == 0:
      continue

    # echo metadata
    if line[0] == '#':
      echo line
      continue

    let fields = line.split(',')

    # rough check for errors
    if fields.len != 4:
      outputAndRaise("fel antal fält ("  & $fields.len & ") på rad " & $i & ": " & line)

    # data rows
    let
      sampleId = fields[1]
      gene = fields[2].strip(chars={'\"'})

    if gene notin ["RHD", "GAPDH"]:
      outputAndRaise("okänd gen \"" & gene & "\" på rad " & $i & ": " & line)

    let
      ctRaw = fields[3].strip(chars={'\"'})
      ct = if ctRaw == "Undetermined": NaN else: ctRaw.parseFloat

    if sampleId notin result:
      result[sampleId] = Sample(rhdCts: @[], gapdhCts: @[])

    # sanity check for genes
    case gene
    of "RHD":
      result[sampleId].rhdCts.add ct
    of "GAPDH":
      result[sampleId].gapdhCts.add ct
    else:
      outputAndRaise("internt fel: okänd gen \"" & gene & "\" på rad " & $i & ": " & line)

  # controls should be present
  if "NTC" notin result:
    outputAndRaise("förväntades en negativ kontroll \"NTC\" men fanns ingen i filen")
  elif "PC" notin result:
    outputAndRaise("förväntades en positiv kontroll \"PC\" men fanns ingen i filen")


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


proc analyzeResults(sample: Sample): string =

  # TODO: verify the results and, in secondary procs, set up rules for determine
  # sample pos/neg/inconclusive status
  discard

#proc sampleHtml(sampleId: string, sample: Sample): string =
#  ## Generate text for sample
#
#  # TODO
#
#  let
#    results = analyzeResults(sample)
#    line = sampleId & "\t" # &  TODO what should it look like
#
#  # join and end with newline
#  # result = gapdhLine.join("\t") & "\n" & rhdLine.join("\t") & "\n"


proc toResultTable(run: Run): string =
  ## Convert results to output format

  # TODO for each sample determine final status
  discard


func cmpSampleId(s1, s2: string): int =
  ## Comparison for sorting sample ids, omitting first char
  cmp(s1[1..<s2.len], s2[1..<s2.len])


iterator sortedSamples(samples: Table[string, Sample]): (string, Sample) =
  ## Returns tuples of sample id and Sample in sorted order
  var sampleIds = toSeq(samples.keys).sorted(cmpSampleId)
  for sampleId in sampleIds:
    yield (sampleId, samples[sampleId])


proc resultsToHtml(contents: string): string =
  ## Convert results to HTML table
  discard


proc parseRun(results: Table[string, Sample]): Run =
  ## Parse raw results and make sense of the numbers
  for (sampleId, sample) in sortedSamples(results):
    echo sampleId
    # TODO: special handling of controls
  # TODO: calc limits for GAPDH etc


proc htmlResult(contents, file: string): cstring =
  let
    results = parseExportFile(contents)  # parse raw input
    run = parseRun(results)  # generate a run
    resultTable = toResultTable(run)  # make a results table
    dataUrl = toDataUrl(resultTable)  # make a file link from data
    linkText = linkFileName(file)  # linkname

  # the HTML result string, conversion upon return from proc
  var s: string

  s = h3("Länk till konverterad fil")
  s.add p(a(href=dataUrl, download=linkText, linkText))

  s.add p(details(
    summary("Visa filens innehåll"),
    pre(code(resultTable))  # code or any html-like content will be rendered
  ))

  s.add p(details(
    summary("Visa resultat"),
    resultsToHtml(resultTable)
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
