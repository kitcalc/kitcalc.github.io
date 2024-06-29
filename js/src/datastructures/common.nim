## Procedures common to all datastructure
import strutils  # parseInt
import math  # `^`
import htmlgen

# Date and time handling

func isLeapYear*(year: int): bool =
  ## Extremely simplified leap year classifier
  result = false
  if year mod 4 == 0:
    if year mod 100 == 0 and year mod 400 > 0:
      result = false
    else:
      result = true

func longYear*(century, year: int): int =
  ## Convert century, year to include millennium
  ## Assumes century 0 is >= 2000 and century != 0 <2000
  if century == 0:
    result = 2000 + year
  else:
    result = 1000 + century * 100 + year

const
  months = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  monthsL = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

func ordinalToDate*(century, year, ordinal: string): string =
  ## Converts ordinal date to normal date in string format
  # https://en.wikipedia.org/wiki/Ordinal_date
  let
    long = longYear(century.parseInt, year.parseInt)
    mtab = if isLeapYear(long): monthsL else: months
    ordinalint = ordinal.parseInt

  var
    day = ordinalInt
    days = 0
    month = 0
  for m in mtab.low..mtab.high:
    inc days, mtab[m]
    if days >= ordinalInt:
      month = m + 1
      break
    dec day, mtab[m]
  let
    monthString = if month < 10: "0" & $month else: $month
    dayString = if day < 10: "0" & $day else: $day
  return $long & "-" & monthString & "-" & dayString


func toDateTime*(century, year, ordinal, hh, mm: string): string =
  ## Simple formatting
  let date = ordinalToDate(century, year, ordinal)
  result = date & " " & hh & ":" & mm


# Style
const commonstyle* = "padding-left: 2em;"

func toHtmlCommon*(body, dataIdentifier: string): string =
  ## Format HTML output in a common format
  const
    header = h3("Streckkodens delar och tolkning")
    head = thead(
      tr(
        th("Element"),
        th("Värde")
      )
    )
  let
    bodyTop = tr(
        td("Dataidentitetstecken"),
        td(dataIdentifier)
    )

  result.add table(header, head, tbody(bodyTop, body))

# Procs related to checksums

func charToCheckValue*(c: char): int =
  ## Char to checksum value according to table 35
  case c
  of '0'..'9': result = c.int - '0'.int  # == -48
  of 'A'..'Z': result = c.int - 55  # 'A'.ord == 65
  of '*': result = 36
  else: assert false

func checkValueToChar*(i: int): char =
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

func calcCheckCharacter*(din: string): char =
  ## Calculate the keyboard entry check character K for `din`
  let value = iso7064mod37(din)
  result = checkValueToChar(value)

func type3FlagCharacters*(din: string): string =
  ## Calculate type 3 flag characters for `din`
  let value = iso7064mod37(din)
  result = $(value + 60)


