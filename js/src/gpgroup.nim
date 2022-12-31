import strutils, tables
import dom, htmlgen

type
  Sero = enum
    missing = "saknas"
    unambiguous = "Unambiguous"
    possible = "Possible"
    assumed = "Assumed"
    expert = "Expert assigned"

  Antigen = object
    kind: Sero
    isExpert: bool
    antigen: string
    expertAntigen: string

  Relation = enum
    splitOf = " är en split av "
    associated = " är associerat med "

  Split = object
    kind: Relation
    broad: string

# global tables
var
  galleles = initTable[string, string]()
  ggroups = initTable[string, seq[string]]()
  palleles = initTable[string, string]()
  pgroups = initTable[string, seq[string]]()
  alleleIDs = initTable[string, string]()
  serological = initTable[string, Antigen]()
  splits = initTable[string, Split]()


proc outputMeta(line: string) =
  let
    fields = line.split(": ", maxsplit=1)
    key = fields[0][2 ..< fields[0].len]  # remove leading "# "
    value = fields[1]
  echo key, spaces(20-key.len), value

proc parseGroup*(data: string, alleles: var Table[string, string],
  groups: var Table[string, seq[string]]) {.exportc.} =

  var fields = newSeq[string]()

  for line in splitLines(data):
    if line.startsWith('#'):
      outputMeta(line)
      continue

    # parse data rows
    fields = line.split(';')
    if fields.len < 3:
      continue
    let
      locus = fields[0]
      members = fields[1].split('/')
      group = if fields[2].len == 0:
          locus & members[0]
        else:
          locus & fields[2]

    groups[group] = newSeqOfCap[string](members.len)
    for allele in members:
      let name = locus & allele
      alleles[name] = group
      groups[group].add name


proc initGgroupData*(gdata: cstring) {.exportc.} =
  ## Load data into tables, to be used as callback
  parseGroup($gdata, galleles, ggroups)
  # The only alleles in G but not in P are the null alleles (feb 2018)

proc initPgroupData*(pdata: cstring) {.exportc.} =
  ## Load data into tables, to be used as callback
  parseGroup($pdata, palleles, pgroups)
  # These are the only alleles in P but not in G (as of feb 2018):
  #
  # DRA*01:01:01:01, DRA*01:02:03, DRA*01:02:02, DRA*01:01:01:03,
  # DRA*01:01:01:02, DRA*01:01:02, DRA*01:02:01

proc initAlleleIdData*(alleleData: cstring) {.exportc.} =
  ## Load data into allele ID table
  # File format:
  #
  #  # author: Steven G. E. Marsh (steven.marsh@ucl.ac.uk)
  #  AlleleID,Allele
  #  HLA00001,A*01:01:01:01

  var fields: seq[string]

  for line in splitLines($alleleData):
    if line.startsWith('#'):
      outputMeta(line)
      continue
    if line.startsWith("AlleleID"):
      continue
    fields = line.split(',')
    if fields.len != 2:
      continue
    # allele as key, allele ID as value
    alleleIDs[fields[1]] = fields[0]


func antigenPrefix(locus: string): string =
  # These are the loci where antigens are available
  case locus
  of "A", "B": locus
  of "C": "Cw"
  of "DRB1", "DRB3", "DRB4", "DRB5": "DR"
  of "DQB1": "DQ"
  else: ""


func parseAntigen(fields: seq[string]): Antigen =
  let
    locus = fields[0].strip(chars={'*'}, leading=false)  # strip asterisk
    prefix = antigenPrefix(locus)  # DRB1 to DR etc
    isExpert = fields[5].len != 0

  # look through available fields
  for field in [2, 3, 4]:
    if fields[field] != "":
      let ag = fields[field]
      let compound = case ag
        of "0": "(nullallel)"
        of "0/?": "(nullallel/oklart)"
        of "?": "oklart"
        else:
          if '/' in ag:
            var ags = ag.split('/')
            for a in ags.mitems:
              case a
              of "0": a = "null"
              of "?": a = "oklart"
              else: a = prefix & a
            ags.join("/")
          else:
            prefix & ag

      let kind = Sero(field - 1)  # careful, must sync fields with enum

      return Antigen(kind: kind, isExpert: isExpert, antigen: compound,
        expertAntigen: prefix & fields[5])

  assert false, "no antigen found!"

proc initSerologicalData*(seroData: cstring) {.exportc.} =
  ## Load data into serological data table
  # This file includes six fields of information, each separated by a
  # semi-colon (;).
  #
  # - HLA Locus
  # - HLA Allele Name
  # - Unambiguous Serological Antigen associated with allele
  # - Possible Serological Antigen associated with allele
  # - Assumed Serological Antigen associated with allele
  # - Expert assigned exceptions in search determinants of some registries
  #
  # # author: WHO, Steven G. E. Marsh (steven.marsh@ucl.ac.uk)
  # A*;43:01;43;;;
  # A*;01:01:01:02N;0;;;
  # A*;66:01:01:01;66;;;26/34
  var fields: seq[string]
  for line in splitLines($serodata):
    if line.startsWith('#'):
      outputMeta(line)
      continue
    fields = line.strip.split(';')
    if fields.len != 6:
      # should never happen
      continue

    let
      antigen = parseAntigen(fields)
      allele = fields[0] & fields[1]  # "A*" & "43:01"
    serological[allele] = antigen


proc parseSplits(fields: seq[string]) =
  # A;2;;203/210    # relation
  # A;9;23/24;      # split
  let
    locus = fields[0]
    broad = locus & fields[1]
  if fields[2] != "":
    for ag in fields[2].split('/'):
      splits[locus & ag] = Split(kind: splitOf, broad: broad)
  if fields[3] != "":
    for ag in fields[3].split('/'):
      splits[locus & ag] = Split(kind: associated, broad: broad)
  echo splits


proc initSplitData*(data: cstring) {.exportc.} =
  ## Load serological relations data
  # File format
  # - HLA Locus
  # - HLA Antigen name
  # - Split Antigen
  # - Associated Antigen
  var fields: seq[string]
  for line in splitLines($data):
    if line.startsWith('#'):
      outputMeta(line)
      continue
    fields = line.strip.split(';')
    if fields.len != 4:
      # should never happen
      continue
    parseSplits(fields)


template infoLink(allele: string): string =
  ## Create a link to the HLA dictionary
  let alleleID = alleleIDs[allele]
  # use the allele as link text, but link to alleleID
  a(href="https://www.ebi.ac.uk/ipd/imgt/hla/alleles/allele/?accession=" & alleleID, allele)


template valueFromInput(elementId: string): string =
  $cast[OptionElement](document.getElementById(elementId)).value

proc setInnerHtml(elementId, value: string) =
  document.getElementById(elementId.cstring).innerHtml = value.cstring

proc clearForm() =
  setInnerHtml("alleleinfo", "")
  setInnerHtml("helptext", "")
  setInnerHtml("pgroup", "")
  setInnerHtml("pgrouplen", "")
  setInnerHtml("pother", "")
  setInnerHtml("ggroup", "")
  setInnerHtml("ggrouplen", "")
  setInnerHtml("gother", "")
  setInnerHtml("serokind", "")
  setInnerHtml("seroantigen", "")

proc help(html: string) =
  setInnerHtml("helptext", "<br>\n" & html)

proc lookForAlternateAllele(allele: string) =
  # clear before we continue
  clearForm()

  # leta kandidater med samma start
  const maxresults = 10
  var cand = newSeq[string]()
  for key in alleleIDs.keys:
    if key.startsWith(allele):
      cand.add key
      if cand.len > maxresults:
        break
  if cand.len > 0:
    help("Mer specifik fråga behövs, ange t.ex. någon av:<br>\n$#\n<br>$#" % [
      cand.join("<br>\n"), if cand.len > maxresults: "..." else: ""])
    return

  # sista utvägen
  help("Okänd allel, ange alleler som t.ex. A*01:01:01:01")

proc lookupAllele() {.exportc.} =
  ## Lookup an allele and put data into HTML elements
  let allele = valueFromInput("allele").toUpperAscii.strip

  # info
  if allele in galleles or allele in palleles or allele in alleleIDs:
    clearForm()
    setInnerHtml("alleleinfo", infoLink(allele))
  else:
    lookForAlternateAllele(allele)
    return

  # P-alleles
  if allele in palleles:
    let pgroup = palleles[allele]
    setInnerHtml("pgroup", pgroup)
    setInnerHtml("pgrouplen", $pgroups[pgroup].len)

    # create links to other alleles
    var alleleLinks = newSeq[string]()
    for otherAllele in pgroups[pgroup]:
      alleleLinks.add infoLink(otherAllele)
    setInnerHtml("pother", alleleLinks.join(" "))

  # G-alleles
  if allele in galleles:
    let ggroup = galleles[allele]
    setInnerHtml("ggroup", ggroup)
    setInnerHtml("ggrouplen", $ggroups[ggroup].len)

    # create links to other alleles
    var alleleLinks = newSeq[string]()
    for otherAllele in ggroups[ggroup]:
      alleleLinks.add infoLink(otherAllele)
    setInnerHtml("gother", alleleLinks.join(" "))

  if allele in serological:
    let antigen = serological[allele]
    var splitString = ""
    if antigen.antigen in splits:
      let split = splits[antigen.antigen]
      splitString = br() & antigen.antigen & $split.kind & split.broad
    if antigen.isExpert:
      setInnerHtml("serokind",
        $antigen.kind & " (med \"expert assigned\" tillägg)"
      )
      setInnerHtml("seroantigen",
        antigen.antigen & " (expert " & antigen.expertAntigen & ")" & splitString
      )
    else:
      setInnerHtml("serokind", $antigen.kind)
      setInnerHtml("seroantigen", antigen.antigen & splitString)


when false:
  ## Example CLI, requires parsegroup only

  import httpclient, os

  const urlG = "https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/wmda/hla_nom_g.txt"
  const urlP = "https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/wmda/hla_nom_p.txt"

  proc getRemoteFile(url: string): string =
    var client = newHttpClient()
    return client.getContent(url)

  proc main() =
    if paramCount() < 1:
      quit("usage: " & getAppFileName() & " allele [allele ...]")

    let gdata = getRemoteFile(urlG)
    var
      galleles = initTable[string, string]()
      ggroups = initTable[string, seq[string]]()
    parseGroup(gdata, galleles, ggroups)

    let pdata = getRemoteFile(urlP)
    var
      palleles = initTable[string, string]()
      pgroups = initTable[string, seq[string]]()
    parseGroup(pdata, palleles, pgroups)

    for allele in commandLineParams():
      echo ""
      if allele in galleles and allele in palleles:
        let
          ggroup = galleles[allele]
          gother = ggroups[ggroup]
          pgroup = palleles[allele]
          pother = pgroups[pgroup]
        echo("Allele $# is in G group $# along with\n$#\nand in P group $# along with\n$#\n" %
             [allele, ggroup, join(gother, ", "), pgroup, join(pother, ", ")])
      else:
        echo "allele ", allele, " is not in a G- and P-group"

  main()
