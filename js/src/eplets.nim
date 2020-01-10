import strutils, hashes, tables
import locus

type
  Evidence* = enum
    epVerified,
    epVerifiedPair,
    epOther

  Eplet* = ref object
    name*: string
    evidence*: Evidence
    locus*: Locus

proc parseEvidence(evidence: string): Evidence =
  ## Parse the evidence kind
  case evidence
  of "verified_eplet":
    result = epVerified
  of "verified_pair":
    result = epVerifiedPair
  of "other_eplet":
    result = epOther
  else:
    raise newException(ValueError, "unknown eplet evidence: " & evidence)

proc newEplet(name: string, evidence: string, locus: string): Eplet =
  ## Initialize an eplet
  new(result)
  result.name = name
  result.evidence = parseEvidence(evidence)
  result.locus = parseLocus(locus)

proc hash*(ep: Eplet): Hash =
  ## Hash function for eplets
  var h: Hash = 0
  h = h !& hash(ep.name)
  h = h !& hash(ep.evidence)
  h = h !& hash(ep.locus)
  result = !$h

proc checkEpletHeader(fields: seq[string]): bool =
  ## Check header format
  const expectedHeader = @["eplet", "evidence", "locus"]
  result = fields == expectedHeader

proc readEplets*(data: string): Table[Locus, Table[string, Eplet]] =
  ## Read eplets from ``data``
  ## Save in Table with Locus as key, Table with eplet name as ket and data
  ## as value
  var firstRow = true
  for line in splitLines(data):
    let fields = line.split()
    if firstRow:
      if not checkEpletHeader(fields):
        raise newException(ValueError, "unknown file format for eplet data")
      else:
        firstRow = false
        continue
    elif line.len == 0:
      continue
    elif fields.len != 3:
      raise newException(ValueError, "unknown format of line: '" & line & "'")
    let ep = newEplet(fields[0], fields[1], fields[2])
    if ep.locus notin result:
      result[ep.locus] = initTable[string, Eplet]()
    result[ep.locus][ep.name] = ep
