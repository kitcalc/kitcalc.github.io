import dom
import beredskap, beredskaptabell

var beredskaper = newSeq[Beredskap]()

proc clearForm() {.importc.}

template getValue(e: untyped): untyped =
  ## För att kunna modifiera input-element.
  ## Se: https://irclogs.nim-lang.org/18-03-2017.html#20:40:38
  cast[OptionElement](e).value

proc fillBeredskapTable*() {.exportc.} =
  ## Lägg till tabell i HTML-dokument
  let manadslon = document.getElementById("manadslon").getValue.parseInt
  let ers = initErsättning(manadslon, beredskaper)
  let table = createBeredskapTable(ers)
  document.getElementById("tabell").innerHtml = table

proc addBeredskap*() {.exportc.} =
  ## Lägg till en ny beredskap
  let
    beredskapTimmarAnnan = document.getElementById("beredskapTimmarAnnan").getValue.parseFloat
    beredskapTimmarHelg = document.getElementById("beredskapTimmarHelg").getValue.parseFloat
    kind = if document.getElementById("beredskapsTypA").checked: berA else: berB
    kortVarsel = document.getElementById("kortVarsel").checked
  var b = initBeredskap(beredskapTimmarAnnan, beredskapTimmarHelg, kind, kortVarsel)

  b.addArbeteAnnan document.getElementById("arbetadeMinAnnan").getValue.parseFloat / 60.0
  b.addArbeteVardagkväll document.getElementById("arbetadeMinVardagkvall").getValue.parseFloat / 60.0
  b.addArbeteNatt document.getElementById("arbetadeMinNatt").getValue.parseFloat / 60.0
  b.addArbeteHelg document.getElementById("arbetadeMinHelg").getValue.parseFloat / 60.0
  b.addArbeteStorhelg document.getElementById("arbetadeMinStorhelg").getValue.parseFloat / 60.0

  beredskaper.add b

  fillBeredskapTable()
  document.getElementbyId("calc").form.reset()  # clear form
