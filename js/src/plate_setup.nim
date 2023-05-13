import strutils, base64, htmlgen, dom, times

const
  inputId = "fileInput"
  outputId = "showcontent"

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


proc parseRackFile(contents: string): Plate =
  ## Parse the csv-RackFile
  # File contains 13 ';'-separated fields per row

  for (i, line) in pairs(splitLines(contents)):
    if line.len == 0:
      continue

    let fields = line.split(';')

    # rough check for errors
    if fields.len != 13:
      outputAndRaise("fel antal fält på rad " & $i & ": (" & $fields.len & ")")

    # handling content on specific rows
    case i
    of 0:
      # check first row
      if fields[0] != "FileType":
        outputAndRaise("\"FileType\" förväntades som första fält på första raden")
    of 1..7:
      # skip metadata rows
      discard
    else:
      # data rows
      let
        sampleId = fields[0]
        position = fields[2].split(":")
        row: Row = position[0][0]  # char
        col: Column = position[1].parseInt  # int
      if sampleId.len == 0:
        continue
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

  let currTime = now().format("yyyyMMdd'_'HHmmss")
  result = trimmed & "_" & currTime & ".txt"


const
  # table header is tab-separated
  plateHeader = """* Block Type = 96alum
* Chemistry = TAQMAN
* Experiment File Name = C:\Users\leocadie.henry\OneDrive - Thermo Fisher Scientific\Documents\Cases\2023\01855962 _SE_7500_SSO_SN_ 8046438_LUNDS UNIVERSITETSSJUKHUS\Devyser RHD template 7500 v2_3 20200831.edt
* Experiment Run End Time = Not Started
* Instrument Type = sds7500
* Passive Reference = ROX

[Sample Setup]
Well	Sample Name	Sample Color	Biogroup Name	Biogroup Color	Target Name	Target Color	Task	Reporter	Quencher	Quantity	Comments
"""

proc plateSample(sample: string, position: string): string =
  ## Generate text for sample, two lines including control
  const
    vicRgb = "\"RGB(208,243,98)\""
    vic = "VIC"
    famRgb = "\"RGB(139,189,249)\""
    fam = "FAM"
    gapdh = "GAPDH"
    rhd = "RHD"
    que = "NFQ-MGB"

  let
    # GAPDH - VIC
    gapdhLine = [
      position, sample, "", "", "", gapdh, vicRgb, gapdh, vic, que, "", ""
    ]

    # RHD - FAM
    rhdLine = [
      position, sample, "", "", "", rhd, famRgb, rhd, fam, que, "", ""
    ]

  # join and end with newline
  result = gapdhLine.join("\t") & "\n" & rhdLine.join("\t") & "\n"

proc toPlateSetup(plate: Plate): string =
  ## Convert plate to output format
  result = plateHeader
  for row in Row.low .. Row.high:
    for col in Column.low .. Column.high:
      # oddly, output by column but with row index first
      let
        sample = plate[row][col]
        pos = $row & $col  # A1 .. H12
      result.add plateSample(sample, pos)

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


proc htmlResult(contents, file: string): cstring =
  let
    linkText = linkFileName(file)
    plate = parseRackFile(contents)
    plateSetup = toPlateSetup(plate)

    dataUrl = toDataUrl(plateSetup)

  # the HTML result string, explicit conversion upon return from proc
  var s: string

  s = h3("Länk till konverterad fil")
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
