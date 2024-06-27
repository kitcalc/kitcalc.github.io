## 2.4.5 Expiration Date and Time [Data Structure 005]

import htmlgen
import common

type ExpirationDateAndTime* = object
  dataIdentifier: string ##\
    ## &
    ## data identifier, first character
    ## >
    ## data identifier, second character
  c: string  ##\
    ## shall specify the century of the year in which the item expires.
  yy: string ##\
    ## shall specify the year within the century in which the item expires.
  jjj: string ##\
    ## shall specify the ordinal number within the calendar year (Julian date)
    ## on which the item expires
    # note: this is now referred to as "ordinal date", from 1-366
  hh: string ##\
    ## shall specify the hour at which the product expires (00 to 23)
  mm: string ##\
    ## shall specify the minute at which the product expires (00 to 59).

func verifyExpirationDateAndTime(code: string) =
  ## QC for Data Structure 005, "Expiration Date and Time"
  if code.len != 12:
    raise newException(ValueError,
      "Fel längd: längd 12 förväntades men endast " & $code.len &
      " tecken fanns i koden")

proc parseExpirationDateAndTime*(code: string): ExpirationDateAndTime =
  ## Parse Data Structure 005, "Expiration Date and Time"
  verifyExpirationDateAndTime(code)

  result.dataIdentifier = code[0..1]
  result.c = code[2..2]
  result.yy = code[3..4]
  result.jjj = code[5..7]
  result.hh = code[8..9]
  result.mm = code[10..11]

proc toHtml*(date: ExpirationDateAndTime): string =
  ## Show information about `date` as HTML

  let
    head = thead(
      tr(
        th("Element"),
        th("Värde")
      )
    )
    body = tbody(
      tr(
        td("Sekel"),
        td(date.c)
      ),
      tr(
        td("År"),
        td(date.yy)
      ),
      tr(
        td("Datumnummer (1 januari = 1)"),
        td(date.jjj)
      ),
      tr(
        td("Timme"),
        td(date.hh)
      ),
      tr(
        td("Minut"),
        td(date.mm)
      ),
      tr(
        td("Datum och tid", style=commonstyle),
        td(toDateTime(date.c, date.yy, date.jjj, date.hh, date.mm))
      ),
    )

  result.add table(head, body)
