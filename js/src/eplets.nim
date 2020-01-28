import strutils, hashes, tables
import locus

type
  Evidence* = enum
    epVerified,
    # epVerifiedPair,  # not used in the epitope matching sheets
    epOther

  Status* = enum
    stTable,
    stAlgorithm,
    stBothCountedOnly,
    stBoth

  Eplet* = ref object
    name*: string
    evidence*: Evidence
    locus*: Locus
    status*: Status

func parseEvidence(evidence: string): Evidence =
  ## Parse the evidence kind
  case evidence
  of "verified_eplet": result = epVerified
  # of "verified_pair": result = epVerifiedPair
  of "other_eplet": result = epOther
  else:
    raise newException(ValueError, "unknown eplet evidence: " & evidence)

func isVerified*(ep: Eplet): bool =
  case ep.evidence
  of epVerified: result = true
  # of epVerifiedPair: result = true
  else: result = false

func parseStatus(status: string): Status =
  ## Parse the status of eplets in tables
  case status
  of "table_only": result = stTable
  of "algorithm_only": result = stAlgorithm
  of "both_counted_only": result = stBothCountedOnly
  of "both": result = stBoth
  else:
    raise newException(ValueError, "unknown eplet status: " & status)

func newEplet*(name, evidence, locus, status: string): Eplet =
  ## Initialize an eplet
  new(result)
  result.name = name
  result.evidence = parseEvidence(evidence)
  result.locus = parseLocus(locus)
  result.status = parseStatus(status)

func hash*(ep: Eplet): Hash =
  ## Hash function for eplets
  var h: Hash = 0
  h = h !& hash(ep.name)
  h = h !& hash(ep.evidence)
  h = h !& hash(ep.locus)
  h = h !& hash(ep.status)
  result = !$h

func checkEpletHeader(fields: seq[string]): bool =
  ## Check header format
  const expectedHeader = @["eplet", "evidence", "locus", "status"]
  result = fields == expectedHeader

func readEplets*(data: string): array[Locus, array[Evidence, Table[string, Eplet]]] =
  ## Read eplets from ``data``
  ## Save in array indexed by Locus and Evidence, with Table with eplet name as
  ## key and data as value
  var firstRow = true
  for line in splitLines(data):
    if line.len == 0: continue
    let fields = line.split()
    if firstRow:
      if not checkEpletHeader(fields):
        raise newException(ValueError, "unknown file format for eplet data")
      else:
        firstRow = false
        continue
    if fields.len != 4:
      raise newException(ValueError, "unknown format of line: '" & line & "'")

    let ep = newEplet(fields[0], fields[1], fields[2], fields[3])

    result[ep.locus][ep.evidence][ep.name] = ep

    #[
    if ep.name in result[ep.locus]:
      # prioritize eplets for status - both > algorithm > table
      case result[ep.locus][ep.name].status
      of stAlgorithm:
        if ep.status == stBoth:
          result[ep.locus][ep.name] = ep
      of stTable:
          result[ep.locus][ep.name] = ep
      of stBoth: discard
    else:
      result[ep.locus][ep.name] = ep

    ]#