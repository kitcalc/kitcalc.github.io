# TODO: check character calculation

## 2.4.1 Donation Identification Number [Data Structure 001]

import strutils  # parseInt
import htmlgen


type DonationIdentificationNumber* = object
  dataIdentifier: string ##\
    ## =
    ##
    ## data identifier, first character
  facilityIdentificationNumber: string ##\
    ## αpppp
    ##
    ## • shall specify the Facility Identification Number (FIN) of the
    ##   organization that assigned the DIN.
    ## • shall be encoded and interpreted by reference to the
    ##   ICCBBA Registered Facilities database.
  year: string ##\
    ## yy
    ##
    ## shall specify the last two digits of the nominal year in which
    ## the DIN was assigned.
    ## The nominal year may overlap +/- one month of the year
    ## assigned.
  sequence: string ##\
    ## nnnnnn
    ##
    ## shall specify the sequence number, within the given nominal year
    ## for the FIN.
  flagCharacters: string ##\
    ## ff
    ##
    ## shall specify flag characters. Flag characters are not part of
    ## the 13-character DIN. See Figure 2.
    ## As shown in Table 3 on page 85, there are three general types of flag
    ## characters:
    ## Type 1: Two-character code used for process control and defined
    ##         by ICCBBA.
    ## Type 2: Two-character code used for process control, but locally
    ##         defined.
    ## Type 3: Two-character code used to convey a weighted ISO/IEC
    ##         7064 modulo 37-2 check character. See Appendix A: Donation
    ##         Identification Number Check Character [K].
    ## When not used, the value of the flag characters shall be 00
    ## (zeroes).
    ## Type 2 flag characters shall only be interpreted by the facility that
    ## has defined them, or within the group of facilities that have agreed
    ## on a common definition.


func verifyDonationIdentificationNumber(din: string) =
  ## QC for Data Structure 001, "Donation Identification Number"

  if din.len != 16:
    raise newException(ValueError,
      "Fel längd: längd 16 förväntades men endast " & $din.len &
      " tecken fanns i koden")


proc parseDonationIdentificationNumber*(code: string): DonationIdentificationNumber =
  ## Parse Data Structure 001, "Donation Identification Number"

  # qc
  verifyDonationIdentificationNumber(code)

  result.dataIdentifier = code[0..0]  # all as strings
  result.facilityIdentificationNumber = code[1..5]
  result.year = code[6..7]
  result.sequence = code[8..13]
  result.flagCharacters = code[14..15]


func interpretFlagSwe(din: DonationIdentificationNumber): string =
  ## Parse the flag characters and return their meaning as text, according to
  ## https://transfusion.se/isbt-128-kodverk-och-anvandning/

  result = case din.flagCharacters

    # förslag till standard i Sverige för nummermarkörer (nm) avseende
    # påsarna i blodpåsesystemet, journaletiketter, omklistring av blodenheter
    of "01": "Påse 1, på tappningsetiketten vid tappning"
    of "02": "Påse 2, på tappningsetiketten vid tappning"
    of "03": "Påse 3, på tappningsetiketten vid tappning"
    of "04": "Påse 4, på tappningsetiketten vid tappning"

    of "31": "Påse 1, på tappningsetiketten vid omklistring"
    of "32": "Påse 2, på tappningsetiketten vid omklistring"
    of "33": "Påse 3, på tappningsetiketten vid omklistring"
    of "34": "Påse 4, på tappningsetiketten vid omklistring"

    of "41": "Påse 1, på journaletiketten vid tappning"
    of "42": "Påse 2, på journaletiketten vid tappning"
    of "43": "Påse 3, på journaletiketten vid tappning"
    of "44": "Påse 4, på journaletiketten vid tappning"

    of "51": "Påse 1, på journaletiketten vid omklistring"
    of "52": "Påse 2, på journaletiketten vid omklistring"
    of "53": "Påse 3, på journaletiketten vid omklistring"
    of "54": "Påse 4, på journaletiketten vid omklistring"

    # Nummermarkörer på blodprov och blanketter:
    of "05": "Annan (upprepad) \"on demand\"-tryckt del av etiketten"
    of "06": "Pilotrör"
    of "07": "Prov för smittester"
    of "08": "Givardokumentation (blankett för hälsodeklaration)"
    of "09": "Prov för NAT"
    of "10": "Prov för undersökning av bakteriell växt"
    of "20": "Packsedel (vid transport av blodenheter till annan blodcentral)"
    of "30": "Följesedel till blodpåsen"
    of "40": "Användes vid inköp av blodenheter märkta med nummer 00"
    of "50": "Kvittens, används vid obemannad depå"

    else: "Ej definierad i Handbok för blodverksamhet"


func interpretFlag(din: DonationIdentificationNumber): string =
  ## Parse the flag characters and return their meaning as text

  case din.flagCharacters
  of "00": result = "Flag not used; null value"
  of "01": result = "Container 1 of a set"
  of "02": result = "Container 2 of a set"
  of "03": result = "Container 3 of a set"
  of "04": result = "Container 4 of a set"
  of "05": result = "Second (or repeated) “demand-printed” label"
  of "06": result = "Pilot tube label"
  of "07": result = "Test tube label"
  of "08": result = "Donor record label"
  of "09": result = "Sample tube for NAT testing"
  of "10": result = "Samples for bacterial testing"
  of "11": result = "Match with Unit label"
  of "12": result = "Affixed partial label"
  of "13": result = "Attached label (intended to be used with affixed partial label)"
  of "14": result = "Reserved for future assignment"
  of "15": result = "Container 5 of a set"
  of "16": result = "Container 6 of a set"
  of "17": result = "Container 7 of a set"
  of "18": result = "Container 8 of a set"
  of "19": result = "Container 9 of a set"
  else:
    # parse numeric values, if alphanumeric it is a reserved value
    try:
      let numeric = din.flagCharacters.parseInt

      case numeric
      of 20..59:
        result = "Reserved for assignment and use by each local facility. Therefore the meaning and interpretation of flag values 20–59 may differ with each FIN and should not be interpreted at any other site"
      of 60..96:
        result = "ISO/IEC 7064 modulo 37-2 check character on the preceding thirteen (13) data characters, αppppyynnnnnn including the FIN, year and the unit sequence number — value is assigned as 60 plus the modulo 37-2 checksum"
      else:
        result = "Reserved for future assignment"
    except ValueError:
      # Alphanumeric using numbers in the range 0-9 and alphas in the range
      # A-N, P, R-Y
      result = "Reserved for future assignment"

#[  # misc functions - untested

func charToCheckValue(c: char): int =
  ## Char to checksum value according to table 35
  case c
  of '0'..'9': result = c.int - '0'.int  # == -48
  of 'A'..'Z': result = c.int - 55  # 'A'.ord == 65
  of '*': result = 36
  else: assert false

func checkValueToChar(i: int): char =
  ## Checksum value to char according to table 35
  const table = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ*"
  static: assert table.len == 37
  result = table[i]

func iso7064mod37(s: string): int =
  # The ISO 7064 Mod 37-2 algorithm for checksum calculation
  assert s.len == 13  # only allowed for DIN
  var
    value = 0
    positionRight = 13
  for c in s:
    let weighted = 2^positionRight * charToCheckValue(c)
    inc value, weighted
    dec positionRight
  value = value mod 37
  value = 38 - value
  value = value mod 37
  result = value

func checkCharacter(din: DonationIdentificationNumber): char =
  ## Calculate the keyboard entry check character K for `din`
  let value = iso7064mod37(din.DIN)
  result = checkValueToChar(value)

func type3FlagCharacters(din: DonationIdentificationNumber): string =
  ## Calculate type 3 flag characters for `din`
  let value = iso7064mod37(din.DIN)
  result = $(value + 60)
]#

proc toHtml*(din: DonationIdentificationNumber): string =
  ## Show information about `din` as HTML
  result = b("Tappningsnummer (Donation Identification Number)")
  let
    head = thead(
      tr(
        th("Element"),
        th("Värde")
      )
    )
    body = tbody(
      tr(
        td("Blodcentralskod (Facility Identification Number)"),
        td(din.facilityIdentificationNumber)
      ),
      tr(
        td("År"),
        td(din.year)
      ),
      tr(
        td("Löpnummer"),
        td(din.sequence)
      ),
      tr(
        td("Nummermarkör"),
        td(din.flagCharacters)
      ),
      tr(
        td(i("Tolkning nummermarkör, svensk")),
        td(interpretFlagSwe(din))
      ),
      tr(
        td(i("Tolkning nummermarkör, ISBT 128")),
        td(interpretFlag(din))
      )
    )

  result.add table(head, body)
