import strutils, tables
import alleles, readfilecontents

type
  LabscreenResult* = object
    sampleId: string
    sampleDate: string
    alleleRawMfi: Table[string, int]

# necessary (?) for the js callback
var fileContents: string  ## global var with file contents
proc setFileContents(contents: cstring) = fileContents = $contents

const
  # expected fields in header
  expectedFields = [
    "SampleIDName", "SampleDate", "CatalogID",
    "LocusType", "SpecAbbr", "RawData"
  ]

  locusTypeName = "Single Class I"

# helpers
template splitRow(row: string): seq[string] = row.split(';')
template getRawMfi(s: string): int = s.replace(',', '.').parseFloat.int
template getAllele(s: string): string = s.strip(chars = {',', '-'})


proc initLabscreenResult(data: string): LabscreenResult =
  ## Parse the data into a LabscreenResult

  result.alleleRawMfi = initTable[string, int]()

  var
    fieldNumbers = initTable[string, int]()
    n = -1


  for line in data.splitLines():
    inc n
    let fields = line.splitRow
    case n
    of 0:
      for expected in expectedFields:
        doAssert expected in fields, "expected field " & expected & " not found"
      for i, field in fields:
        if field in expectedFields:
          fieldNumbers[field] = i
      continue
    of 1:
      # NC
      result.sampleId = fields[fieldNumbers["SampleIDName"]]
      result.sampleDate = fields[fieldNumbers["SampleDate"]]
      continue
    of 2:
      # PC
      continue
    else:
      if fields[fieldNumbers["LocusType"]] == locusTypeName:
        doAssert(fields[fieldNumbers["SampleIDName"]] == result.sampleId,
          "at least two sample IDs found in data!")
        let
          rawmfi = fields[fieldNumbers["RawData"]].getRawMfi
          allele = fields[fieldNumbers["SpecAbbr"]].getAllele
        result.alleleRawMfi[allele] = rawmfi
      else:
        # new section, LS2?
        break

  let beads = result.alleleRawMfi.len
  doAssert beads > 0 and beads < 100, "too few or too many beads in file!"


proc readLabScreenData*(elementId: cstring) {.exportc.} =
  ## Read the data from the LabScreen file pointed to in file input control
  #echo fileContents
  readFileContents(elementId, setFileContents)
  echo fileContents
  let ls = initLabscreenResult(fileContents)
  echo ls