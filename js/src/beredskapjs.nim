import dom
import beredskap, beredskaptabell, strutils

var beredskaper = newSeq[Beredskap]()

template getValue(e: untyped): untyped =
  ## För att kunna modifiera input-element.
  OptionElement(e).value

proc fillBeredskapTable*() {.exportc.} =
  ## Lägg till tabell i HTML-dokument
  let manadslon = parseInt $document.getElementById("manadslon").getValue
  let ers = initErsättning(manadslon, beredskaper)
  let table = createBeredskapTable(ers)
  document.getElementById("tabell").innerHtml = table.cstring

proc addBeredskap*() {.exportc.} =
  ## Lägg till en ny beredskap
  let
    beredskapTimmarAnnan = parseFloat $document.getElementById("beredskapTimmarAnnan").getValue
    beredskapTimmarHelg = parseFloat $document.getElementById("beredskapTimmarHelg").getValue
    kind = if document.getElementById("beredskapsTypA").checked: berA else: berB
    kortVarsel = document.getElementById("kortVarsel").checked
  var b = initBeredskap(beredskapTimmarAnnan, beredskapTimmarHelg, kind, kortVarsel)

  b.addArbeteAnnan parseFloat($document.getElementById("arbetadeMinAnnan").getValue) / 60.0
  b.addArbeteVardagkväll parseFloat($document.getElementById("arbetadeMinVardagkvall").getValue) / 60.0
  b.addArbeteNatt parseFloat($document.getElementById("arbetadeMinNatt").getValue) / 60.0
  b.addArbeteHelg parseFloat($document.getElementById("arbetadeMinHelg").getValue) / 60.0
  b.addArbeteStorhelg parseFloat($document.getElementById("arbetadeMinStorhelg").getValue) / 60.0

  beredskaper.add b

  fillBeredskapTable()
  FormElement(document.getElementbyId("calc")).reset()  # clear form
