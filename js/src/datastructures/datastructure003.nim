## 2.4.3 Product Code [Data Structure 003]

import htmlgen, strutils

type ProductCode* = object
  dataIdentifier: string ##\
    ## =
    ## data identifier, first character
    ## <
    ## data identifier, second character
  productDescriptionCode: string ##\
    ## αoooo
    ##
    ## α    - alphabetic {A-Z}
    ## oooo - alphanumeric {A-Z; 0–9}
    ## 
    ## αoooo
    ## • shall specify the Product Description Code (PDC)
    ## • shall be encoded and interpreted by reference to the Product
    ##   Description Codes database table. An exception to this is the clinical
    ##   trials products indicated in the mapping table below, which are coded
    ##   in a separate database.
  tds: string ##\
    ## tds The encoding and interpretation of tds shall depend upon the
    ## value of α.
    ##
    ## For α values of E, F, H, S, P, X0, or YA to YZ the t portion of the
    ## Product Code shall specify the Collection Type Code. See Table 7
    ## for collection types.
    ##
    ## For α values of E, F, H, S, P, X0, or YA to YZ the ds portion of the
    ## Product Code shall specify the Division Code.
    ## The d portion of the Division Code shall be encoded using capital
    ## letters, unless Data Structure 032 is used in conjunction with Data
    ## Structure 003.
    ##
    ## The s portion of the Division Code shall be encoded using lower
    ## case letters, unless Data Structure 032 is used in conjunction with
    ## Data Structure 003.

func verifyProductCode(code: string) =
  ## QC for Data Structure 003, "Product Code"

  if code.len != 10:
    raise newException(ValueError,
      "Fel längd: längd 10 förväntades men endast " & $code.len &
      " tecken fanns i koden")

proc parseProductCode*(code: string): ProductCode =
  ## Parse Data Structure 003, "Product Code"
  verifyProductCode(code)

  result.dataIdentifier = code[0..1]
  result.productDescriptionCode = code[2..6]
  result.tds = code[7..9]

proc parseProductDescription(code: ProductCode): string =
  ## Parse the (broad) product description from code string

  # match explicitly, if no match - raise in end of proc, mostly to reduce clutter

  case code.productDescriptionCode[0]  # use inital letter
  of 'E', 'F': result = "Blood Components"
  of 'H': result = "Medical products of human origin (MPHO) with International Nonproprietary Names (INN) and/or United States Adopted Name (USAN) names"
  of 'M':
    # specific M-codes are numeric. Out-of-range and character codes are not
    # allowed
    try:
      let numeric = code.productDescriptionCode[1..4].parseInt  # last four characters
      case numeric
      of 1..999:
        result = "Human Milk"
      of 1000..8999:
        result = "Not assigned"
      of 9000..9999:
        result = "Topical Products of Human Origin"
      else: discard
    except ValueError:
      discard
  of 'N':
    # specific N-codes are numeric
    try:
      let numeric = code.productDescriptionCode[1..4].parseInt  # last four characters
      case numeric
      of 1..999:
        result = "Organs"
      of 1000..9999:
        result = "Not assigned"
      else: discard
    except ValueError: 
      discard
  of 'P':
    result = "Regenerated Tissue products"
  of 'R':
    # specific R-codes are numeric
    try:
      let numeric = code.productDescriptionCode[1..4].parseInt  # last four characters
      case numeric
      of 1..999:
        result = "Reproductive Tissue and Cell products"
      of 1000..9999:
        result = "Not assigned"
      else: discard
    except ValueError:
      discard
  of 'S':
    result = "Cellular Therapy products"
  of 'T':
    result = "Tissue products"
  of 'V':
    result = "Ocular Tissue products"
  of 'W':
    # specific W-codes are numeric
    try:
      let numeric = code.productDescriptionCode[1..4].parseInt  # last four characters
      case numeric 
      of 1..999:
        result = "Fecal Microbiota"
      of 1000..9999:
        result = "Not assigned"
      else: discard
    except ValueError:
      discard
  of 'X':
    # specific X-codes are numeric
    try:
      let numeric = code.productDescriptionCode[1..4].parseInt  # last four characters
      case numeric 
      of 1..999:
        result = "Plasma Derivatives"
      of 1000..4999:
        result = "Not assigned"
      of 5000..5999:
        result = "In Vivo Diagnostic Medical products of human origin (MPHO)"
      of 6000..9999:
        result = "Not assigned"
      else: discard
    except ValueError:
      discard
  of 'Y':
    try:
      let
        second = code.productDescriptionCode[1]  # second character
        numeric = code.productDescriptionCode[2..4].parseInt  # last THREE characters
      if second in {'A'..'Y'} and 0 <= numeric and numeric <= 999:
        result = "Clinical Trials products"
      else: discard
    except ValueError:
      discard
  of 'A'..'D':
    # Handboken: A-codes local, contradictory to the standard...
    result = "National or Local/Facility codes"
  else: discard

  # no explicit result - unknown code
  if result.len == 0:
    raise newException(ValueError, "okänd produktkod: " & code.productDescriptionCode)


proc parseCollectionType(first: char): string =
  ## Returns the collection type for `first`
  # Table 7 Data Structure 003
  case first
  of '0': "Not specified (null value)"
  of 'V': "Volunteer homologous (allogeneic) (default)"
  of 'R': "Volunteer research (Product not intended for human application)"
  of 'S': "Volunteer source"
  of 'T': "Volunteer therapeutic"
  of 'P': "Paid homologous (allogeneic)"
  of 'r': "Paid research (Product not intended for human application)"
  of 's': "Paid source"
  of 'A': "Autologous, eligible for crossover"
  of '1': "For autologous use only"
  of 'X': "For autologous use only, biohazard"
  of 'D': "Volunteer directed, eligible for crossover"
  of 'd': "Paid directed, eligible for crossover"
  of '2': "For directed recipient use only"
  of 'L': "For directed recipient use only, limited exposure"
  of 'E': "Medical exception, for specified recipient only (allogeneic)"
  of 'Q': "See (i.e., read [scan]) Special Testing bar code"
  of '3': "For directed recipient use only, biohazard"
  of '4': "Designated"
  of '5': "Dedicated"
  of '6': "Designated, biohazard"
  of 'F': "Family reserved"
  of 'C': "Replacement"
  of '7': "For allogeneic use."
  of '8': "For autologous use. Contains allogeneic material."
  of 'B': "Directed/Dedicated/Designated Collection Use Only"
  of 'H': "Directed/Dedicated/Designated Collection/Biohazardous"
  of 'J': "Directed/Dedicated/Designated Collection/Eligible for Crossover"
  of 'G': "For Emergency Use Only"
  else:
    raise newException(ValueError, "okänd typ av tappning eller donation: " & first)

type
  TdsKind = enum
    simple  # just division
    complex  # collection type and division
  Tds = object
    division: string
    case kind: TdsKind
    of simple:
      discard  # use tds directly
    of complex:
      collectionType: string


proc parseTds(code: ProductCode): Tds =
  ## Parse the TDS sequence
  # use \alpha once again
  let 
    first = code.productDescriptionCode[0]
    second = code.productDescriptionCode[0]  # for X, Y
  case first
  of 'E', 'F', 'H', 'S', 'P', 'X', 'Y':
    # check X and Y first
    if first == 'X' and second != '0':
      if second in {'1'..'9'}:
        # If α is X1-X9, tds shall be reserved for future use and the value 000 shall be used.
        result = Tds(kind: simple, division: code.tds)
      else:
        raise newException(ValueError, "okänd produktkod för tds: " & code.productDescriptionCode)
    elif first == 'Y' and second notin {'A'..'Y'}:
      raise newException(ValueError, "okänd produktkod för tds: " & code.productDescriptionCode)
    # now that we have valid products, interpret tds
    let
      collectionType = parseCollectionType(code.tds[0])
      division = code.tds[1..2]  # last two
    result = Tds(kind: complex, collectionType: collectionType, division: division)
  of 'M', 'N', 'R', 'T', 'V', 'W':
    result = Tds(kind: simple, division: code.tds)
  of 'A'..'D':
    result = Tds(kind: simple, division: code.tds)
  else:
    raise newException(ValueError, "okänd produktkod: " & code.productDescriptionCode)


proc toHtml*(code: ProductCode): string =
  ## Show information about `code` as HTML

  let 
    productType = parseProductDescription(code)
    tds = parseTds(code)

  var tdsRows: string
  case tds.kind
  of simple:
    tdsRows = tr(
      td(i("Tolkad delning")),
      td(if tds.division == "000": "ej delad" else: "delad")
    )
  of complex:
    tdsRows.add tr(
      td(i("Tolkad typ av tappning och användning")),
      td(tds.collectionType)
    )
    if code.productDescriptionCode[0] in {'A'..'D'}:
      tdsRows.add tr(
        td(i("Tolkad delning")),
        td("lokalt eller nationellt definierad kod")
      )
    else:
      let divisionField = if tds.division == "99":
        "datastruktur 032 ger information om delning"
      elif tds.division == "00":
        "ej delad"
      else:
        "delad"
      tdsRows.add tr(
        td(i("Tolkad delning")),
        td(divisionField)
      )

  let
    head = thead(
      tr(
        th("Element"),
        th("Värde")
      )
    )
    body = tbody(
      tr(
        td("Produktkod"),
        td(code.productDescriptionCode)
      ),
      tr(
        td(i("Tolkad komponenttyp")),
        td(productType)
      ),
      tr(
        td("tds"),
        td(code.tds)
      ),
      tdsRows
    )

  result.add table(head, body)
