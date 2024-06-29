## 2.4.13 Special Testing: Red Blood Cell Antigens—Finnish

import htmlgen, strutils
import common

type SpecialTestingAntigensFinnish* = object
  dataIdentifier: string ##\
    ## &
    ## data identifier, first character
    ## \
    ## data identifier, second character
  aaaaaaaaaaaaaaaa: string ##\
    ## The eighteen (18)-character data content string, aaaaaaaaaaaaaaaaii,
    ## shall be encoded and interpreted using Table 10, starting on page 97, ...
  ii: string ##\
    ## ... and Table 13, page 101.
    ##
    ## If there are red blood cell antigen test results that cannot be encoded
    ## using Table 10 or Table 13, positions 17 and 18 may be set to 00 (see
    ## Table 13), and information concerning the status of those antigens may
    ## be indicated in the label text. Alternatively, red blood cell antigens
    ## not found in these tables may be encoded using the Red Cell Antigens
    ## with Test History (Data Structure 030). For information on this data
    ## structure, see Section 2.4.30, page 67.

func verifySpecialTestingAntigensFinnish(code: string) =
  ## QC for Data Structure 013, "Special Testing: Red Blood Cell Antigens—Finnish"
  if code.len != 20:
    raise newException(ValueError,
      "Fel längd: längd 20 förväntades men " & $code.len &
      " tecken fanns i koden")

proc parseSpecialTestingAntigensFinnish*(code: string): SpecialTestingAntigensFinnish =
  ## Parse Data Structure 013, "Special Testing: Red Blood Cell Antigens—Finnish"
  verifySpecialTestingAntigensFinnish(code)

  result.dataIdentifier = code[0..1]
  result.aaaaaaaaaaaaaaaa = code[2..17]
  result.ii = code[18..19]


type
  Phenotype = enum
    pos = "+",
    neg = "−"  # minus symbol
    ni = "ingen info"
    nt = "ej testad"

  PhenoPair = tuple
    name: string
    pheno: Phenotype

  ValueRange = range['0'..'9']

# Table 10, the antigen not part of RhCcEe
const
  antigens = [
    "K",
    "k",
    "C<sup>w</sup>",
    "Mi<sup>a</sup>",
    "M",
    "N",
    "S",
    "s",
    "U",
    "P1",
    "Lu<sup>a</sup>",
    "Kp<sup>a</sup>",
    "Le<sup>a</sup>",
    "Le<sup>b</sup>",
    "Fy<sup>a</sup>",
    "Fy<sup>b</sup>",
    "Jk<sup>a</sup>",
    "Jk<sup>b</sup>",
    "Do<sup>a</sup>",
    "Do<sup>b</sup>",
    "C<sup>x</sup>",
    "Co<sup>b</sup>",
    "WES<sup>a</sup>",
    "LW<sup>b</sup>",
    "Ul<sup>a</sup>",
    "Ls<sup>a</sup>",
    "An<sup>a</sup>",
    "res",
    "res",
    "CMV-ak"
  ]

  phenoOne: array[ValueRange, Phenotype] = [
    nt, nt, nt, neg, neg, neg, pos, pos, pos, ni
  ]
  phenoTwo: array[ValueRange, Phenotype] = [
    nt, neg, pos, nt, neg, pos, nt, neg, pos, ni
  ]

proc parseRh(value: ValueRange): array[4, PhenoPair] =
  ## Parse the Rh haplotypes
  case value
  of '0':
    result = [("C", pos), ("c", neg), ("E", pos), ("e", neg)]
  of '1':
    result = [("C", pos), ("c", pos), ("E", pos), ("e", neg)]
  of '2':
    result = [("C", neg), ("c", pos), ("E", pos), ("e", neg)]
  of '3':
    result = [("C", pos), ("c", neg), ("E", pos), ("e", pos)]
  of '4':
    result = [("C", pos), ("c", pos), ("E", pos), ("e", pos)]
  of '5':
    result = [("C", neg), ("c", pos), ("E", pos), ("e", pos)]
  of '6':
    result = [("C", pos), ("c", neg), ("E", neg), ("e", pos)]
  of '7':
    result = [("C", pos), ("c", pos), ("E", neg), ("e", pos)]
  of '8':
    result = [("C", neg), ("c", pos), ("E", neg), ("e", pos)]
  of '9':
    result = [("C", ni), ("c", ni), ("E", ni), ("e", ni)]

proc parseAntigen(spec: SpecialTestingAntigensFinnish): seq[PhenoPair] =
  ## Parse the antigens, returns a seq of phenotype strings

  var agIndex = antigens.low

  for i, a in spec.aaaaaaaaaaaaaaaa:
    # i is the 0-indexed position in string
    # a is the value ('0'..'9')

    if i == 0:
      # Rh haplotypes
      result.add parseRh(a)
      continue

    # take two antigens per positional value, from different tables
    result.add (antigens[agIndex], phenoOne[a])
    inc agIndex
    result.add (antigens[agIndex], phenoTwo[a])
    inc agIndex

# Table 13
const antigenNegativ: array[100, string] = [
  "information elsewhere",  #  0
  "En<sup>a</sup>",  #  1
  "’N’",  #  2
  "V<sup>w</sup>",  #  3
  "Mur",  #  4
  "Hut",  #  5
  "Hil",  #  06":
  "P",  #  7
  "PP<sub>1</sub>P<sup>k</sup>",  #  8
  "hr<sup>S</sup>",  #  9
  "hr<sup>B</sup>",  #  10
  "f",  #  11
  "Ce",  #  12
  "G",  #  13
  "Hr<sub>0</sub>",  #  14
  "CE",  #  15
  "cE",  #  16
  "C<sup>x</sup>",  #  17
  "E<sup>w</sup>",  #  18
  "D<sup>w</sup>",  #  19
  "hr<sup>H</sup>",  #  20
  "Go<sup>a</sup>",  #  21
  "Rh32",  #  22
  "Rh33",  #  23
  "Tar",  #  24
  "Kp<sup>b</sup>",  #  25
  "Kp<sup>c</sup>",  #  26
  "Js<sup>b</sup>",  #  27
  "Ul<sup>a</sup>",  #  28
  "K11",  #  29
  "K12",  #  30
  "K13",  #  31
  "K14",  #  32
  "K17",  #  33
  "K18",  #  34
  "K19",  #  35
  "K22",  #  36
  "K23",  #  37
  "K24",  #  38
  "Lu<sup>b</sup>",  #  39
  "Lu3",  #  40
  "Lu4",  #  41
  "Lu5",  #  42
  "Lu6",  #  43
  "Lu7",  #  44
  "Lu8",  #  45
  "Lu11",  #  46
  "Lu12",  #  47
  "Lu13",  #  48
  "Lu20",  #  49
  "Au<sup>a</sup>",  #  50
  "Au<sup>b</sup>",  #  51
  "Fy4",  #  52
  "Fy5",  #  53
  "Fy6",  #  54
  "removed",  #  55
  "Sd<sup>a</sup>",  #  56
  "Wr<sup>b</sup>",  #  57
  "Yt<sup>b</sup>",  #  58
  "Xg<sup>a</sup>",  #  59
  "Sc1",  #  60
  "Sc2",  #  61
  "Sc3",  #  62
  "Jo<sup>a</sup>",  #  63
  "Do<sup>b</sup>",  #  64
  "Hy",  #  65
  "Gy<sup>a</sup>",  #  66
  "Co3",  #  67
  "LW<sup>a</sup>",  #  68
  "LW<sup>b</sup>",  #  69
  "Kx",  #  70
  "Ge2",  #  71
  "Ge3",  #  72
  "Wb",  #  73
  "Ls<sup>a</sup>",  #  74
  "An<sup>a</sup>",  #  75
  "Dh<sup>a</sup>",  #  76
  "Cr<sup>a</sup>",  #  77
  "IFC",  #  78
  "Kn<sup>a</sup>",  #  79
  "In<sup>b</sup>",  #  80
  "Cs<sup>a</sup>",  #  81
  "I",  #  82
  "Er<sup>a</sup>",  #  83
  "Vel",  #  84
  "Lan",  #  85
  "At<sup>a</sup>",  #  86
  "Jr<sup>a</sup>",  #  87
  "Ok<sup>a</sup>",  #  88
  "Wr<sup>a</sup>",  #  89
  "reserved for future use",  #  90
  "reserved for future use",  #  91
  "reserved for future use",  #  92
  "reserved for future use",  #  93
  "reserved for future use",  #  94
  "reserved for future use",  #  95
  "reserved for future use",  #  96
  "reserved for future use",  #  97
  "IgA deficient",  #  98
  "no information provided"  #  99
]

proc parseNegativeAntigen(spec: SpecialTestingAntigensFinnish): string =
  ## Parse the negative antigen field.
  # Table 12
  try:
    let numeric = spec.ii.parseInt
    if numeric > 99:
      raise newException(ValueError, "okänd kod för antigen: " & spec.ii)
    result = antigenNegativ[numeric]
  except:
    raise newException(ValueError, "okänd kod för antigen: " & spec.ii)


proc toHtml*(spec: SpecialTestingAntigensFinnish): string =
  ## Show information about `spec` as HTML
  let pheno = parseAntigen(spec)
  var phenotypeRows: string
  for pair in pheno:
    phenotypeRows.add tr(
      td(pair.name, style=commonstyle),
      td($pair.pheno)
    )

  let
    body = `div`(
      tr(
        td("aaaaaaaaaaaaaaaa"),
        td(spec.aaaaaaaaaaaaaaaa)
      ),
      phenotypeRows,
      tr(
        td("ii"),
        td(spec.ii)
      ),
      tr(
        td("Negativ för", style=commonstyle),
        td(parseNegativeAntigen(spec))
      ),
    )

  result = toHtmlCommon(body, spec.dataIdentifier)
