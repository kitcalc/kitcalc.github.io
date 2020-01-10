import dom, tables, sets, algorithm, htmlgen, strutils
import remoterequest, alleles, eplets, locus


var
  epletsTable: Table[Locus, Table[string, Eplet]]
  allelesTable: Table[string, Allele]


const
  epletABCurl = "https://kitcalc.github.io/data/epitopes/abc_eplets.txt"
  alleleABCurl = "https://kitcalc.github.io/data/epitopes/abc_alleles.txt"
  epletDRDQurl = "https://kitcalc.github.io/data/epitopes/drdq_eplets.txt"
  alleleDRDQurl = "https://kitcalc.github.io/data/epitopes/drdq_alleles.txt"
  epletDPurl = "https://kitcalc.github.io/data/epitopes/dp_eplets.txt"
  alleleDPurl = "https://kitcalc.github.io/data/epitopes/dp_alleles.txt"

  # input element ids
  recElementsA = ["recA1", "recA2"]
  recElementsB = ["recB1", "recB2"]
  recElementsC = ["recC1", "recC2"]
  recElementsDRB1 = ["recDRB1_1", "recDRB1_2"]
  recElementsDRB345 = ["recDRB345_1", "recDRB345_2"]
  recElementsDQA1 = ["recDQA1_1", "recDQA1_2"]
  recElementsDQB1 = ["recDQB1_1", "recDQB1_2"]
  recElementsDPA1 = ["recDPA1_1", "recDPA1_2"]
  recElementsDPB1 = ["recDPB1_1", "recDPB1_2"]

  recElements = @[
    recElementsA,
    recElementsB,
    recElementsC,
    recElementsDRB1,
    recElementsDRB345,
    recElementsDQA1,
    recElementsDQB1,
    recElementsDPA1,
    recElementsDPB1
  ]


  donElementsA = ["donA1", "donA2"]
  donElementsB = ["donB1", "donB2"]
  donElementsC = ["donC1", "donC2"]
  donElementsDRB1 = ["donDRB1_1", "donDRB1_2"]
  donElementsDRB345 = ["donDRB345_1", "donDRB345_2"]
  donElementsDQA1 = ["donDQA1_1", "donDQA1_2"]
  donElementsDQB1 = ["donDQB1_1", "donDQB1_2"]
  donElementsDPA1 = ["donDPA1_1", "donDPA1_2"]
  donElementsDPB1 = ["donDPB1_1", "donDPB1_2"]

  donElements = @[
    donElementsA,
    donElementsB,
    donElementsC,
    donElementsDRB1,
    donElementsDRB345,
    donElementsDQA1,
    donElementsDQB1,
    donElementsDPA1,
    donElementsDPB1
  ]


proc fillSelect() =
  ## Fill select elements with alleles

  var
    alleleA = newSeq[string]()
    alleleB = newSeq[string]()
    alleleC = newSeq[string]()
    alleleDRB1 = newSeq[string]()
    alleleDRB345 = newSeq[string]()
    alleleDQA1 = newSeq[string]()
    alleleDQB1 = newSeq[string]()
    alleleDPA1 = newSeq[string]()
    alleleDPB1 = newSeq[string]()

  for allele in allelesTable.values:
    case allele.locus
    of ABC:
      case allele.name[0]
      of 'A': alleleA.add allele.name
      of 'B': alleleB.add allele.name
      of 'C': alleleC.add allele.name
      else:
        echo "unknown locus in allele ", allele.name
    of DRB:
      case allele.name[0..<4]
      of "DRB1": alleleDRB1.add allele.name
      of "DRB3", "DRB4", "DRB5": alleleDRB345.add allele.name
    of DQA1:
      alleleDQA1.add allele.name
    of DQB1:
      alleleDQB1.add allele.name
    of DPA1:
      alleleDPA1.add allele.name
    of DPB1:
      alleleDPB1.add allele.name

  alleleA.sort()
  alleleB.sort()
  alleleC.sort()
  alleleDRB1.sort()
  alleleDRB345.sort()
  alleleDQA1.sort()
  alleleDQB1.sort()
  alleleDPA1.sort()
  alleleDPB1.sort()

  # start with a new line, to have an empty element on top
  var alleleList = option(value="", "")

  for allele in alleleA:
    alleleList &= option(value=allele, allele) & "\n"

  for element in recElementsA:
    document.getElementById(element).innerHtml = alleleList
  for element in donElementsA:
    document.getElementById(element).innerHtml = alleleList

  alleleList = option(value="", "")

  for allele in alleleB:
    alleleList &= option(value=allele, allele) & "\n"

  for element in recElementsB:
    document.getElementById(element).innerHtml = alleleList
  for element in donElementsB:
    document.getElementById(element).innerHtml = alleleList

  alleleList = option(value="", "")

  for allele in alleleC:
    alleleList &= option(value=allele, allele) & "\n"

  for element in recElementsC:
    document.getElementById(element).innerHtml = alleleList
  for element in donElementsC:
    document.getElementById(element).innerHtml = alleleList

  alleleList = option(value="", "")

  for allele in alleleDRB1:
    alleleList &= option(value=allele, allele) & "\n"

  for element in recElementsDRB1:
    document.getElementById(element).innerHtml = alleleList
  for element in donElementsDRB1:
    document.getElementById(element).innerHtml = alleleList

  alleleList = option(value="", "")

  for allele in alleleDRB345:
    alleleList &= option(value=allele, allele) & "\n"

  for element in recElementsDRB345:
    document.getElementById(element).innerHtml = alleleList
  for element in donElementsDRB345:
    document.getElementById(element).innerHtml = alleleList

  alleleList = option(value="", "")

  for allele in alleleDQA1:
    alleleList &= option(value=allele, allele) & "\n"

  for element in recElementsDQA1:
    document.getElementById(element).innerHtml = alleleList
  for element in donElementsDQA1:
    document.getElementById(element).innerHtml = alleleList

  alleleList = option(value="", "")

  for allele in alleleDQB1:
    alleleList &= option(value=allele, allele) & "\n"

  for element in recElementsDQB1:
    document.getElementById(element).innerHtml = alleleList
  for element in donElementsDQB1:
    document.getElementById(element).innerHtml = alleleList

  alleleList = option(value="", "")

  for allele in alleleDPA1:
    alleleList &= option(value=allele, allele) & "\n"

  for element in recElementsDPA1:
    document.getElementById(element).innerHtml = alleleList
  for element in donElementsDPA1:
    document.getElementById(element).innerHtml = alleleList

  alleleList = option(value="", "")

  for allele in alleleDPB1:
    alleleList &= option(value=allele, allele) & "\n"

  for element in recElementsDPB1:
    document.getElementById(element).innerHtml = alleleList
  for element in donElementsDPB1:
    document.getElementById(element).innerHtml = alleleList

proc mergeTable[A,B](t1: var Table[A, B], t2: Table[A, B]) =
  ## Merge ``t2`` into ``t1``.
  for key, value in t2:
    t1[key] = value


# This section is ugly all relies on nested callbacks; read from bottom to top

proc getAlleleDP(data: cstring) =
  ## Parse and initialize allele table
  allelesTable.mergeTable readAlleles($data, epletsTable)
  echo "alleles loaded from '", alleleDPurl, "'"

  # finally, fill all select elements
  fillSelect()

proc getEpletDP(data: cstring) =
  ## Parse and initialize eplets table
  epletsTable.mergeTable readEplets($data)
  echo "eplets loaded from '", epletDPurl, "'"
  makeRequest(alleleDPurl, getAlleleDP)

proc getAlleleDRDQ(data: cstring) =
  ## Parse and initialize allele table
  allelesTable.mergeTable readAlleles($data, epletsTable)
  echo "alleles loaded from '", alleleDRDQurl, "'"
  makeRequest(epletDPurl, getEpletDP)

proc getEpletDRDQ(data: cstring) =
  ## Parse and initialize eplets table
  epletsTable.mergeTable readEplets($data)
  echo "eplets loaded from '", epletDRDQurl, "'"
  makeRequest(alleleDRDQurl, getAlleleDRDQ)

proc getAlleleABC(data: cstring) =
  ## Parse and initialize allele table
  allelesTable = readAlleles($data, epletsTable)
  echo "alleles loaded from '", alleleABCurl, "'"
  makeRequest(epletDRDQurl, getEpletDRDQ)

proc getEpletABC(data: cstring) =
  ## Parse and initialize eplets table
  epletsTable = readEplets($data)
  echo "eplets loaded from '", epletABCurl, "'"
  makeRequest(alleleABCurl, getAlleleABC)


proc getAlleles(elements: seq[array[2, string]]): seq[Allele] =
  ## Collect alleles in elements
  for elementGroup in elements:
    for element in elementGroup:
      let alleleStr = $cast[OptionElement](document.getElementById(element)).value
      # skip empty alleles
      if alleleStr != "":
        result.add allelesTable[alleleStr]

proc getEplets(al: seq[Allele]): HashSet[Eplet] =
  ## Get eplets for alleles
  result = initHashSet[Eplet]()
  for allele in al:
    result.incl allele.eplets

func getAbverEplets(eplets: HashSet[Eplet]): HashSet[Eplet] =
    for eplet in eplets:
      case eplet.evidence
      of epVerified, epVerifiedPair:
        result.incl eplet
      of epOther: discard


proc outputMismatchedEplets(epletsSet: HashSet[Eplet]) =
  ## Shows the mismatched eplets and the cardinality

  const
    # prefixes for output fields
    mmEpletCountId = "mmEpletCount"  # & locus
    mmEpletsId = "mmMismatchedEplets"  # & locus

  # subset abver eplets
  let
    abverEps = getAbverEplets(epletsSet)
    otherEps = epletsSet - abverEps

  # output summary
  let totalPrefix = mmEpletCountId & "Total"
  document.getElementById(totalPrefix).innerHtml = $epletsSet.card
  document.getElementById(totalPrefix & "Abver").innerHtml = $abverEps.len
  document.getElementById(totalPrefix & "Other").innerHtml = $otherEps.len

  # seq to store eplets, reused between loci
  var
    locusEpletsAbver: seq[string]
    locusEpletsOther: seq[string]

  # iterate all loci in Locus enum
  for locus in Locus:

    locusEpletsOther.setLen 0
    locusEpletsAbver.setLen 0

    for eplet in epletsSet:
      if eplet.locus == locus:
        if eplet in abverEps:
          locusEpletsAbver.add eplet.name
        elif eplet in otherEps:
          # not abVer -> other
          locusEpletsOther.add eplet.name
        else: doAssert false

    # sort both for readability
    locusEpletsAbver.sort()
    locusEpletsOther.sort()

    # all eplets first
    let epletCount = locusEpletsAbver.len + locusEpletsOther.len
    document.getElementById(mmEpletCountId & $locus).innerHtml = $epletCount

    # abver eplets
    document.getElementById(mmEpletCountId & $locus & "Abver").innerHtml = $len(locusEpletsAbver)
    document.getElementById(mmEpletsId & $locus & "Abver").innerHtml = locusEpletsAbver.join(", ")

    # other eplets
    document.getElementById(mmEpletCountId & $locus & "Other").innerHtml = $len(locusEpletsOther)
    document.getElementById(mmEpletsId & $locus & "Other").innerHtml = locusEpletsOther.join(", ")

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
    recAlleles = getAlleles(recElements)
    recEplets = getEplets(recAlleles)

    donAlleles = getAlleles(donElements)
    donEplets = getEplets(donAlleles)

    hvgEplets = donEplets - recEplets

  # include all eplets
  outputMismatchedEplets(hvgEplets)

  # include unverified eplets for Wiebe risk group
  outputWiebeRiskGroup(recEplets, donAlleles)

makeRequest(epletABCurl, getEpletABC)