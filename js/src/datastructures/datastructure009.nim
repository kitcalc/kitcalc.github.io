## 2.4.9 Production Date and Time [Data Structure 009]

import htmlgen

type ProductionDateAndTime* = object
  dataIdentifier: string ##\
    ## &
    ## data identifier, first character
    ## }
    ## data identifier, second character
  c: string  ##\
    ## shall specify the century of the year in which the product was produced
  yy: string ##\
    ## shall specify the year within the century in which the product was
    ## produced.
  jjj: string ##\
    ## shall specify the ordinal number within the calendar year (Julian date)
    ## on which the product was produced.
    # note: this is now referred to as "ordinal date", from 1-366
  hh: string ##\
    ## shall specify the hour at which the product was produced (00 to 23).
  mm: string ##\
    ## shall specify the minute at which the product was produced (00 to 59).

func verifyProductionDateAndTime(code: string) =
  ## QC for Data Structure 009, "Production Date and Time"
  if code.len != 12:
    raise newException(ValueError,
      "Fel längd: längd 12 förväntades men endast " & $code.len &
      " tecken fanns i koden")

proc parseProductionDateAndTime*(code: string): ProductionDateAndTime =
  ## Parse Data Structure 009, "Production Date and Time"
  verifyProductionDateAndTime(code)

  result.dataIdentifier = code[0..1]
  result.c = code[2..2]
  result.yy = code[3..4]
  result.jjj = code[5..7]
  result.hh = code[8..9]
  result.mm = code[10..11]

proc toHtml*(date: ProductionDateAndTime): string =
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
    )

  result.add table(head, body)
