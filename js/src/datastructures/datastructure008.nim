## 2.4.8 Production Date [Data Structure 008]

import htmlgen

type ProductionDate* = object
  dataIdentifier: string ##\
    ## =
    ## data identifier, first character
    ## }
    ## data identifier, second character
  c: string  ##\
    ## shall specify the century of the year in which the product was produced
  yy: string ##\
    ## shall specify the year within the century in which the product was
    ## produced.
  jjj: string ##\
    ## shall specify the ordinal number within the calendar year (Julian date) on
    ## which the product was produced.
    # note: this is now referred to as "ordinal date", from 1-366

func verifyProductionDate(code: string) =
  ## QC for Data Structure 008, "Production Date"
  if code.len != 8:
    raise newException(ValueError,
      "Fel längd: längd 8 förväntades men endast " & $code.len &
      " tecken fanns i koden")

proc parseProductionDate*(code: string): ProductionDate =
  ## Parse Data Structure 008, "Production Date"
  verifyProductionDate(code)

  result.dataIdentifier = code[0..1]
  result.c = code[2..2]
  result.yy = code[3..4]
  result.jjj = code[5..7]

proc toHtml*(date: ProductionDate): string =
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
    )

  result.add table(head, body)
