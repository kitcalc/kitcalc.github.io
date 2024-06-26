## 2.4.2 Blood Groups [ABO and RhD] [Data Structure 002]

import strutils, htmlgen

type BloodGroupsABORhD* = object
  dataIdentifier: string ##\
    ## =
    ## data identifier, first character
    ## %
    ## data identifier, second character
  aboRhD: string ##\
    ## gg
    ##
    ## EITHER:
    ## • shall specify ABO and RhD blood groups, and type of collection
    ##   information
    ## • shall be encoded and interpreted by reference to Table 4, page 86
    ## OR
    ## shall specify a range of special messages, as shown in Table 5, page 89.
  rhKellMi: string ##\
    ## r
    ##
    ## • shall specify Rh, and Kell or Miltenberger phenotypes
    ## • shall be encoded and interpreted by reference to Table 6, page 90
    ## A value of 0 (zero) shall be used if the data structure does not contain
    ## information about these phenotypes.
  e: string ##\
    ## e
    ##
    ## • shall be reserved for future use
    ## • shall always be set to 0 (zero).

func verifyBloodGroupsABORhD(code: string) =
  ## QC for Data Structure 002, "Blood Groups [ABO and RhD]"

  if code.len != 6:
    raise newException(ValueError,
      "Fel längd: längd 6 förväntades men endast " & $code.len &
      " tecken fanns i koden")


proc parseBloodGroupsABORhD*(code: string): BloodGroupsABORhD =
  ## Parse Data Structure 002, "Blood Groups [ABO and RhD]"

  # qc
  verifyBloodGroupsABORhD(code)

  result.dataIdentifier = code[0..1]  # all as strings
  result.aboRhD = code[2..3]
  result.rhKellMi = code[4..4]
  result.e = code[5..5]


type
  MessageKind = enum
    bloodGroup, specialMessage

  CollectionInformation = enum
    default = "Default: Intended Use Not Specified"
    directed = "Directed (Dedicated/Designated) Collection Use Only"
    emergency = "For Emergency Use Only"
    directedBio = "Directed (Dedicated/Designated) Collection/Biohazardous"
    directedCrossover = "Directed (Dedicated/Designated) Collection/Eligible for Crossover"
    autologousCrossover = "Autologous Collection/Eligible for Crossover"
    autologous = "For Autologous Use Only"
    autologousBio = "For Autologous Use Only/Biohazardous"

  ABORhD = object
    case kind: MessageKind
    of bloodGroup:
      group: string
      collectionInformation: CollectionInformation
    of specialMessage:
      message: string


proc interpretCollectionInformation(bg: BloodGroupsABORhD): CollectionInformation =
  ## Interpret the collection information
  # from table 4

  try:
    let numeric = bg.aboRhD.parseInt
    case numeric
    of 95, 51, 6, 62, 17, 73, 28, 84, 55, 66, 77, 88:
      result = default
    of 91, 47, 2, 58, 13, 69, 24, 80:
      result = directed
    of 92, 48, 3, 59, 14, 70, 25, 81:
      result = emergency
    of 93, 49, 4, 60, 15, 71, 26, 82:
      result = directedBio
    of 94, 50, 5, 61, 16, 72, 27, 83:
      result = directedCrossover
    of 96, 52, 7, 63, 18, 74, 29, 85:
      result = autologousCrossover
    of 97, 53, 8, 64, 19, 75, 30, 86:
      result = autologous
    of 98, 54, 9, 65, 20, 76, 31, 87:
      result = autologousBio
    else: discard
  except ValueError:
    let
      two = bg.aboRhD[1]
    case two
    of '0', '6': result = default
    of '2': result = directed
    of '3': result = emergency
    of '4': result = directedBio
    of '5': result = directedCrossover
    of '7': result = autologousCrossover
    of '8': result = autologous
    of '9': result = autologousBio
    else: discard

  # no exception when value is not found since that cannot happen!


proc interpretABORhD(bg: BloodGroupsABORhD): ABORhD =
  ## Interpret the ABO/RhD blood group string
  # from tables 4 and 5
  var
    group: string
    collect: CollectionInformation

  try:
    let numeric = bg.aboRhD.parseInt
    case numeric
    of 91..98: group = "O RhD neg"
    of 47..54: group = "O RhD pos"
    of 2 .. 9: group = "A RhD neg"
    of 58..65: group = "A RhD pos"
    of 13..20: group = "B RhD neg"
    of 69..76: group = "B RhD pos"
    of 24..31: group = "AB RhD pos"
    of 80..87: group = "AB RhD pos"
    # misc
    of 55: group = "O"
    of 66: group = "A"
    of 77: group = "B"
    of 88: group = "AB"
    else: discard
  except ValueError:
    # non numeric - two is always in range 2-9
    let
      one = bg.aboRhD[0]
      two = bg.aboRhD[1]
    if two in {'2'..'9'}:
      case one
      of 'P': group = "O"
      of 'A': group = "A"
      of 'B': group = "B"
      of 'C': group = "AB"
      of 'D': group = "para-Bombay, RhD neg"
      of 'E': group = "para-Bombay, RhD pos"
      of 'G': group = "Bombay, RhD neg"
      of 'H': group = "Bombay, RhD pos"
      of 'I': group = "O para-Bombay, RhD neg"
      of 'J': group = "O para-Bombay, RhD pos"
      of 'K': group = "A para-Bombay, RhD neg"
      of 'L': group = "B para-Bombay, RhD neg"
      of 'M': group = "AB para-Bombay, RhD neg"
      of 'N': group = "A para-Bombay, RhD pos"
      of 'O': group = "B para-Bombay, RhD pos"
      of 'Q': group = "AB para-Bombay, RhD pos"
      else: discard
    elif two == '0':
      case one
      of 'A': group = "Grupp A, pooled RhD"
      of 'B': group = "Grupp B, pooled RhD"
      of 'C': group = "Grupp AB, pooled RhD [Pooled Products]"
      of 'D': group = "Grupp O, pooled RhD"
      of 'E': group = "Pooled ABO, RhD pos"
      of 'F': group = "Pooled ABO, RhD neg"
      of 'G': group = "Pooled ABO, pooled RhD"
      of 'H': group = "Pooled ABO (RhD not specified)"
      of 'I': group = "A1"
      of 'J': group = "A2"
      of 'K': group = "A<sub>1</sub>B"
      of 'L': group = "A<sub>2</sub>B"
      else: discard

  # if we got this far and have a group, assign kind
  if group.len > 0:
    collect = interpretCollectionInformation(bg)
    return ABORhD(kind: bloodGroup, group: group, collectionInformation: collect)
  # else try with special messages
  else:
    case bg.aboRhD
    of "00": group = "No ABO or Rh information is available"
    of "Ma": group = "Autologous collection"
    of "Mb": group = "Biohazardous"
    of "Md": group = "Discard (to be destroyed)"
    of "Mf": group = "For fractionation use only"
    of "Mq": group = "Quarantine/hold for further testing or processing"
    of "Mr": group = "For research use only"
    of "Mx": group = "Not for transfusion based on test results"
    # Values in Table 5 that begin with the letter T (T1-T6) shall be used only with tissue products.
    of "T1": group = "ABO not specified, RhD positive"
    of "T2": group = "ABO not specified, RhD negative"
    of "T3": group = "ABO not specified, RhD not specified"
    of "T4": group = "Autologous collection/in quarantine"
    of "T5": group = "See outer packaging for product status"
    of "T6": group = "Must be sterilized before release"
    else: discard

    if group.len > 0:
      return ABORhD(kind: specialMessage, message: group)

  if group == "":
    raise newException(ValueError,
      "kunde inte tolka blodgrupp för: '" & bg.aboRhD & "'")

type
  PhenoKind = enum
    rhK, mi, special
  Phenotype = enum
    pos = "+"
    neg = "−"  # minus sign
    noInfo = "?",
    unknown
  RhKellMi = object
    case kind: PhenoKind
    of rhK:
      kell: Phenotype
      rhC: Phenotype
      rhsmallc: Phenotype
      rhE: Phenotype
      rhsmalle: Phenotype
    of mi:
      mipheno: Phenotype
    of special:
      discard

proc interpretKell(bg: BloodGroupsABORhD): Phenotype =
  ## Interpret Kell phenotype
  case bg.rhKellMi[0]
  of '0'..'9', 'X': result = noInfo
  of 'S', 'A'..'I', 'Y': result = neg
  of 'T', 'J'..'R', 'Z': result = pos
  of 'U'..'W': result = unknown
  else:
    raise newException(ValueError, "okänt värde för Kell: '" & bg.rhKellMi & "'")

proc interpretRh(bg: BloodGroupsABORhD): array[4, Phenotype] =
  ## Interpret Rh phenotype
  case bg.rhKellMi[0]
  of '0', 'S', 'T': result = [noInfo, noInfo, noInfo, noInfo]
  of '1', 'A', 'J': result = [neg, pos, neg, pos]
  of '2', 'B', 'K': result = [pos, pos, neg, pos]
  of '3', 'C', 'L': result = [pos, pos, pos, pos]
  of '4', 'D', 'M': result = [pos, pos, pos, neg]
  of '5', 'E', 'N': result = [neg, pos, pos, pos]
  of '6', 'F', 'O': result = [neg, pos, pos, neg]
  of '7', 'G', 'P': result = [pos, neg, neg, pos]
  of '8', 'H', 'Q': result = [pos, neg, pos, pos]
  of '9', 'I', 'R': result = [pos, neg, pos, neg]
  of 'X', 'Y', 'Z': result = [neg, noInfo, neg, noInfo]
  else:
    raise newException(ValueError, "okänt värde för Rh: '" & bg.rhKellMi & "'")


proc interpretMi(bg: BloodGroupsABORhD): Phenotype =
  ## Interpret Mi phenotype
  if bg.rhKellMi == "U": result = neg
  elif bg.rhKellMi == "V": result = pos


proc interpretRhKellMi(bg: BloodGroupsABORhD): RhKellMi =
  ## Interpret Rh, Kell, Mia/Mur phenotypes
  # shortcut "special"
  if bg.rhKellMi == "W":
    return RhKellMi(kind: special)
  let kell = interpretKell(bg)
  if kell != unknown:
    let rh = interpretRh(bg)
    result = RhKellMi(
      kind: rhK, kell: kell, rhC: rh[0], rhsmallc: rh[1], rhE: rh[2], rhsmalle: rh[3]
    )
  else:
    let mi = interpretMi(bg)
    result = RhKellMi(kind: mi, mipheno: mi)


proc toHtml*(bg: BloodGroupsABORhD): string =
  ## Show information about `bg` as HTML
  const style = "padding-left: 1em;"
  let
    aboRhD = interpretABORhD(bg)
    rhKellMi = interpretRhKellMi(bg)

  var aboRows = tr(
    td("ABO och RhD-Kod"),
    td(bg.aboRhD)
  )
  if aboRhD.kind == bloodGroup:
    aboRows.add tr(
      td("ABO och RhD", style=style),
      td(aboRhD.group)
    )
    aboRows.add tr(
      td("Tappningstyp", style=style),
      td($aboRhD.collectionInformation)
    )
  else:
    aboRows.add tr(
      td("Meddelande", style=style),
      td(aboRhD.message)
    )

  var phenoRows = tr(
    td("Fenotypskod"),
    td(bg.rhKellMi)
  )
  case rhKellMi.kind
  of rhK:
    let phenoString = ("K" & $rhKellMi.kell & " C" & $rhKellMi.rhC & " c" &
      $rhKellMi.rhsmallc & " E" & $rhKellMi.rhE & " e" & $rhKellMi.rhsmalle)
    phenoRows.add tr(
      td("Fenotyp (Rh/K)", style=style),
      td(phenoString)
    )
  of mi:
    phenoRows.add tr(
      td("Fenotyp (Mi<sup>a</sup>/Mur)", style=style),
      td($rhKellMi.mipheno)
    )
  of special:
    phenoRows.add tr(
      td("Fenotyp (okänd)", style=style),
      td("Special Testing bar code present and must be scanned and interpreted")
    )

  let
    head = thead(
      tr(
        th("Element"),
        th("Värde")
      )
    )
    body = tbody(
      aboRows,
      phenoRows,
      tr(
        td("e"),
        td(bg.e)
      )
    )

  result.add table(head, body)
