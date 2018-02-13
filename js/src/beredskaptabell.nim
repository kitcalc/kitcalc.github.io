#? stdtmpl | standard
# import strutils
# import beredskap
#
# proc createBeredskapTable*(ers: Ersättning): string =
#   ## Skapa tabellen med beredskaperna i HTML-format
#   result = ""
<table>
  <thead>
    <tr>
      <th></th> <!-- empty first field in header -->
    # for i, ber in ers.beredskaper:
      <th>${i+1}. Ber ${if ber.kind == berA: "A" else: "B"}${if ber.kortVarsel: " kv" else: ""}</th>
    # end for
      <th>Summa</th>
      <th>Apris</th>
      <th>Belopp</th>
    </tr>
  </thead>
  <tbody>
    # if ers.ersBerAtid > 0.0:
    <tr>
      <td>Ber A tid</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersBerAtid.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersBerAtid.formatFloat(ffDecimal, 2)}</td>
      <td></td>
      <td></td>
    </tr>
    # end if
    # if ers.ersBerApengAntal > 0.0:
    <tr>
      <td>Ber A peng</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersBerApengAntal.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersBerApengAntal.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.månadslön137.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.ersBerApengKronor.formatFloat(ffDecimal, 2)}</td>
    </tr>
    # end if
    # if ers.ersBerA440antal > 0.0:
    <tr>
      <td>Ber A 1/440</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersBerA440.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersBerA440antal.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.månadslön440.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.ersBerA440peng.formatFloat(ffDecimal, 2)}</td>
    </tr>
    # end if
    # if ers.ersBerBtid > 0.0:
    <tr>
      <td>Ber B tid</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersBerBtid.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersBerBtid.formatFloat(ffDecimal, 2)}</td>
      <td></td>
      <td></td>
    </tr>
    # end if
    # if ers.ersBerBpengAntal > 0.0:
    <tr>
      <td>Ber B peng</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersBerBpengAntal.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersBerBpengAntal.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.månadslön137.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.ersBerBpengKronor.formatFloat(ffDecimal, 2)}</td>
    </tr>
    # end if
    # if ers.ersBerB440antal > 0.0:
    <tr>
      <td>Ber B 1/440</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersBerB440.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersBerB440antal.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.månadslön440.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.ersBerB440peng.formatFloat(ffDecimal, 2)}</td>
    </tr>
    # end if
    # if ers.ersArbtid10tidAntal > 0.0:
    <tr>
      <td>Arbtid 1.0 tid</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersArbtid10tidAntal.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersArbtid10tidAntal.formatFloat(ffDecimal, 2)}</td>
      <td></td>
      <td></td>
    </tr>
    # end if
    # if ers.ersArbtid10pengAntal > 0.0:
    <tr>
      <td>Arbtid 1.0 peng</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersArbtid10pengAntal.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersArbtid10pengAntal.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.månadslön137.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.ersArbtid10pengKronor.formatFloat(ffDecimal, 2)}</td>
    </tr>
    # end if
    # if ers.ersArbtid10KvTidAntal > 0.0:
    <tr>
      <td>Arbtid 1.0 tid kv</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersArbtid10KvTidAntal.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersArbtid10KvTidAntal.formatFloat(ffDecimal, 2)}</td>
      <td></td>
      <td></td>
    </tr>
    # end if
    # if ers.ersArbtid10KvPengAntal > 0.0:
    <tr>
      <td>Arbtid 1.0 peng kv</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersArbtid10KvPengAntal.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersArbtid10KvPengAntal.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.månadslön137.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.ersArbtid10KvPengKronor.formatFloat(ffDecimal, 2)}</td>
    </tr>
    # end if
    # if ers.ersArbtid15tidAntal > 0.0:
    <tr>
      <td>Arbtid 1.5 tid</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersArbtid15tidAntal.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersArbtid15tidAntal.formatFloat(ffDecimal, 2)}</td>
      <td></td>
      <td></td>
    </tr>
    # end if
    # if ers.ersArbtid15pengAntal > 0.0:
    <tr>
      <td>Arbtid 1.5 peng</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersArbtid15pengAntal.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersArbtid15pengAntal.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.månadslön137.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.ersArbtid15pengKronor.formatFloat(ffDecimal, 2)}</td>
    </tr>
    # end if
    # if ers.ersArbtid15KvTidAntal > 0.0:
    <tr>
      <td>Arbtid 1.5 tid kv</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersArbtid15KvTidAntal.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersArbtid15KvTidAntal.formatFloat(ffDecimal, 2)}</td>
      <td></td>
      <td></td>
    </tr>
    # end if
    # if ers.ersArbtid15KvPengAntal > 0.0:
    <tr>
      <td>Arbtid 1.5 peng kv</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersArbtid15KvPengAntal.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersArbtid15KvPengAntal.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.månadslön137.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.ersArbtid15KvPengKronor.formatFloat(ffDecimal, 2)}</td>
    </tr>
    # end if
    # if ers.ersArbtid20tidAntal > 0.0:
    <tr>
      <td>Arbtid 2.0 tid</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersArbtid20tidAntal.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersArbtid20tidAntal.formatFloat(ffDecimal, 2)}</td>
      <td></td>
      <td></td>
    </tr>
    # end if
    # if ers.ersArbtid20pengAntal > 0.0:
    <tr>
      <td>Arbtid 2.0 peng</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersArbtid20pengAntal.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersArbtid20pengAntal.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.månadslön137.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.ersArbtid20pengKronor.formatFloat(ffDecimal, 2)}</td>
    </tr>
    # end if
    # if ers.ersArbtid20KvTidAntal > 0.0:
    <tr>
      <td>Arbtid 2.0 tid kv</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersArbtid20KvTidAntal.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersArbtid20KvTidAntal.formatFloat(ffDecimal, 2)}</td>
      <td></td>
      <td></td>
    </tr>
    # end if
    # if ers.ersArbtid20KvPengAntal > 0.0:
    <tr>
      <td>Arbtid 2.0 peng kv</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersArbtid20KvPengAntal.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersArbtid20KvPengAntal.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.månadslön137.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.ersArbtid20KvPengKronor.formatFloat(ffDecimal, 2)}</td>
    </tr>
    # end if
    # if ers.ersArbtid40tidAntal > 0.0:
    <tr>
      <td>Arbtid 4.0 tid</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersArbtid40tidAntal.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersArbtid40tidAntal.formatFloat(ffDecimal, 2)}</td>
      <td></td>
      <td></td>
    </tr>
    # end if
    # if ers.ersArbtid40pengAntal > 0.0:
    <tr>
      <td>Arbtid 4.0 peng</td>
      # for ber in ers.beredskaper:
      <td>${ber.ersArbtid40pengAntal.formatFloat(ffDecimal, 2)}</td>
      # end for
      <td>${ers.ersArbtid40pengAntal.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.månadslön137.formatFloat(ffDecimal, 2)}</td>
      <td>${ers.ersArbtid40pengKronor.formatFloat(ffDecimal, 2)}</td>
    </tr>
    # end if
  </tbody>
</table>

<h2>Summerat</h2>

<table>
  <tr>
    <td>Summa beredskap A (h)</td>
    # let summaberedskapA = ers.beredskapsTidA
    <td>${summaberedskapA.formatFloat(ffDecimal, 2)}</td>
  </tr>
  <tr>
    <td>Summa beredskap B (h)</td>
    # let summaberedskapB = ers.beredskapsTidB
    <td>${summaberedskapB.formatFloat(ffDecimal, 2)}</td>
  </tr>
  <tr>
    <td>Summa arbetad tid (h)</td>
    # let summaarbete = ers.arbetadTid
    <td>${summaarbete.formatFloat(ffDecimal, 2)}</td>
  </tr>
  <tr>
    <td>Summa tid (h)</td>
    # let summatid = ers.ersBerAtid + ers.ersBerBtid + ers.ersArbtid10tidAntal + ers.ersArbtid15tidAntal + ers.ersArbtid20tidAntal + ers.ersArbtid40tidAntal + ers.ersArbtid10KvTidAntal + ers.ersArbtid15KvTidAntal + ers.ersArbtid20KvTidAntal
    <td>${summatid.formatFloat(ffDecimal, 2)}</td>
  </tr>
  <tr>
    <td>Summa peng (kr)</td>
    # let summapeng = ers.ersBerApengKronor + ers.ersBerA440peng + ers.ersBerBpengKronor + ers.ersBerB440peng + ers.ersArbtid10pengKronor + ers.ersArbtid15pengKronor + ers.ersArbtid20pengKronor + ers.ersArbtid40pengKronor + ers.ersArbtid10KvPengKronor + ers.ersArbtid15KvPengKronor + ers.ersArbtid20KvPengKronor
    <td>${summapeng.formatFloat(ffDecimal, 2)}</td>
  </tr>
</table>


