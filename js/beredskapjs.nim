import dom
import beredskap, beredskaptabell

var beredskaper = newSeq[Beredskap]()

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
  let beredskapTimmarAnnan = document.getElementById("beredskapTimmarAnnan").getValue.parseFloat
  let beredskapTimmarHelg = document.getElementById("beredskapTimmarHelg").getValue.parseFloat
  let kind = if document.getElementById("beredskapsTypA").checked: berA else: berB
  let kortVarsel = document.getElementById("kortVarsel").checked
  var b = initBeredskap(beredskapTimmarAnnan, beredskapTimmarHelg, kind, kortVarsel)

  b.addArbeteAnnan document.getElementById("arbetadeTimmarAnnan").getValue.parseFloat
  b.addArbeteVardagkväll document.getElementById("arbetadeTimmarVardagkvall").getValue.parseFloat
  b.addArbeteNatt document.getElementById("arbetadeTimmarNatt").getValue.parseFloat
  b.addArbeteHelg document.getElementById("arbetadeTimmarHelg").getValue.parseFloat
  b.addArbeteStorhelg document.getElementById("arbetadeTimmarStorhelg").getValue.parseFloat

  beredskaper.add b

  fillBeredskapTable()
