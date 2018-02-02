import strutils

##[
Beräkning av jour- och beredskapsersättning
===========================================

Exempel

.. code-block:: nim

    # definiera månad
    var nov = initErsättning(10000)

    # ny beredskap
    var nov20 = initBeredskap(15.5, 0.0, berA, false)
    nov20.addArbeteAnnan(0.5)

    # lägg till beredskapen till månad
    nov.addBeredskap(nov20)

    # andra beredskap
    var nov28 = initVardagsjour(berA)
    nov28.addArbeteAnnan(0.5)

    # lägg till beredskapen till månad
    nov.addBeredskap(nov28)

    # skriv ersättningstabell
    echo nov

]##

type
    Ersättning* = object ##\
        ## En samlad ersättning för beredskaper, vanligen månad
        månadslön*: Natural  ## Månadslön i kronor
        beredskaper*: seq[Beredskap]  ## Beredskaperna

    BeredskapsTyp* = enum ##\
        ## Typ av beredskap, ``A`` eller ``B``
        berA,
        berB

    Beredskap* = object ##\
        ## Ett beredskapstillfälle
        arbetadeTimmarAnnan*: float  ## Arbetade timmar annan tid
        arbetadeTimmarVardagkväll*: float  ## Arbetade timmar vardag 21-24
        arbetadeTimmarNatt*: float  ## Arbetade timmar vardag 00-07
        arbetadeTimmarHelg*: float  ## Arbetade timmar helg
        arbetadeTimmarStorhelg*: float  ## Arbetade timmar storhelg

        beredskapTimmarAnnan*: float  ## Timmar i beredskap annan tid
        beredskapTimmarHelg*: float  ## Timmar i beredskap helg

        kind*: BeredskapsTyp  ## Typ av beredskap
        kortVarsel*: bool  ## Indikerar kort varsel


const
    tidkvot = 0.7
    pengkvot = 1.0 - tidkvot

    ersättningskvotAnnan: array[BeredskapsTyp, float] = [0.15, 0.1]
    ersättningskvotHelg: array[BeredskapsTyp, float] = [0.25, 0.2]

    ersättningKvBer: array[BeredskapsTyp, float] = [0.2, 0.15]
    ersättningArbeteKv = 1.5


proc initBeredskap*(beredskapTimmarAnnan, beredskapTimmarHelg: float,
                    kind: BeredskapsTyp, kortVarsel = false): Beredskap =
    ## Nytt beredskaptillfälle. Vanlig vardag beredskap A definieras som
    ##
    ## .. code-block:: nim
    ##
    ##   initBeredskap(15.5, 0.0, berA, false)
    result = Beredskap(beredskapTimmarAnnan: beredskapTimmarAnnan,
                       beredskapTimmarHelg: beredskapTimmarHelg,
                       kind: kind,
                       kortVarsel: kortVarsel)

template initVardagsjour*(kind: BeredskapsTyp): Beredskap =
    ## Mall för vanlig bereskap vardag.
    initBeredskap(15.5, 0.0, kind, false)

template initHelgjour*(kind: BeredskapsTyp): Beredskap =
    ## Mall för vanlig beredskap helg över fredag-måndag..
    initBeredskap(1.5, 62.0, kind, false)

proc addArbeteAnnan*(ber: var Beredskap, timmar: float) =
    ## Lägger till arbetad tid till ``ber`` under annan tid.
    ber.arbetadeTimmarAnnan += timmar
    ber.beredskapTimmarAnnan -= timmar

proc addArbeteVardagkväll*(ber: var Beredskap, timmar: float) =
    ## Lägger till arbetad tid till ``ber`` under vardagskväll.
    ber.arbetadeTimmarVardagkväll += timmar
    ber.beredskapTimmarAnnan -= timmar

proc addArbeteNatt*(ber: var Beredskap, timmar: float) =
    ## Lägger till arbetad tid till ``ber`` under natt.
    ber.arbetadeTimmarNatt += timmar
    ber.beredskapTimmarAnnan -= timmar

proc addArbeteHelg*(ber: var Beredskap, timmar: float) =
    ## Lägger till arbetad tid till ``ber`` under helg.
    ber.arbetadeTimmarHelg += timmar
    ber.beredskapTimmarHelg -= timmar

proc addArbeteStorhelg*(ber: var Beredskap, timmar: float) =
    ## Lägger till arbetad tid till ``ber`` under storhelg.
    ber.arbetadeTimmarStorhelg += timmar
    ber.beredskapTimmarHelg -= timmar

proc ersattBeredskapstidAnnan(ber: Beredskap): float =
    ## Ersatt beredskapstid under annan tid, i timmar.
    result = ber.beredskapTimmarAnnan * ersättningskvotAnnan[ber.kind]
    if ber.kortVarsel:
        result += ber.beredskapTimmarAnnan * ersättningKvBer[ber.kind]

proc ersattBeredskapstidHelg(ber: Beredskap): float =
    ## Ersatt beredskapstid under helgtid, i timmar.
    result = ber.beredskapTimmarHelg * ersättningskvotHelg[ber.kind]
    if ber.kortVarsel:
        result += ber.beredskapTimmarHelg * ersättningKvBer[ber.kind]

proc ersattBeredskapstidA(ber: Beredskap): float =
    ## Ersatt beredskapstid A, totalt, i timmar.
    if ber.kind == berA:
        result = ber.ersattBeredskapstidAnnan + ber.ersattBeredskapstidHelg

proc ersattBeredskapstidB(ber: Beredskap): float =
    ## Ersatt beredskapstid B, totalt, i timmar.
    if ber.kind == berB:
        result = ber.ersattBeredskapstidAnnan + ber.ersattBeredskapstidHelg


# Nedanstående hamnar på lönespecen

proc ersBerAtid*(ber: Beredskap): float =
    ## Ersättning "Ber A tid" i antal timmar.
    result = ber.ersattBeredskapstidA * tidkvot

proc ersBerApengAntal*(ber: Beredskap): float =
    ## Ersättning "Ber A peng" i antal timmar.
    result = ber.ersattBeredskapstidA * pengkvot

proc ersBerBtid*(ber: Beredskap): float =
    ## Ersättning "Ber B tid" i antal timmar.
    result = ber.ersattBeredskapstidB * tidkvot

proc ersBerBpengAntal*(ber: Beredskap): float =
    ## Ersättning "Ber B peng" i antal timmar.
    result = ber.ersattBeredskapstidB * pengkvot

proc ersBerA440*(ber: Beredskap): float =
    ## Ersättning "Ber A 1/440" i antal timmar.
    result = ber.ersattBeredskapstidA

proc ersBerB440*(ber: Beredskap): float =
    ## Ersättning "Ber B 1/440" i antal timmar.
    result = ber.ersattBeredskapstidB

proc ersArbtid10tidAntal*(ber: Beredskap): float =
    ## Ersättning "Arbtid 1.0 tid" i antal timmar.
    if not ber.kortVarsel:
        result = ber.arbetadeTimmarAnnan * tidkvot

proc ersArbtid10pengAntal*(ber: Beredskap): float =
    ## Ersättning "Arbtid 1.0 peng" i antal timmar.
    if not ber.kortVarsel:
        result = ber.arbetadeTimmarAnnan * pengkvot

proc ersArbtid15tidAntal*(ber: Beredskap): float =
    ## Ersättning "Arbtid 1.5 tid" i antal timmar.
    if not ber.kortVarsel:
        result = ber.arbetadeTimmarVardagkväll * tidkvot * 1.5

proc ersArbtid15pengAntal*(ber: Beredskap): float =
    ## Ersättning "Arbtid 1.5 peng" i antal timmar.
    if not ber.kortVarsel:
        result = ber.arbetadeTimmarVardagkväll * pengkvot * 1.5

proc ersArbtid20tidAntal*(ber: Beredskap): float =
    ## Ersättning "Arbtid 2.0 tid" i antal timmar.
    if not ber.kortVarsel:
        let tid = ber.arbetadeTimmarNatt + ber.arbetadeTimmarHelg
        result = tid * tidkvot * 2.0

proc ersArbtid20pengAntal*(ber: Beredskap): float =
    ## Ersättning "Arbtid 2.0 peng" i antal timmar.
    if not ber.kortVarsel:
        let tid = ber.arbetadeTimmarNatt + ber.arbetadeTimmarHelg
        result = tid * pengkvot * 2.0

proc ersArbtid40tidAntal*(ber: Beredskap): float =
    ## Ersättning "Arbtid 4.0 tid" i antal timmar.
    result = ber.arbetadeTimmarStorhelg * tidkvot * 4.0

proc ersArbtid40pengAntal*(ber: Beredskap): float =
    ## Ersättning "Arbtid 4.0 peng" i antal timmar.
    result = ber.arbetadeTimmarStorhelg * pengkvot * 4.0

# Kort varsel

proc ersArbtid10KvTidAntal*(ber: Beredskap): float =
    ## Ersättning "Arbtid 1.0 tid kv" i antal timmar.
    if ber.kortVarsel:
        let tid = ber.arbetadeTimmarVardagkväll * tidkvot
        result = tid + tid * ersättningArbeteKv

proc ersArbtid10KvPengAntal*(ber: Beredskap): float =
    ## Ersättning "Arbtid 1.0 peng kv" i antal timmar.
    if ber.kortVarsel:
        let tid = ber.arbetadeTimmarAnnan * pengkvot
        result = tid + tid * ersättningArbeteKv

proc ersArbtid15KvTidAntal*(ber: Beredskap): float =
    ## Ersättning "Arbtid 1.5 tid kv" i antal timmar.
    if ber.kortVarsel:
        let tid = ber.arbetadeTimmarVardagkväll * tidkvot
        result = tid * 1.5 + tid * ersättningArbeteKv

proc ersArbtid15KvPengAntal*(ber: Beredskap): float =
    ## Ersättning "Arbtid 1.5 peng kv" i antal timmar.
    if ber.kortVarsel:
        let tid = ber.arbetadeTimmarVardagkväll * pengkvot
        result = tid * 1.5 + tid * ersättningArbeteKv

proc ersArbtid20KvTidAntal*(ber: Beredskap): float =
    ## Ersättning "Arbtid 2.0 tid kv" i antal timmar.
    if ber.kortVarsel:
        let tid = (ber.arbetadeTimmarNatt + ber.arbetadeTimmarHelg) * tidKvot
        result = tid * 2.0 + tid * ersättningArbeteKv

proc ersArbtid20KvPengAntal*(ber: Beredskap): float =
    ## Ersättning "Arbtid 2.0 peng kv" i antal timmar.
    if ber.kortVarsel:
        let tid = (ber.arbetadeTimmarNatt + ber.arbetadeTimmarHelg) * pengKvot
        result = tid * 2.0 + tid * ersättningArbeteKv

# Ersättning för en hel månad

proc initErsättning*(månadslön: int, beredskaper: seq[Beredskap] = @[]): Ersättning =
    ## Ny ersättning för en månads jour och beredskap.
    result = Ersättning(månadslön: månadslön, beredskaper: beredskaper)

proc månadslön137*(ers: Ersättning): float =
    ## Månadslön 1/137
    result = ers.månadslön / 137

proc månadslön440*(ers: Ersättning): float =
    ## Månadslön 1/440
    result = ers.månadslön / 440

proc addBeredskap*(ers: var Ersättning, ber: Beredskap) =
    ## Lägg till beredskap till denna månads ersättning
    ers.beredskaper.add ber

# Nedanstående hamnar på lönespecen

# Beredskap A

proc ersBerAtid*(ers: Ersättning): float =
    ## Ersättning "Ber A tid" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersBerAtid

proc ersBerApengAntal*(ers: Ersättning): float =
    ## Ersättning "Ber A peng" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersBerApengAntal

proc ersBerApengKronor*(ers: Ersättning): float =
    ## Ersättning "Ber A peng" i kronor
    result = ers.ersBerApengAntal * ers.månadslön137

proc ersBerA440antal*(ers: Ersättning): float =
    ## Ersättning "Ber A 1/440" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersBerA440

proc ersBerA440peng*(ers: Ersättning): float =
    ## Ersättning "Ber A 1/440" i kronor
    result = ers.ersBerA440antal * ers.månadslön440

# Beredskap B

proc ersBerBtid*(ers: Ersättning): float =
    ## Ersättning "Ber B tid" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersBerBtid

proc ersBerBpengAntal*(ers: Ersättning): float =
    ## Ersättning "Ber B peng" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersBerBpengAntal

proc ersBerBpengKronor*(ers: Ersättning): float =
    ## Ersättning "Ber B peng" i kronor
    result = ers.ersBerBpengAntal * ers.månadslön137

proc ersBerB440antal*(ers: Ersättning): float =
    ## Ersättning "Ber B 1/440" i kronor
    for ber in ers.beredskaper:
        result += ber.ersBerB440

proc ersBerB440peng*(ers: Ersättning): float =
    ## Ersättning "Ber A 1/440" i kronor
    result = ers.ersBerB440antal * ers.månadslön440

# Arbete

proc ersArbtid10tidAntal*(ers: Ersättning): float =
    ## Ersättning "Arbtid 1.0 tid" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersArbtid10tidAntal

proc ersArbtid10pengAntal*(ers: Ersättning): float =
    ## Ersättning "Arbtid 1.0 peng" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersArbtid10pengAntal

proc ersArbtid10pengKronor*(ers: Ersättning): float =
    ## Ersättning "Arbtid 1.0 peng" i kronor
    result = ers.ersArbtid10pengAntal * ers.månadslön137

proc ersArbtid15tidAntal*(ers: Ersättning): float =
    ## Ersättning "Arbtid 1.5 tid" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersArbtid15tidAntal

proc ersArbtid15pengAntal*(ers: Ersättning): float =
    ## Ersättning "Arbtid 1.5 peng" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersArbtid15pengAntal

proc ersArbtid15pengKronor*(ers: Ersättning): float =
    ## Ersättning "Arbtid 1.5 peng" i kronor
    result = ers.ersArbtid15pengAntal * ers.månadslön137

proc ersArbtid20tidAntal*(ers: Ersättning): float =
    ## Ersättning "Arbtid 2.0 tid" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersArbtid20tidAntal

proc ersArbtid20pengAntal*(ers: Ersättning): float =
    ## Ersättning "Arbtid 2.0 peng" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersArbtid20pengAntal

proc ersArbtid20pengKronor*(ers: Ersättning): float =
    ## Ersättning "Arbtid 2.0 peng" i kronor
    result = ers.ersArbtid20pengAntal * ers.månadslön137

proc ersArbtid40tidAntal*(ers: Ersättning): float =
    ## Ersättning "Arbtid 4.0 tid" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersArbtid40tidAntal

proc ersArbtid40pengAntal*(ers: Ersättning): float =
    ## Ersättning "Arbtid 4.0 peng" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersArbtid40pengAntal

proc ersArbtid40pengKronor*(ers: Ersättning): float =
    ## Ersättning "Arbtid 4.0 peng" i kronor
    result = ers.ersArbtid40pengAntal * ers.månadslön137

# Kort varsel

proc ersArbtid10KvTidAntal*(ers: Ersättning): float =
    ## Ersättning "Arbtid 1.0 tid kv" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersArbtid10KvTidAntal

proc ersArbtid10KvPengAntal*(ers: Ersättning): float =
    ## Ersättning "Arbtid 1.0 peng kv" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersArbtid10KvPengAntal

proc ersArbtid10KvPengKronor*(ers: Ersättning): float =
    ## Ersättning "Arbtid 1.0 peng kv" i kronor
    result = ers.ersArbtid10KvPengAntal * ers.månadslön137

proc ersArbtid15KvTidAntal*(ers: Ersättning): float =
    ## Ersättning "Arbtid 1.5 tid kv" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersArbtid15KvTidAntal

proc ersArbtid15KvPengAntal*(ers: Ersättning): float =
    ## Ersättning "Arbtid 1.5 peng kv" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersArbtid15KvPengAntal

proc ersArbtid15KvPengKronor*(ers: Ersättning): float =
    ## Ersättning "Arbtid 1.5 peng kv" i kronor
    result = ers.ersArbtid15KvPengAntal * ers.månadslön137

proc ersArbtid20KvTidAntal*(ers: Ersättning): float =
    ## Ersättning "Arbtid 2.0 tid kv" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersArbtid20KvTidAntal

proc ersArbtid20KvPengAntal*(ers: Ersättning): float =
    ## Ersättning "Arbtid 2.0 peng kv" i antal timmar
    for ber in ers.beredskaper:
        result += ber.ersArbtid20KvPengAntal

proc ersArbtid20KvPengKronor*(ers: Ersättning): float =
    ## Ersättning "Arbtid 2.0 peng kv" i kronor
    result = ers.ersArbtid20KvPengAntal * ers.månadslön137


proc `$`*(ers: Ersättning): string =
    ## Returnerar en tabell med ersättningar.

    const colwidth = 12

    template ff(f: float): string = formatFloat(f, ffDecimal, 2).align(colwidth)

    let summaTid =
        ers.ersBerAtid + ers.ersBerBtid +
        ers.ersArbtid10tidAntal + ers.ersArbtid15tidAntal +
        ers.ersArbtid20tidAntal + ers.ersArbtid40tidAntal +
        ers.ersArbtid10KvTidAntal + ers.ersArbtid15KvTidAntal +
        ers.ersArbtid20KvTidAntal


    let summaBelopp =
        ers.ersBerApengKronor + ers.ersBerA440peng +
        ers.ersBerBpengKronor + ers.ersBerB440peng +
        ers.ersArbtid10pengKronor + ers.ersArbtid15pengKronor +
        ers.ersArbtid20pengKronor + ers.ersArbtid40pengKronor +
        ers.ersArbtid10KvPengKronor + ers.ersArbtid15KvPengKronor +
        ers.ersArbtid20KvPengKronor


    result = """
Månadslön:           $#
Fördelning tid/peng: $# / $#

                    $#$#$#
Ber A tid           $#
Ber A peng          $#$#$#
Ber A 1/440         $#$#$#

Ber B tid           $#
Ber B peng          $#$#$#
Ber B 1/440         $#$#$#

Arbtid 1.0 tid      $#
Arbtid 1.0 peng     $#$#$#
Arbtid 1.0 tid kv   $#
Arbtid 1.0 peng kv  $#$#$#

Arbtid 1.5 tid      $#
Arbtid 1.5 peng     $#$#$#
Arbtid 1.5 tid kv   $#
Arbtid 1.5 peng kv  $#$#$#

Arbtid 2.0 tid      $#
Arbtid 2.0 peng     $#$#$#
Arbtid 2.0 tid kv   $#
Arbtid 2.0 peng kv  $#$#$#

Arbtid 4.0 tid      $#
Arbtid 4.0 peng     $#$#$#
--------------------------
Summa tid (h) $#
Summa kronor  $#
"""

    result = result.format(
        ers.månadslön,
        tidkvot, pengkvot,

        "Antal".align(colwidth), "Apris".align(colwidth), "Belopp".align(colwidth),

        ers.ersBerAtid.ff,
        ers.ersBerApengAntal.ff, ers.månadslön137.ff, ers.ersBerApengKronor.ff,
        ers.ersBerA440antal.ff, ers.månadslön440.ff, ers.ersBerA440peng.ff,

        ers.ersBerBtid.ff,
        ers.ersBerBpengAntal.ff, ers.månadslön137.ff, ers.ersBerBpengKronor.ff,
        ers.ersBerB440antal.ff, ers.månadslön440.ff, ers.ersBerB440peng.ff,

        ers.ersArbtid10tidAntal.ff,
        ers.ersArbtid10pengAntal.ff, ers.månadslön137.ff, ers.ersArbtid10pengKronor.ff,
        ers.ersArbtid10KvTidAntal.ff,
        ers.ersArbtid10KvPengAntal.ff, ers.månadslön137.ff, ers.ersArbtid10KvPengKronor.ff,

        ers.ersArbtid15tidAntal.ff,
        ers.ersArbtid15pengAntal.ff, ers.månadslön137.ff, ers.ersArbtid15pengKronor.ff,
        ers.ersArbtid15KvTidAntal.ff,
        ers.ersArbtid15KvPengAntal.ff, ers.månadslön137.ff, ers.ersArbtid15KvPengKronor.ff,

        ers.ersArbtid20tidAntal.ff,
        ers.ersArbtid20pengAntal.ff, ers.månadslön137.ff, ers.ersArbtid20pengKronor.ff,
        ers.ersArbtid20KvTidAntal.ff,
        ers.ersArbtid20KvPengAntal.ff, ers.månadslön137.ff, ers.ersArbtid20KvPengKronor.ff,

        ers.ersArbtid40tidAntal.ff,
        ers.ersArbtid40pengAntal.ff, ers.månadslön137.ff, ers.ersArbtid40pengKronor.ff,

        summaTid.ff,
        summaBelopp.ff
    )

