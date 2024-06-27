## 2.4.7 Collection Date and Time [Data Structure 007]

import htmlgen
import common

type CollectionDateAndTime* = object
  dataIdentifier: string ##\
    ## &
    ## data identifier, first character
    ## *
    ## data identifier, second character
  c: string  ##\
    ## shall specify the century of the year in which the product was collected
    ## or recovered.
  yy: string ##\
    ## shall specify the year within the century in which the product was
    ## collected or recovered.
  jjj: string ##\
    ## shall specify the ordinal number within the calendar year (Julian date)
    ## on which the product was collected or recovered.
    # note: this is now referred to as "ordinal date", from 1-366
  hh: string ##\
    ## shall specify the hour at which the product was collected or recovered
    ## (00 to 23).
  mm: string ##\
    ## shall specify the minute at which the product was collected or recovered
    ## (00 to 59).

func verifyCollectionDateAndTime(code: string) =
  ## QC for Data Structure 007, "Collection Date and Time"
  if code.len != 12:
    raise newException(ValueError,
      "Fel längd: längd 12 förväntades men endast " & $code.len &
      " tecken fanns i koden")

proc parseCollectionDateAndTime*(code: string): CollectionDateAndTime =
  ## Parse Data Structure 007, "Collection Date and Time"
  verifyCollectionDateAndTime(code)

  result.dataIdentifier = code[0..1]
  result.c = code[2..2]
  result.yy = code[3..4]
  result.jjj = code[5..7]
  result.hh = code[8..9]
  result.mm = code[10..11]

proc toHtml*(date: CollectionDateAndTime): string =
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
        td(toDateTime(date.c, date.year, date.ordinal, date.hh, date.mm))
      ),
    )

  result.add table(head, body)
