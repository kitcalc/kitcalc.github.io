import dom
import jsutils

# JsTable _must_ be explicitly initialized before usage (with newJsTable)
# unlike ordinary Nim tables!

type
  Sero = enum
    missing
    unambiguous
    possible
    assumed
    expert

  Antigen = object
    kind: Sero
    isExpert: bool
    antigen: cstring
    expertAntigen: cstring

  Relation = enum
    splitOf
    associated

  Split = object
    kind: Relation
    broad: cstring

  TableResult = tuple
    alleles: JsTable[cstring, cstring]
    groups: JsTable[cstring, seq[cstring]]

const strSero: array[Sero, cstring] =[
  "saknas".cstring,
  "Unambiguous",
  "Possible",
  "Assumed",
  "Expert assigned"
]

const strRelation: array[Relation, cstring] = [
  " är en split av ".cstring,
  " är associerat med "
]

# https://hla.alleles.org/antigens/bw46.html
# "The following specificities are generally agreed inclusions of HLA epitopes
# Bw4 and Bw6."
const Bw4 = [
    "A9".cstring, "A23", "A24", "A2403", "A25", "A32",

    "B5", "B5102", "B5103", "B13", "B17", "B27", "B37", "B38", "B44", "B47",
    "B49", "B51", "B52", "B53", "B57", "B58", "B59", "B63", "B77"
]

const Bw6 = [
    "B7".cstring, "B703", "B8", "B14", "B18", "B22", "B2708", "B35", "B39",
    "B3901", "B3902", "B40", "B4005", "B41", "B42", "B45", "B46", "B48", "B50",
    "B54", "B55", "B56", "B60", "B61", "B62", "B64", "B65", "B67", "B70",
    "B71", "B72", "B73", "B75", "B76", "B78", "B81", "B82"
]


# global tables
var
  galleles = newJsTable[cstring, cstring]()
  ggroups = newJsTable[cstring, seq[cstring]]()
  palleles = newJsTable[cstring, cstring]()
  pgroups = newJsTable[cstring, seq[cstring]]()
  alleleIDs = newJsTable[cstring, cstring]()
  serological = newJsTable[cstring, Antigen]()
  splits = newJsTable[cstring, Split]()
  broads = newJsTable[cstring, cstring]()

proc outputMeta(line: cstring) =
  echo line

proc parseGroup*(data: cstring): TableResult {.exportc.} =
  var fields: seq[cstring]
  result.alleles = newJsTable[cstring, cstring]()
  result.groups = newJsTable[cstring, seq[cstring]]()

  for line in data.split("\n"):
    if line.startsWith("#"):
      outputMeta(line)
      continue

    # parse data rows
    fields = line.split(";")

    if fields.len < 3:
      continue
    let
      locus = fields[0]
      members = fields[1].split("/")
      group = if fields[2].len == 0:
          locus & members[0]
        else:
          locus & fields[2]

    var memberlist: seq[cstring]
    for allele in members:
      let name = locus & allele
      result.alleles[name] = group
      memberlist.add name
    result.groups[group] = memberlist


proc initGgroupData*(gdata: cstring) {.exportc.} =
  ## Load data into tables, to be used as callback
  let data = parseGroup(gdata)
  galleles = data.alleles
  ggroups = data.groups
  # The only alleles in G but not in P are the null alleles (feb 2018)

proc initPgroupData*(pdata: cstring) {.exportc.} =
  ## Load data into tables, to be used as callback
  (palleles, pgroups) = parseGroup(pdata)
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

  var fields: seq[cstring]

  for line in alleleData.split("\n"):
    if line.startsWith("#"):
      outputMeta(line)
      continue
    if line.startsWith("AlleleID"):
      continue
    fields = line.split(",")
    if fields.len != 2:
      continue
    # allele as key, allele ID as value
    alleleIDs[fields[1]] = fields[0]


proc antigenPrefix(locus: cstring): cstring =
  # These are the loci where antigens are available
  # Can't case..of on cstring
  result = ""
  if locus == "A" or locus == "B":
    result = locus
  elif locus == "C":
    result = "Cw"
  elif locus in ["DRB1".cstring, "DRB3", "DRB4", "DRB5"]:
    result = "DR"
  elif locus == "DQB1":
    result = "DQ"


proc parseAntigen(fields: seq[cstring]): Antigen =
  let
    locus = if fields[0].endsWith("*"):
        fields[0].substr(0, fields[0].len - 1)
      else:
        fields[0]
    prefix = antigenPrefix(locus)  # DRB1 to DR etc
    isExpert = fields[5].len != 0

  # look through available fields
  for field in [2, 3, 4]:
    if fields[field] != "":
      let ag = fields[field]

      var compound: cstring

      # parse compound antigen strings
      if ag == "0":
        compound = "(nullallel)"
      elif ag == "0/?":
        compound = "(nullallel/oklart)"
      elif ag == "?":
        compound = "oklart"
      elif "/" in ag:
        # several possibilities, mixed null/actual
        let ags = ag.split("/")
        for i, a in ags:
          if a == "0":
            compound.add "null"
          elif a == "?":
            compound.add "oklart"
          else:
            compound.add(prefix & a)
          if i < ags.len - 1:
            compound.add "/"
      else:
        # give up
        compound = prefix & ag

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
  var fields: seq[cstring]
  for line in serodata.split("\n"):
    if line.startsWith("#"):
      outputMeta(line)
      continue
    fields = line.strip.split(";")
    if fields.len != 6:
      # should never happen
      continue

    let
      antigen = parseAntigen(fields)
      allele = fields[0] & fields[1]  # "A*" & "43:01"
    serological[allele] = antigen


proc parseSplits(fields: seq[cstring]) =
  # A;2;;203/210    # relation
  # A;9;23/24;      # split
  let
    locus = fields[0]
    broad = locus & fields[1]
  if fields[2] != "":
    for ag in fields[2].split("/"):
      splits[locus & ag] = Split(kind: splitOf, broad: broad)
  if fields[3] != "":
    for ag in fields[3].split("/"):
      splits[locus & ag] = Split(kind: associated, broad: broad)


proc initSplitData*(data: cstring) {.exportc.} =
  ## Load serological relations data
  # File format
  # - HLA Locus
  # - HLA Antigen name
  # - Split Antigen
  # - Associated Antigen
  var fields: seq[cstring]
  for line in data.split("\n"):
    if line.startsWith("#"):
      outputMeta(line)
      continue
    fields = line.strip.split(";")
    if fields.len != 4:
      # should never happen
      continue
    parseSplits(fields)

  # add broads
  for split in splits.keys:
    let broad = splits[split].broad
    if broad notin broads:
      broads[broad] = split
    else:
      broads[broad] = broads[broad] & ", " & split


template infoLink(allele: cstring): cstring =
  ## Create a link to the HLA dictionary
  let alleleID = alleleIDs[allele]
  # use the allele as link text, but link to alleleID
  a(href="https://www.ebi.ac.uk/ipd/imgt/hla/alleles/allele/?accession=" & alleleID, allele)


template valueFromInput(elementId: cstring): cstring =
  cast[OptionElement](document.getElementById(elementId)).value

proc setInnerHtml(elementId, value: cstring) =
  document.getElementById(elementId).innerHtml = value

template fillInput(value: cstring): cstring =
  ## Set `allele` input text to value
  const action = """document.getElementById("allele").innerHtml=this.innerHTML""".cstring
  "<span onclick='javascript:".cstring &
    action & "'>".cstring &
    value & "</span>".cstring

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

proc help(html: cstring) =
  setInnerHtml("helptext", "<br>\n" & html)

proc lookForAlternateAllele(allele: cstring) =
  # clear before we continue
  clearForm()

  # leta kandidater med samma start
  const maxresults = 10
  var cands: seq[cstring]
  for key in alleleIDs.keys:
    if key.startsWith(allele):
      cands.add key
      if cands.len > maxresults:
        break
  if cands.len > 0:
    var helpstring: cstring = "Mer specifik fråga behövs, ange t.ex. någon av:<br>\n"
    for cand in cands:
      helpstring.add(fillInput(cand) & "<br>\n")
    if cands.len > maxresults:
      helpstring.add "..."
    help(helpstring)
    return

  # sista utvägen
  help("Okänd allel, ange alleler som t.ex. A*01:01:01:01")

proc outputPgroup(allele: cstring) =
  # Output P-groups
  let pgroup = palleles[allele]
  setInnerHtml("pgroup", pgroup)
  setInnerHtml("pgrouplen", pgroups[pgroup].len.toCstr)

  # create links to other alleles
  var alleleLinks: seq[cstring]
  for otherAllele in pgroups[pgroup]:
    alleleLinks.add infoLink(otherAllele)
  var joined: cstring
  for i, link in alleleLinks:
    joined.add link
    if i < allelelinks.len - 1:
      joined.add " "
  setInnerHtml("pother", joined)

proc outputGgroup(allele: cstring) =
  # Output G-group
  let ggroup = galleles[allele]
  setInnerHtml("ggroup", ggroup)
  setInnerHtml("ggrouplen", ggroups[ggroup].len.toCstr)

  # create links to other alleles
  var alleleLinks: seq[cstring]
  for otherAllele in ggroups[ggroup]:
    alleleLinks.add infoLink(otherAllele)
  var joined: cstring
  for i, link in alleleLinks:
    joined.add link
    if i < allelelinks.len - 1:
      joined.add " "
  setInnerHtml("gother", joined)

func evidAbbr(evidence: cstring): cstring =
  const
    front = "<abbr title=\"unambiguous > possible > assumed > expert assigned\">"
    back = "</abbr>"
  result = front & evidence & back

proc outputSerological(allele: cstring) =
  let bwlink = a("https://hla.alleles.org/antigens/bw46.html", "källa")
  let antigen = serological[allele]
  var
    evidenceStr = evidabbr strSero[antigen.kind]
    antigenStr = antigen.antigen

  if antigen.isExpert:
    evidenceStr.add " (med \"expert assigned\" tillägg)"
    antigenStr.add " (expert " & antigen.expertAntigen & ")"

  if antigen.antigen in splits:
    let
      split = splits[antigenStr]
      relation = strRelation[split.kind]
    antigenStr.add br() & antigen.antigen
    antigenStr.add relation & split.broad
  elif antigen.antigen in broads:
    antigenStr.add br() & antigen.antigen
    antigenStr.add " kan splittas i " & broads[antigen.antigen]

  if antigen.antigen in Bw4:
    antigenStr.add br() & antigen.antigen & " bär Bw4 (" & bwlink & ")"
  elif antigen.antigen in Bw6:
    antigenStr.add br() & antigen.antigen & " bär Bw6 (" & bwlink & ")"

  setInnerHtml("serokind", evidenceStr)
  setInnerHtml("seroantigen", antigenStr)


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
    outputPgroup(allele)

  # G-alleles
  if allele in galleles:
    outputGgroup(allele)

  # Sero stuff
  if allele in serological:
    outputSerological(allele)
