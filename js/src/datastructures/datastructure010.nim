## 2.4.10 Special Testing: General [Data Structure 010]

import htmlgen
import common

type SpecialTestingGeneral* = object
  dataIdentifier: string ##\
    ## &
    ## data identifier, first character
    ## ()
    ## data identifier, second character
  zzzzz: string  ##\
    ## The five (5)-character data content string, zzzzz, shall be encoded and
    ## interpreted by reference to the Special Testing database table (see
    ## Section 5.2, page 115) published and maintained by ICCBBA in the
    ## password-protected area of the ICCBBA Website.

func verifySpecialTestingGeneral(code: string) =
  ## QC for Data Structure 010, "Special Testing: General"
  if code.len != 7:
    raise newException(ValueError,
      "Fel längd: längd 7 förväntades men endast " & $code.len &
      " tecken fanns i koden")

proc parseSpecialTestingGeneral*(code: string): SpecialTestingGeneral =
  ## Parse Data Structure 008, "Special Testing: General"
  verifySpecialTestingGeneral(code)

  result.dataIdentifier = code[0..1]
  result.zzzzz = code[2..6]


proc toHtml*(code: SpecialTestingGeneral): string =
  ## Show information about `code` as HTML
  let
    head = thead(
      tr(
        th("Element"),
        th("Värde")
      )
    )
    body = tbody(
      tr(
        td("zzzzz"),
        td(code.zzzzz)
      ),
      tr(
        td("Tolkning", style=commonstyle),
        td("Går ej att tolka, ej öppen tillgång till information")
      ),
    )

  result.add table(head, body)
