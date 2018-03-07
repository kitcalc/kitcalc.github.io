import dom, tables, sets, algorithm, htmlgen, strutils
import remoterequest, alleles, eplets


var
  epletABC: Table[string, Eplet]
  alleleABC: Table[string, Allele]

const
  epletABCurl = "data/epitopes/abc_eplets.txt"
  alleleABCurl = "data/epitopes/abc_alleles.txt"

  includeOtherId = "includeOther"
  hvgEpletCountId = "hvgEpletCount"
  hvgMismatchedEpletsId = "hvgMismatchedEplets"

  recElementsA = ["recA1", "recA2"]
  recElementsB = ["recB1", "recB2"]
  recElementsC = ["recC1", "recC2"]

  donElementsA = ["donA1", "donA2"]
  donElementsB = ["donB1", "donB2"]
  donElementsC = ["donC1", "donC2"]

proc fillSelect() =
  ## Fill select elements with alleles

  var
    alleleA = newSeq[string]()
    alleleB = newSeq[string]()
    alleleC = newSeq[string]()
  for allele in alleleABC.keys:
    case allele[0]
    of 'A': alleleA.add allele
    of 'B': alleleB.add allele
    of 'C': alleleC.add allele
    else:
      echo "unknown locus in allele ", allele

  alleleA.sort(system.cmp)
  alleleB.sort(system.cmp)
  alleleC.sort(system.cmp)

  var alleleList = ""

  for allele in alleleA:
    alleleList &= option(value=allele, allele) & "\n"

  for element in recElementsA:
    document.getElementById(element).innerHtml = alleleList
  for element in donElementsA:
    document.getElementById(element).innerHtml = alleleList

  alleleList = ""

  for allele in alleleB:
    alleleList &= option(value=allele, allele) & "\n"

  for element in recElementsB:
    document.getElementById(element).innerHtml = alleleList
  for element in donElementsB:
    document.getElementById(element).innerHtml = alleleList

  alleleList = ""

  for allele in alleleC:
    alleleList &= option(value=allele, allele) & "\n"

  for element in recElementsC:
    document.getElementById(element).innerHtml = alleleList
  for element in donElementsC:
    document.getElementById(element).innerHtml = alleleList


proc getAlleleABC(data: cstring) =
  ## Parse and initialize eplets table
  alleleABC = readAlleles($data, epletABC)
  echo "alleles loaded from '", alleleABCurl, "'"
  fillSelect()


proc getEpletABC(data: cstring) =
  ## Parse and initialize eplets table
  epletABC = readEplets($data)
  echo "eplets loaded from '", epletABCurl, "'"
  makeRequest(alleleABCurl, getAlleleABC)


proc getEplets(elementsA, elementsB, elementsC: array[2, string]): HashSet[Eplet] =
  ## Collect all eplets for donor or recipient
  result = initSet[Eplet]()
  for element in elementsA:
    let allele = $cast[OptionElement](document.getElementById(element)).value
    result.incl alleleABC[allele].eplets
  for element in elementsB:
    let allele = $cast[OptionElement](document.getElementById(element)).value
    result.incl alleleABC[allele].eplets
  for element in elementsC:
    let allele = $cast[OptionElement](document.getElementById(element)).value
    result.incl alleleABC[allele].eplets

proc outputMismatchedEplets(eplets: HashSet[Eplet]) =
  ## Shows the mismatched eplets and the cardinality
  document.getElementById(hvgEpletCountId).innerHtml = $eplets.card
  var sortedEplets = newSeq[string]()
  for eplet in eplets:
    sortedEplets.add eplet.name
  sortedEplets.sort(system.cmp)
  document.getElementById(hvgMismatchedEpletsId).innerHtml = sortedEplets.join(", ")

proc showMismatchedEplets*() {.exportc.} =
  let
    recEplets = getEplets(recElementsA, recElementsB, recElementsC)
    donEplets = getEplets(donElementsA, donElementsB, donElementsC)
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
