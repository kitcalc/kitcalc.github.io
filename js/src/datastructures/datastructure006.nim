## 2.4.6 Collection Date [Data Structure 006]

import htmlgen
import common

type CollectionDate* = object
  dataIdentifier: string ##\
    ## =
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
    ## shall specify the ordinal number within the calendar year (Julian date) on
    ## which the product was collected or recovered.
    # note: this is now referred to as "ordinal date", from 1-366

func verifyCollectionDate(code: string) =
  ## QC for Data Structure 006, "Collection Date"
  if code.len != 8:
    raise newException(ValueError,
      "Fel längd: längd 8 förväntades men " & $code.len &
      " tecken fanns i koden")

proc parseCollectionDate*(code: string): CollectionDate =
  ## Parse Data Structure 006, "Collection Date"
  verifyCollectionDate(code)

  result.dataIdentifier = code[0..1]
  result.c = code[2..2]
  result.yy = code[3..4]
  result.jjj = code[5..7]

proc toHtml*(date: CollectionDate): string =
  ## Show information about `date` as HTML

  let
    body = `div`(
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
        td("Datum", style=commonstyle),
        td(ordinalToDate(date.c, date.yy, date.jjj))
      ),
    )

  result = toHtmlCommon(body, date.dataIdentifier)
