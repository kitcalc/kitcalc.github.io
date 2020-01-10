import dom, tables, sets, algorithm, htmlgen, strutils
import remoterequest, alleles, eplets, locus

var
  epletsTable: array[Locus, Table[string, Eplet]]
  allelesTable: Table[string, Allele]

const
  epletUrl = "https://kitcalc.github.io/data/epitopes/eplets.txt"
  alleleUrl = "https://kitcalc.github.io/data/epitopes/alleles.txt"

  # checkbox whether or not to emulate HLAmatchmaker
  emulateMatchmakerId = "emulateMatchmaker"

  group = ["rec", "don"]
  loci = ["A", "B", "C", "DRB1", "DRB345", "DQA1", "DQB1", "DPA1", "DPB1"]
  fields = ["_1", "_2"]

proc setInner(id, value: string) =
  # set innerHtml value at id
  document.getElementById(id).innerHtml = value

proc setInnerOption(id, value, label: string) =
  # set an option value for id
  setInner(id, option(value, label) & '\n')

proc setAllFields(loc, name: string) =
  # Set all options at locus loc to allele name
  for ind in group:
    for field in fields:
      setInnerOption(ind & loc & field, name, name)

proc fillSelect() =
  ## Fill select elements with alleles, assume they are sorted
  for loc in loci:
    # start with a new line, to have an empty element on top
    setAllFields(loc, "")

  for allele in allelesTable.values:
    var loc = allele.name.split('*', maxsplit=1)[0]
    if allele.locus == DRB:
      case loc
      of "DRB3", "DRB4", "DRB5":
        loc = "DRB345"
    setAllFields(loc, allele.name)

proc getAlleles(data: cstring) =
  ## Parse and initialize allele table
  allelesTable = readAlleles($data, epletsTable)
  echo "alleles loaded from '", alleleUrl, "'"
  fillSelect()

proc getEplets(data: cstring) =
  ## Parse and initialize eplets table
  epletsTable = readEplets($data)
  echo "eplets loaded from '", epletUrl, "'"
  makeRequest(alleleUrl, getAlleles)

proc getAlleles(ind: string): seq[Allele] =
  ## Collect alleles in elements
  for loc in loci:
    for field in fields:
      let
        id = ind & loc & field
        alleleStr = $cast[OptionElement](document.getElementById(id)).value
      if alleleStr != "":
        result.add allelesTable[alleleStr]

proc getEplets(al: seq[Allele]): HashSet[Eplet] =
  ## Get eplets for alleles
  let emulate = document.getElementById(emulateMatchmakerId).checked
  for allele in al:
    if emulate:
      # save only eplets that are considered in the HLAmm algorithm
      for ep in allele.eplets:
        if ep.status == stBoth:
          result.incl ep
    else:
      result.incl allele.eplets

proc outputMismatchedEplets(epletsSet: HashSet[Eplet]) =
  ## Shows the mismatched eplets and the cardinality
  const
    # prefixes for output fields
    mmEpletCountId = "mmEpletCount"  # & locus
    mmEpletsId = "mmMismatchedEplets"  # & locus

  var
    # seqs to store eplets, reused between loci
    locusEpletsAbver: seq[string]
    locusEpletsOther: seq[string]

    # total counts
    abverCount = 0
    otherCount = 0

  # iterate all loci in Locus enum
  for loc in Locus:
    locusEpletsOther.setLen 0
    locusEpletsAbver.setLen 0

    for eplet in epletsSet:
      if eplet.locus == loc:
        case eplet.evidence
        of epVerified, epVerifiedPair:
          locusEpletsAbver.add eplet.name
        of epOther:
          locusEpletsOther.add eplet.name

    # sort both for "readability"
    locusEpletsAbver.sort()
    locusEpletsOther.sort()

    # all eplets first
    let epletCount = locusEpletsAbver.len + locusEpletsOther.len
    setInner(mmEpletCountId & $loc, $epletCount)

    # abver eplets
    setInner(mmEpletCountId & $loc & "Abver", $locusEpletsAbver.len)
    setInner(mmEpletsId & $loc & "Abver", locusEpletsAbver.join(", "))

    # other eplets
    setInner(mmEpletCountId & $loc & "Other", $locusEpletsOther.len)
    setInner(mmEpletsId & $loc & "Other", locusEpletsOther.join(", "))

    # update totals
    inc abverCount, locusEpletsAbver.len
    inc otherCount, locusEpletsOther.len

  # output summary
  const totalPrefix = mmEpletCountId & "Total"
  setInner(totalPrefix, $(abverCount + otherCount))
  setInner(totalPrefix & "Abver", $abverCount)
  setInner(totalPrefix & "Other", $otherCount)

func getWiebeCategory(dr, dq: Natural): string =
  ## Returns the Wiebe group as a string
  if dr < 7 and dq < 9:
    result = "Låg (low; DR <7 och DQ <9)"
  elif dr >= 7 and dq <= 14:
    result = "Medel (intermediate; DR ≥7 och DQ ≤14)"
  elif dr < 7 and dq < 14:
    result = "Medel (intermediate; DR 0–6 och DQ 9–14)"
  else:
    result = "Hög (high; DR 0–22 och DQ 15–31)"

proc outputWiebeRiskGroup(recEplets: HashSet[Eplet], donAlleles: seq[Allele]) =
  ## Output the risk group according to Wiebe et al.
  var
    maxDRB = 0
    maxDRBallele = "ingen"
    maxDQA1 = 0
    maxDQA1allele = "ingen"
    maxDQB1 = 0
    maxDQB1allele = "ingen"

  # look through all alleles, save the allele with the highest number of
  # mismatching eplets
  for allele in donAlleles:
    let
      alleleEplets = allele.eplets
      # mismatched eplet count
      mmEpletCount = (alleleEplets - recEplets).card

    case allele.locus
    of DRB:
      if mmEpletCount > maxDRB:
        maxDRBallele = allele.name
        maxDRB = mmEpletCount
    of DQA1:
      if mmEpletCount > maxDQA1:
        maxDQA1allele = allele.name
        maxDQA1 = mmEpletCount
    of DQB1:
      if mmEpletCount > maxDQB1:
        maxDQB1allele = allele.name
        maxDQB1 = mmEpletCount
    else: discard


  let
    dqSum = maxDQA1 + maxDQB1
    dqName = maxDQA1allele & " + " & maxDQB1allele
    category = getWiebeCategory(maxDRB, dqSum)

  document.getElementById("wiebeCategory").innerHtml = category

  document.getElementById("maxMismatchDRB").innerHtml = $maxDRB
  document.getElementById("maxMismatchAlleleDRB").innerHtml = maxDRBallele

  document.getElementById("maxMismatchDQAB").innerHtml = $dqSum
  document.getElementById("maxMismatchAlleleDQAB").innerHtml = dqName


proc showMismatchedEplets*() {.exportc.} =
  let
    recAlleles = getAlleles("rec")
    recEplets = getEplets(recAlleles)

    donAlleles = getAlleles("don")
    donEplets = getEplets(donAlleles)

    hvgEplets = donEplets - recEplets

  # include all eplets
  outputMismatchedEplets(hvgEplets)

  # include unverified eplets for Wiebe risk group
  outputWiebeRiskGroup(recEplets, donAlleles)

# this starts when the page loads
makeRequest(epletUrl, getEplets)
