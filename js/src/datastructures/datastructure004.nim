## 2.4.4 Expiration Date [Data Structure 004]

import htmlgen, strutils

type ExpirationDate* = object
  dataIdentifier: string ##\
    ## =
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

func verifyExpirationDate(code: string) =
  ## QC for Data Structure 004, "Expiration Date"
  if code.len != 8:
    raise newException(ValueError,
      "Fel längd: längd 8 förväntades men endast " & $code.len &
      " tecken fanns i koden")

proc parseExpirationDate*(code: string): ProductCode =
  ## Parse Data Structure 003, "Product Code"
  verifyExpirationDate(code)

  result.dataIdentifier = code[0..1]
  result.c = code[2..2]
  result.yy = code[3..4]
  result.jjj = code[5..7]

proc toHtml*(date: ExpirationDate): string =
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
        td(code.c)
      ),
      tr(
        td("År"),
        td(code.yy)
      ),
      tr(
        td("Datumnummer (1 januari = 1)"),
        td(code.jjj)
      ),
    )

  result.add table(head, body)