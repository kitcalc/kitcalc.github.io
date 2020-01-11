import sets, hashes, tables, strutils
import eplets, locus

type
  Allele* = ref object
    name*: string
    eplets*: HashSet[Eplet]
    locus*: Locus

proc newAllele(name: string, locus: Locus): Allele =
  ## Initialize an allele
  new(result)
  result.name = name
  result.locus = locus

proc checkAlleleHeader(fields: seq[string]): bool =
  ## Check that the header is correct
  const expectedHeader = @["allele", "eplet", "locus"]
  result = fields == expectedHeader

proc readAlleles*(data: string, eplets: array[Locus, Table[string, Eplet]]): Table[string, Allele] =
  ## Read alleles from ``data`` and annotates eplets from ``eplets``
  result = initTable[string, Allele]()
  var firstRow = true
  for line in splitLines(data):
    if line.len == 0: continue
    let fields = line.split()
    if firstRow:
      if not checkAlleleHeader(fields):
        raise newException(Exception, "unknown file format for allele data")
      else:
        firstRow = false
        continue
    elif fields.len != 3:
      raise newException(Exception, "unknown format of line: '" & line & "'")
    let
      allelename = fields[0]
      epletname = fields[1]
      locus = parseLocus(fields[2])
    if allelename notin result:
      result[allelename] = newAllele(allelename, locus)
    if epletname in eplets[locus]:
      result[allelename].eplets.incl eplets[locus][epletname]
