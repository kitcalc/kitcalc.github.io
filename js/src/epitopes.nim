import dom, tables, sets, algorithm, htmlgen, strutils
import remoterequest, alleles, eplets, locus


var
  epletsTable: Table[string, Eplet]
  allelesTable: Table[string, Allele]


const
  epletABCurl = "data/epitopes/abc_eplets.txt"
  alleleABCurl = "data/epitopes/abc_alleles.txt"
  epletDRDQurl = "data/epitopes/drdq_eplets.txt"
  alleleDRDQurl = "data/epitopes/drdq_alleles.txt"
  epletDPurl = "data/epitopes/dp_eplets.txt"
  alleleDPurl = "data/epitopes/dp_alleles.txt"

  includeOtherId = "includeOther"

  hvgEpletCountIdTmpl = "hvgEpletCount" # & locus
  hvgMismatchedEpletsIdTmpl = "hvgMismatchedEplets" # & locus


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

  recElements = [
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

  donElements = [
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

  alleleA.sort(system.cmp)
  alleleB.sort(system.cmp)
  alleleC.sort(system.cmp)
  alleleDRB1.sort(system.cmp)
  alleleDRB345.sort(system.cmp)
  alleleDQA1.sort(system.cmp)
  alleleDQB1.sort(system.cmp)
  alleleDPA1.sort(system.cmp)
  alleleDPB1.sort(system.cmp)

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


proc getEplets(elements: array[9, array[2, string]]): HashSet[Eplet] =
  ## Collect all eplets for donor or recipient
  result = initSet[Eplet]()
  for elementGroup in elements:
    for element in elementGroup:
      let allele = $cast[OptionElement](document.getElementById(element)).value
      # skip empty alleles
      if allele != "":
        result.incl allelesTable[allele].eplets

proc outputMismatchedEplets(epletsSet: HashSet[Eplet]) =
  ## Shows the mismatched eplets and the cardinality
  document.getElementById(hvgEpletCountIdTmpl & "Total").innerHtml = $epletsSet.card

  for locus in [ABC, DRB, DQA1, DQB1, DPA1, DPB1]:
    var sortedEplets = newSeq[string]()
    for eplet in epletsSet:
      if eplet.locus == locus:
        sortedEplets.add eplet.name
    sortedEplets.sort(system.cmp)
    document.getElementById(hvgEpletCountIdTmpl & $locus).innerHtml = $len(sortedEplets)
    document.getElementById(hvgMismatchedEpletsIdTmpl & $locus).innerHtml = sortedEplets.join(", ")

proc showMismatchedEplets*() {.exportc.} =
  let
    recEplets = getEplets(recElements)
    donEplets = getEplets(donElements)
    hvgEplets = donEplets - recEplets

  if document.getElementById(includeOtherId).checked:
    # include all eplets
    outputMismatchedEplets(hvgEplets)
  else:
    var otherExcluded = initSet[Eplet]()
    for eplet in hvgEplets:
      if eplet.evidence != epOther:
        otherExcluded.incl eplet
    outputMismatchedEplets(otherExcluded)

makeRequest(epletABCurl, getEpletABC)