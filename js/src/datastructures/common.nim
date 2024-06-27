## Procedures common to all datastructure

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

  var
    day = ordinal.parseInt
    days = 0
    month = 0
  for m in mtab.low..mtab.high:
    inc days, mtab[m]
    if days >= ordinal:
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
