import htmlgen, strutils


type

  Hours = range[0.0 .. float.high]  ## Like Natural but for float

  WorkType = enum  ## Tid för störning
    other = "Annan tid",  ## annan tid
    evening = "Vardag 21–24",  ## vardag 21-24
    night = "Vardag 00–07",  ## vardag 00-07; separate from weekend to calculate weekday waiting time
    weekend = "Helg",  ## helg
    holiday = "Storhelg" ## storhelg

  Work = object  ## Ett störningstillfälle
    kind: WorkType  ## störningstyp
    duration: Natural  ## störningstid i minuter

  OnCallTimeType = enum  ## Tid för beredskap
    other = "Annan tid",  ## annan tid
    weekend = "Helg" ## helg

  OnCallType = enum ## Typ av beredskap, jour, A eller B
    jour = "Jour",
    berA = "Beredskap A",
    berB = "Beredskap B"

  OnCall = object ## Ett beredskapstillfälle

    kind = berA  ## Typ av beredskap, default A
    shortNotice = false  ## Indikerar kort varsel, default false

    hoursWaiting: array[OnCallTimeType, Hours]  ## Timmar i beredskap

    works: seq[Work]  ## störningar

  WorkMonth = object ##\
    ## En samlad ersättning för beredskaper, en kalendermånad
    onCalls: seq[OnCall]  ##Beredskaperna

  Compensation = object  ##\
    ## Ersättning för arbete under ett beredskapstillfälle. Ej fördelat tid/pengar
    working: array[WorkType, float]
    waiting: array[OnCallType, float]

    # time, not compensation, spent waiting. saved for 1/330
    waitingTime: array[OnCallType, float]

    # separate because of how it is presented
    workingShortNotice: array[WorkType, float]  # note - not for holiday!

    # note: 1/330 not included here

  PaymentType = enum  ##\
    ## Ersättningstyper för en kalendermånad
    berAtid = "Ber A tid",
    berApeng = "Ber A peng",
    berA440 = "Ber A 1/440",
    berBtid = "Ber B tid",
    berBpeng = "Ber B peng",
    berB440 = "Ber B 1/440",
    ber330 = "Ber 1/330",  # unsure about the name, shared between berA/berB
    jourTid = "Jour tid",
    jourPeng = "Jour peng",
    jour330 = "Jour 1/330",
    jour440 = "Jour 1/440",
    arbtid10tid = "Arbtid 1.0 tid",
    arbtid10peng = "Arbtid 1.0 peng",
    arbtid15tid = "Arbtid 1.5 tid",
    arbtid15peng = "Arbtid 1.5 peng",
    arbtid20tid = "Arbtid 2.0 tid",
    arbtid20peng = "Arbtid 2.0 peng",
    arbtid40tid = "Arbtid 4.0 tid",
    arbtid40peng = "Arbtid 4.0 peng",
    arbtid10kvtid = "Arbtid 1.0 kv tid",
    arbtid10kvpeng = "Arbtid 1.0 kv peng",
    arbtid15kvtid = "Arbtid 1.5 kv tid",
    arbtid15kvpeng = "Arbtid 1.5 kv peng",
    arbtid20kvtid = "Arbtid 2.0 kv tid",
    arbtid20kvpeng = "Arbtid 2.0 kv peng"

  Presentation = enum
    antal = "Antal"
    apris = "Apris"
    belopp = "Belopp"

  Payment = array[PaymentType, array[Presentation, float]]  ##\
    ## Ersättningar för en kalendermånad: antal, Apris, belopp


# ersättningar enligt avtal 2025
const
  timeQuota = 0.7  ## ersättning i tid
  moneyQuota = 1.0 - timeQuota  ## ersättning i pengar

  paymentWaiting: array[OnCallTimeType, array[OnCallType, float]] = [

    # ersättning beredskap övrig tid, per beredskapstyp (jour, A, B)
    [0.25, 0.17, 0.15],

    # ersättning beredskap helg, per beredskapstyp
    [0.5, 0.25, 0.23]
  ]


  paymentWork: array[WorkType, float] = [1.0, 1.5, 2.0, 2.0, 4.0]  ##\
    ## ersättning för arbetad tid per tid: annan tid, vardagkväll, natt, helg
    ## samt storhelg

  extraPaymentShortNotice: array[OnCallType, float] = [0.5, 0.2, 0.15]  ##\
    ## extra ersättning beredskap med kort varsel, per beredskapstyp (jour, A, B)

  extraPaymentWorkShortNotice = 1.5  ## extra ersättning för arbete med kort varsel


proc addWork(call: var OnCall, worktype: WorkType; duration: Natural) =
  ## Add work to `call`
  call.works.add Work(kind: worktype, duration: duration)


proc addOnCall(month: var WorkMonth; call: OnCall) =
  ## Add `call` to `month`
  month.onCalls.add call


func merge(c1, c2: Compensation): Compensation =
  ## Add fields of c1 and c2
  for i in c1.working.low .. c1.working.high:
    result.working[i] = c1.working[i] + c2.working[i]

  for i in c1.waiting.low .. c1.waiting.high:
    result.waiting[i] = c1.waiting[i] + c2.waiting[i]

  for i in c1.waitingTime.low .. c1.waitingTime.high:
    result.waitingTime[i] = c1.waitingTime[i] + c2.waitingTime[i]

  for i in c1.workingShortNotice.low .. c1.workingShortNotice.high:
    result.workingShortNotice[i] = c1.workingShortNotice[i] + c2.workingShortNotice[i]


template inHours(minutes: Natural): float =
  ## Minutes to hours
  minutes.float / 60.0


proc getCompensation(call: OnCall): Compensation =
  ## Get compensation for this on call, in hours
  var waiting = call.hoursWaiting
  for work in call.works:
    let hours = work.duration.inHours

    # extra pay unless holiday
    if call.shortNotice and work.kind != holiday:
      result.workingShortNotice[work.kind] += hours * paymentWork[work.kind]
      result.workingShortNotice[work.kind] += hours * extraPaymentWorkShortNotice
    else:
      # regular pay
      result.working[work.kind] += hours * paymentWork[work.kind]

    # decrease waiting time by the length of work
    case work.kind
    of other, evening, night:
      waiting[OnCallTimeType.other] -= hours
    of weekend, holiday:
      waiting[OnCallTimeType.weekend] -= hours

  # now compensation for waiting time
  for kind in waiting.low .. waiting.high:
    result.waiting[call.kind] += paymentWaiting[kind][call.kind] * waiting[kind]

    if call.shortNotice:
      # short notice extra for waiting

      # no extra payment for short notice on holidays is not taken into account!!!
      result.waiting[call.kind] += extraPaymentShortNotice[call.kind] * waiting[kind]

    # save raw waiting time
    result.waitingTime[call.kind] += waiting[kind]


proc getCompensation(month: WorkMonth): Compensation =
  ## Get compensation for this month, in hours

  for call in month.oncalls:
    let comp = getCompensation(call)
    result = result.merge(comp)


const
  ## Return matching payment fields for work types
  payFieldsWork: array[WorkType, (PaymentType, PaymentType)] = [
    (arbtid10tid, arbtid10peng),
    (arbtid15tid, arbtid15peng),
    (arbtid20tid, arbtid20peng),
    (arbtid20tid, arbtid20peng),
    (arbtid40tid, arbtid40peng)
  ]

  # short notice work
  payFieldsWorkShortNotice: array[WorkType, (PaymentType, PaymentType)] = [
    (arbtid10kvtid, arbtid10kvpeng),
    (arbtid15kvtid, arbtid15kvpeng),
    (arbtid20kvtid, arbtid20kvpeng),
    (arbtid20kvtid, arbtid20kvpeng),
    (arbtid40tid, arbtid40peng)
  ]

  payFieldsWait: array[OnCallType, (PaymentType, PaymentType)] = [
    (jourTid, jourPeng),
    (berAtid, berApeng),
    (berBtid, berBpeng)
  ]

  pay440Fields: array[OnCallType, PaymentType] = [
    jour440, berA440, berB440
  ]


proc getPayment(comp: Compensation, salary: Natural): Payment =
  ## Calculate how much is payed from numbers in compensation, given salary
  let
    pay137 = salary.float / 137.0
    pay440 = salary.float / 440.0
    pay330 = salary.float / 330.0

  # regular work pay
  for worktype in comp.working.low .. comp.working.high:
    let
      (time, money) = payFieldsWork[worktype]
      work = comp.working[worktype]

    # Why are arrays unrolled to use +=?
    # This is since 2.0 pay fields are used twice and will otherwise be blanked in
    # the later iteration for weekend

    result[time][antal] += work * timeQuota
    # rest of result[time] fields (apris, belopp are always 0.0 for time

    result[money][antal] += work * moneyQuota
    result[money][apris] = pay137
    result[money][belopp] += work * moneyQuota * pay137

  # short notice work pay
  for kvworktype in comp.workingShortNotice.low .. comp.workingShortNotice.high:
    let
      (time, money) = payFieldsWorkShortNotice[kvworktype]
      work = comp.workingShortNotice[kvworktype]

    # same as above for the unrolling of arrays

    result[time][antal] += work * timeQuota
    # remaining result[time] fields (apris, belopp) are always 0.0 for time

    result[money][antal] += work * moneyQuota
    result[money][apris] = pay137
    result[money][belopp] += work * moneyQuota * pay137

  # waiting pay
  for waittype in comp.waiting.low .. comp.waiting.high:
    let
      (time, money) = payFieldsWait[waittype]
      wait = comp.waiting[waittype]

    # waiting, 440 and 330 fields are not reused, assign array

    result[time] = [wait * timeQuota, 0.0, 0.0]

    result[money] = [wait * moneyQuota, pay137, wait * moneyQuota * pay137]

    # 1/440
    result[pay440Fields[waittype]] = [wait, pay440, wait * pay440]

  # 330 only in certain cases, >50 jour and >150 berA+B (raw time)
  let
    jourTotal = comp.waitingTime[jour]
    berTotal = comp.waitingTime[berA] + comp.waitingTime[berB]

  if jourTotal > 50.0:
    result[jour330] = [jourTotal - 50.0, pay330, (jourTotal - 50.0) * pay330]
  else:
    # for presentation purposes
    result[jour330] = [0.0, pay330, 0.0]

  if berTotal > 150.0:
    result[ber330] = [berTotal - 150.0, pay330, (berTotal - 150.0) * pay330]
  else:
    # for presentation purposes
    result[ber330] = [0.0, pay330, 0.0]


proc getPaymentSummary(pay: Payment): (float, float) =
  ## Returns total time, money counts for pay
  for t in pay.low .. pay.high:
    case t
    of berAtid, berBtid, jourTid, arbtid10tid, arbtid15tid, arbtid20tid, arbtid40tid, arbtid10kvtid, arbtid15kvtid, arbtid20kvtid:
      result[0] += pay[t][antal]
    else:
      result[1] += pay[t][belopp]


proc initOnCall(
    kind: OnCallType; hoursOther, hoursWeekend: Hours; shortNotice = false
  ): OnCall =
  ## Init an on call
  OnCall(
    kind: kind, shortNotice: shortNotice,
    hoursWaiting: [hoursOther, hoursWeekend], works: @[]
  )

# Shortcuts for the most common types
template vardag(): Oncall =
  OnCall(
    kind: berA, shortNotice: false, hoursWaiting: [15.5, 0.0], works: @[]
  )
template helg(): OnCall =
  OnCall(
    kind: berA, shortNotice: false, hoursWaiting: [1.5, 62.0], works: @[]
  )

const timeTypes = {
  berAtid, berBtid, jourTid, arbtid10tid, arbtid15tid, arbtid20tid,
  arbtid40tid, arbtid10kvtid, arbtid15kvtid, arbtid20kvtid
}


type
  OnCallTimeWorking = tuple
    working: array[WorkType, Hours]
    workingShortNotice: array[WorkType, Hours]
  OnCallTimeWaiting = array[OnCallType, array[OnCallTimeType, Hours]]  # indexedby[berA][other]


func getWorkDurations(call: OnCall): OnCallTimeWorking =
  ## Get work duration per type for `call`
  for work in call.works:
    let hours = work.duration.inHours
    if not call.shortNotice:
      result.working[work.kind] += hours
    else:
      result.workingShortNotice[work.kind] += hours


func getWorkDurations(month: WorkMonth): OnCallTimeWorking =
  ## Get work duration per type for `month`
  for call in month.onCalls:
    let duration = call.getWorkDurations
    for t in result.working.low .. result.working.high:
      result.working[t] += duration.working[t]
      result.workingShortNotice[t] += duration.workingShortNotice[t]


func getWaitingDurations(call: OnCall): OnCallTimeWaiting =
  ## Get waiting time duration sum for `call`
  for t in call.hoursWaiting.low .. call.hoursWaiting.high:
    result[call.kind][t] += call.hoursWaiting[t]


func getWaitingDurations(month: WorkMonth): OnCallTimeWaiting =
  ## Get waiting time duration sum for month
  # indexedby[berA][other]
  for call in month.onCalls:
    let duration = call.getWaitingDurations
    # only one kind so merge only that array
    for t in duration[call.kind].low .. duration[call.kind].high:
      result[call.kind][t] += duration[t]


func workingTableHtml(work: OnCallTimeWorking): string =
  ## Pretty-print time spent working in a month

  var rows = ""
  const theader = thead(
    tr(
      th(),
      th("Arbetad tid", colspan=2)
    ),
    tr(
      th(),
      th("(h)"),
      th("Kort varsel (h)")
    )
  )
  for t in WorkType.low .. WorkType.high:
    # skip empty
    if work.working[t] == 0.0 and work.workingShortNotice[t] == 0.0:
      continue
    var row = td($t)
    row.add td(work.working[t].formatFloat(ffDecimal, 2))
    if t != holiday:
      row.add td(work.workingShortNotice[t].formatFloat(ffDecimal, 2))
    else:
      row.add td("–")
    rows.add tr(row)

  result = table(theader, tbody(rows))


func waitingTableHtml(waiting: OnCallTimeWaiting): string =
  ## Pretty-print time spent waiting

  let rowOne = tr(th(), th("Bundenhet", colspan=OnCallTimeType.len))
  var rowTwo = th()
  for t in OnCallTimeType.low .. OnCallTimeType.high:
    theader.add th($t & " (h)")

  let theader = thead(
    rowOne, tr(rowTwo)
  )

  var rows = ""
  for t in waiting.low .. waiting.high:
    # skip waiting types with no time
    var hasData = false
    for hour in waiting[t];
      if hour > 0.0:
        hasData = true
        break

    if hasData:
      var row = td($t)
      for kind in waiting[t].low .. waiting[t].high:
        row.add td(waiting[t][kind].formatFloat(ffDecimal, 2))
      rows.add tr(row)

  result = table(theader, tbody(rows))


func timeTableHtml(call: OnCall): string =
  ## Pretty-print time spent working/waiting

  # waiting
  let waiting = call.getWaitingDurations
  result = waiting.waitingTableHtml

  # working
  let work = call.getWorkDurations
  result.add work.workingTableHtml


func timeTableHtml(month: WorkMonth): string =
  ## Pretty-print time spent working/waiting in a month

  # waiting
  let waiting = month.getWaitingDurations
  result = waiting.waitingTableHtml

  # work
  let work = month.getWorkDurations
  result.add work.workingTableHtml


func salaryTableHtml(pay: Payment): string =
  ## Pretty-print `pay` as HTML
  const theader = thead(tr(th(), th($antal), th($apris), th($belopp)))
  var rows = ""
  for t in pay.low .. pay.high:
    var row = ""
    if pay[t][antal] == 0.0: continue
    row.add td($t)
    row.add td(pay[t][antal].formatFloat(ffDecimal, 2))
    if t notin timeTypes:
      row.add td(pay[t][apris].formatFloat(ffDecimal, 2))
      row.add td(pay[t][belopp].formatFloat(ffDecimal, 2))
    else:
      row.add td()
      row.add td()
    rows.add tr(row)
  result = table(theader, tbody(rows))


func summaryTableHtml(pay: Payment): string =
  ## Pretty-print a summary of `pay` as HTML
  let summed = pay.getPaymentSummary
  result = table(
    thead(
      tr(
        th(),
        th("Ersättning")
      )
    ),
    tbody(
      tr(
        td("Tid (h)"),
        td(summed[0].formatFloat(ffDecimal, 2))
      ),
      tr(
        td("Peng (kr)"),
        td(summed[1].formatFloat(ffDecimal, 2))
      )
    )
  )


# the js stuff

when defined(js):
  import dom

  var month = WorkMonth()  # global month


  template getValue(e: untyped): untyped =
    ## Cast to get form element value
    OptionElement(e).value


  proc updateTables*() {.exportc.} =
    ## Update tables on page
    # don't update if no data
    if month.onCalls.len == 0:
      return

    let
      salary = parseInt $getElementById("manadslon").getValue
      comp = month.getCompensation
      pay = comp.getPayment(salary)
      summed = pay.getPaymentSummary()

    var contents = ""
    contents.add h2("Månad")
    contents.add pay.summaryTableHtml
    contents.add pay.salaryTableHtml
    contents.add month.timeTableHtml

    var
      details = summary("Detalj per beredskap")
      i = 0

    for call in month.onCalls:
      # print every call in a separate table
      let
        callComp = call.getCompensation
        callPay = callComp.getPayment(salary)
      inc i
      if call.shortNotice:
        details.add h3($i & ". " & $call.kind & " &ndash; kort varsel")
      else:
        details.add h3($i & ". " & $call.kind)

      details.add callPay.summaryTableHtml
      details.add callPay.salaryTableHtml
      details.add call.timeTableHtml

    contents.add details(details)
    getElementById("tabell").innerHtml = contents.cstring


  proc addOnCall*() {.exportc.} =
    ## Entry point for adding data

    let
      # allow empty input
      hoursOtherInput = getElementById("beredskapTimmarAnnan").getValue
      hoursOther = if hoursOtherInput != "".cstring: parseFloat ($hoursOtherInput).replace(",", ".") else: 0.0

      hoursWeekendInput = getElementById("beredskapTimmarHelg").getValue
      hoursWeekend = if hoursWeekendInput != "".cstring: parseFloat ($hoursWeekendInput).replace(",", ".") else: 0.0

      kind: OnCallType = if getElementById("beredskapsTypA").checked:
        berA
      elif getElementById("beredskapsTypB").checked:
        berB
      else:
        jour
      shortNotice = getElementById("kortVarsel").checked

    # skip empty inputs
    if hoursOther == 0.0 and hoursWeekend == 0.0:
      return

    var b = initOnCall(kind, hoursOther, hoursWeekend, shortNotice)

    b.addWork(
      other,
      parseInt($getElementById("arbetadeMinAnnan").getValue)
    )
    b.addWork(
      evening,
      parseInt($getElementById("arbetadeMinVardagkvall").getValue)
    )
    b.addWork(
      night,
      parseInt($getElementById("arbetadeMinNatt").getValue)
    )
    b.addWork(
      weekend,
      parseInt($getElementById("arbetadeMinHelg").getValue)
    )
    b.addWork(
      holiday,
      parseInt($getElementById("arbetadeMinStorhelg").getValue)
    )

    month.addOnCall b

    updateTables()
    FormElement(getElementbyId("calc")).reset()  # clear form


when isMainModule:
  import strformat

  func salaryTable(pay: Payment): string =
    ## Pretty-print salary
    var s = fmt"""{"":20} {"Antal":>8} {"Apris":>8} {"Belopp":>8}"""
    s.add "\n"
    for t in pay.low .. pay.high:
      # skip where there is nothing to show
      if pay[t][antal] == 0.0: continue
      if t in {berAtid, berBtid, jourTid, arbtid10tid, arbtid15tid, arbtid20tid, arbtid40tid, arbtid10kvtid, arbtid15kvtid, arbtid20kvtid}:
        s.add fmt"{t:20} {pay[t][antal]:>8.2f}"
      else:
        s.add fmt"{t:20} {pay[t][antal]:>8.2f} {pay[t][apris]:>8.2f} {pay[t][belopp]:>8.2f}"
      s.add "\n"

    result = s

  func summaryTable(summed: (float, float)): string =
    ## Pretty-print summary table
    var s = "-----------\n"
    s.add fmt"Tid     {summed[0]:>8.2f} h"
    s.add "\n"
    s.add fmt"Pengar  {summed[1]:>8.2f} kr"
    s.add "\n"
    result = s


proc test() =
  var
    month: WorkMonth
    call = vardag()
    call2 = helg()
    call3 = helg()
    call4 = helg()  # will surpass 330 limit here
    call5 = initOnCall(berB, 15.5, 2.0)
    call6 = initOnCall(jour, 65.5, 2.0)

  call.addWork(other, 30)
  call.addWork(evening, 60)
  call.addWork(night, 45)
  #month.addOnCall call

  call2.addWork(weekend, 20)
  # month.addOnCall call2

  call3.addWork(holiday, 70)
  # month.addOnCall call3

  # month.addOnCall call4

  call5.addWork(other, 30)
  call5.addWork(evening, 20)
  call5.addWork(night, 45)
  month.addOnCall call5

  month.addOnCall call6

  let
    comp = month.getCompensation
    pay = comp.getPayment(50000)
    summed = pay.getPaymentSummary()
  echo pay.salaryTable
  echo summed.summaryTable


when isMainModule and not defined(js):
  test()
