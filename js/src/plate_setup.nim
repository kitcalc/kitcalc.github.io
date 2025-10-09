import strutils, base64, htmlgen, dom, jscore, streams, parsecsv

const
  inputId = "fileInput"
  outputId = "showcontent"
  commit = staticExec("git rev-parse HEAD")
  changesSinceCommit = gorgeEx("git diff --name-only --exit-code")[1] != 0


when changesSinceCommit:
  echo(
    "Based on git commit ", commit, " compiled ", CompileDate,
    " but `git diff --exit-code` returned > 0"
  )
else:
  echo "Generated from git commit ", commit, " compiled ", CompileDate

type
  # Limits of plate, but only 10 columns are used
  Column = range[1..12]  # at most 10, only controls can be in column 10
  Row = range['A'..'H']

  # A plate, layed out by row. Samples are, however, layed out by column
  Plate = array[Row, array[Column, string]]


# result field, was missing from stdlib dom module
proc `result`*(f: FileReader): cstring {.importcpp: "#.result", nodecl.}


proc outputAndRaise(error: string) =
  ## Output an error message and raise
  const prefix = b("Fel vid inläsning av filen: ")
  document.getElementById(outputId).innerHtml = cstring(prefix & error)
  raise newException(ValueError, error)


proc parseRackFile(contents, filename: string): Plate =
  ## Parse the csv-RackFile

  # The rack files are standardized and should be easy to parse with
  # a simple split(';')/trim('"') but using a proper csv-parser feels right

  var
    stream = newStringStream(contents)
    dataRows = false
    parser: CsvParser

  parser.open(stream, filename, separator=';', quote='"')
  defer: parser.close()

  while parser.readRow():
    case parser.processedRows()
    of 1:
      # check that file is in the expected format
      const expectedFormat = @["FileType", "RackFile", "2"]
      if parser.row.len > 2 and parser.row[0 .. 2] != expectedFormat:
        outputAndRaise("""okänt filformat: första raden förväntas vara "FileType";"RackFile";"2"""")
    else:
      if not dataRows:
        if parser.row[0] == "SampleID":
          # rows that follow are data rows
          dataRows = true

        # ignore metadata
        continue

      # 13 ';'-separated fields per data row, blank lines (trailing) are skipped
      if parser.row.len != 13:
        outputAndRaise(
          "fel antal fält på rad " & $parser.row  & ": " & $parser.row.len
        )

      let sampleId = parser.row[0]

      # unused wells are still in the file, skip these
      if sampleId.len == 0:
        continue

      let
        position = parser.row[2].split(":")
        row: Row = position[0][0]  # char
        col: Column = position[1].parseInt  # int

      result[row][col] = sampleId


proc toDataUrl(contents: string): string =
  ## Converts `contents` into a data URL
  # https://developer.mozilla.org/en-US/docs/web/http/basics_of_http/data_urls
  const prefix = "data:text/plain;base64,"
  result = prefix & encode(contents)


proc linkFileName(file: string): string =
  ## Generate link file name
  # inplace trimming
  var trimmed = file
  trimmed.removeSuffix(".csv")

  # jscore Date is used since times adds ~40 kb; original was
  #   import times
  #   let currTime = now().format("yyyyMMdd'_'HHmmss")
  #   result = trimmed & "_" & currTime & ".txt"

  let
    # compensate for time being in UTC
    dateUtc = newDate()
    offset = dateUtc.getTimezoneOffset()
    # cast to int64 or overflow
    dateObj = newDate(dateUtc.getTime().int64 - offset * 60 * 1000)

    dateStr = $dateObj.toISOString() # 2011-10-05T14:48:00.000Z
    dateSplit = dateStr.split('T')
    rawDate = dateSplit[0]
    date = rawDate.split('-').join()
    rawTime = dateSplit[1].split('.')[0]
    time = rawTime.split(':').join()

  result = trimmed & "_" & date & "_" & time & ".txt"


const
  # table header is tab-separated
  plateHeader = """* Block Type = 96alum
* Chemistry = TAQMAN
* Experiment File Name = D:\Users\INSTR-USER\Desktop\Devyser RHD template 7500 v2_3 20200831.edt
* Experiment Run End Time = Not Started
* Instrument Type = sds7500
* Passive Reference = ROX

[Sample Setup]
Well	Sample Name	Sample Color	Biogroup Name	Biogroup Color	Target Name	Target Color	Task	Reporter	Quencher	Quantity	Comments
"""

proc plateSample(sample, position, color: string): string =
  ## Generate text for sample, two lines including control
  const
    vicRgb = "\"RGB(208,243,98)\""
    vic = "VIC"
    famRgb = "\"RGB(139,189,249)\""
    fam = "FAM"
    gapdh = "GAPDH"
    rhd = "RHD"
    que = "NFQ-MGB"
    unk = "UNKNOWN"

  let
    # GAPDH - VIC
    gapdhLine = [
      position, sample, color, "", "", gapdh, vicRgb, unk, vic, que, "", ""
    ]

    # RHD - FAM
    rhdLine = [
      position, sample, color, "", "", rhd, famRgb, unk, fam, que, "", ""
    ]

  # join and end with newline
  result = gapdhLine.join("\t") & "\n" & rhdLine.join("\t") & "\n"

const colors = [
  "\"RGB(132,193,241)\"",
  "\"RGB(168,255,222)\"",
  "\"RGB(223,221,142)\"",
  "\"RGB(247,255,168)\"",
  "\"RGB(180,255,0)\"",
  "\"RGB(255,204,153)\"",
  "\"RGB(253,138,88)\"",
  "\"RGB(213,244,165)\"",
  "\"RGB(96,255,160)\""
]

proc toPlateSetup(plate: Plate): string =
  ## Convert plate to output format
  result = plateHeader
  var
    lastSampleId = ""
    colorId = 0
  for row in Row.low .. Row.high:
    for col in Column.low .. Column.high:
      # oddly, output by column but with row index first
      let
        sample = plate[row][col]
        pos = $row & $col  # A1 .. H12
      if sample != lastSampleId:
        # change to next color
        colorId = (colorId + 1) mod colors.len

        lastSampleId = sample

      let samplecolor = colors[colorId]

      result.add plateSample(sample, pos, samplecolor)


proc columnIndex(): string =
  ## Static proc to generate column index for table
  var colIndex = td("")  # empty top left
  for col in Column.low .. Column.high:
    colIndex.add td(small($col))
  result = tr(colIndex)


proc plateToTable(plate: Plate): string =
  ## Convert plate to table
  var rows = columnIndex()
  for row in Row.low .. Row.high:
    var rowData = td(small(row))
    for sample in plate[row]:
      rowData.add td(small(sample))
    rows.add tr(rowData)
  result = table(rows)


proc htmlResult(contents, filename: string): cstring =
  let
    linkText = linkFileName(filename)
    plate = parseRackFile(contents, filename)

    # file must have windows newlines!!!
    plateSetup = toPlateSetup(plate).replace("\n", "\c\n")

    dataUrl = toDataUrl(plateSetup)

  # the HTML result string, explicit conversion upon return from proc
  var s = h3("Länk till konverterad fil")

  s.add p(a(href=dataUrl, download=linkText, linkText))

  s.add p(details(
    summary("Visa filens innehåll"),
    pre(code(plateSetup))  # code or any html-like content will be rendered
  ))

  s.add p(details(
    summary("Visa platta"),
    plateToTable(plate)
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
