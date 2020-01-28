import dom, tables, sets, algorithm, htmlgen, strutils
import remoterequest, alleles, eplets, locus

var
  epletsTable: array[Locus, array[Evidence ,Table[string, Eplet]]]
  allelesTable: Table[string, Allele]

const
  epletUrl = "https://kitcalc.github.io/data/epitopes/eplets.txt"
  alleleUrl = "https://kitcalc.github.io/data/epitopes/alleles.txt"

  # checkbox whether or not to emulate HLAmatchmaker
  emulateMatchmakerId = "emulateMatchmaker"

type
  Group = enum
    rec, don
  FieldLoci = enum
    flA = "A", flB = "B", flC = "C", flDRB1 = "DRB1", flDRB345 = "DRB345",
    flDQA1 = "DQA1", flDQB1 = "DQB1", flDPA1 = "DPA1", flDPB1 = "DPB1"
  Fields = enum
    first = "_1",
    second = "_2"

proc setInner(id, value: string) =
  # set innerHtml value at id
  document.getElementById(id).innerHtml = value

proc fillSelect() =
  ## Fill select elements with alleles

  # nested array of strings, to be assigned as options later. Assigning them
  # one at a time is VERY slow
  var options: array[FieldLoci, seq[string]]

  # fill lists
  for allele in allelesTable.values:
    var locStr = allele.name.split('*', maxsplit=1)[0]
    if allele.locus == DRB:
      case locStr
      of "DRB3", "DRB4", "DRB5":
        locStr = "DRB345"

    let loc = parseEnum[FieldLoci](locStr)
    options[loc].add option(value=allele.name, allele.name & "\n")

  # sort alleles
  for opt in mitems(options):
    opt.sort()

  # output, empty element on top
  let empty = option(value="", "") & "\n"
  for loc in FieldLoci:
    let output = empty & options[loc].join("\n")
    for g in Group:
      for f in Fields:
        setInner($g & $loc & $f, output)

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

proc getAlleles(ind: Group): seq[Allele] =
  ## Collect alleles in elements
  for loc in FieldLoci:
    for field in Fields:
      let
        id = $ind & $loc & $field
        alleleStr = $cast[OptionElement](document.getElementById(id)).value
      if alleleStr != "":
        result.add allelesTable[alleleStr]

proc getEplets(al: Allele): HashSet[Eplet] =
  ## Get eplets for allele, take emulation into consideration
  let emulate = document.getElementById(emulateMatchmakerId).checked
  if emulate:
    # save only eplets that are considered in the HLAmm algorithm
    for ep in al.eplets:
      if ep.status == stBoth or ep.status.stBothCountedOnly:
        result.incl ep
  else:
    result.incl al.eplets

proc getEplets(al: seq[Allele]): HashSet[Eplet] =
  ## Get eplets for alleles
  for allele in al:
    result.incl getEplets(allele)

func getPrintableEplets(eps: seq[Eplet]): seq[Eplet] =
  ## Returns the printable eplets in eps, taking emulation into consideration
  let emulate = document.getElementById(emulateMatchmakerId).checked
  if not emulate:
    return eps
  for ep in eps:
    if ep.status == stBoth:
      result.add ep

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
        if eplet.isVerified:
          locusEpletsAbver.add eplet.name
        else:
          locusEpletsOther.add eplet.name

    # sort both for "readability"
    locusEpletsAbver.sort()
    locusEpletsOther.sort()

    # all eplets first
    let epletCount = locusEpletsAbver.len + locusEpletsOther.len
    setInner(mmEpletCountId & $loc, $epletCount)

    # when we emulate HLAmm, counts and printed eplets don't always match

    # abver eplets
    setInner(mmEpletCountId & $loc & "Abver", $locusEpletsAbver.len)
    setInner(mmEpletsId & $loc & "Abver", getPrintableEplets(locusEpletsAbver).join(", "))

    # other eplets
    setInner(mmEpletCountId & $loc & "Other", $locusEpletsOther.len)
    setInner(mmEpletsId & $loc & "Other", getPrintableEplets(locusEpletsOther).join(", "))

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
      alleleEplets = getEplets(allele)
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
    recAlleles = getAlleles(rec)
    recEplets = getEplets(recAlleles)

    donAlleles = getAlleles(don)
    donEplets = getEplets(donAlleles)

    hvgEplets = donEplets - recEplets

  # include all eplets
  outputMismatchedEplets(hvgEplets)

  # include unverified eplets for Wiebe risk group
  outputWiebeRiskGroup(recEplets, donAlleles)

# this starts when the page loads
makeRequest(epletUrl, getEplets)
