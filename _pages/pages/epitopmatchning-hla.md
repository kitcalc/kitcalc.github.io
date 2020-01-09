title: Epitopmatchning HLA
created: 2018-02-09
updated: 2020-01-08
summary: Epitopmatchning HLA för t.ex. transplantation och trombocytrefraktäritet.
js: js/epitopes.js
---

Allel- och epitopdata är extraherade från
[HLAMatchmaker](http://www.epitopes.net/) version 2
(`4ABCEpletMatchingVs02prototype.xlsb` och `5DRDQDPMatchingVs2.2.xlsb`).


## Länkar och information

- [HLA - Epitope Registry](http://epregistry.ufpi.br/)
- Artiklar om [HLAMatchmaker](https://www.ncbi.nlm.nih.gov/pubmed/?term=hlamatchmaker).


### Riskgrupp för primär immunisering vid njurtransplantation

Wiebe C, et al. HLA-DR/DQ molecular mismatch: A prognostic biomarker for primary
alloimmunity. Am J Transplant. 2019 Jun;19(6):1708-1719.
PMID [30414349](https://www.ncbi.nlm.nih.gov/pubmed/30414349).

Frågor som ej besvaras av artikeln

* ska alla fyra kombinationer av DQA1 och DQB1 räknas med?
* ska overifierade eplets räknas med?

För riskgruppering krävs DRB1, DRB3/4/5, DQA1 och DQB1 för recipient och donator
(fält märkta <sup>†</sup>).


## Inmatning

<form action="javascript:showMismatchedEplets()">
    <fieldset>
        <legend>Recipient</legend>

        <label for="recA1">HLA-A</label>
        <select id="recA1"></select>
        <select id="recA2"></select>
        <br>

        <label for="recB1">HLA-B</label>
        <select id="recB1"></select>
        <select id="recB2"></select>
        <br>

        <label for="recC1">HLA-C</label>
        <select id="recC1"></select>
        <select id="recC2"></select>
        <br>

        <label for="recDRB1_1">HLA-DRB1<sup>†</sup></label>
        <select id="recDRB1_1"></select>
        <select id="recDRB1_2"></select>
        <br>

        <label for="recDRB345">HLA-DRB3/4/5<sup>†</sup></label>
        <select id="recDRB345_1"></select>
        <select id="recDRB345_2"></select>
        <br>

        <label for="recDQA1_1">HLA-DQA1<sup>†</sup></label>
        <select id="recDQA1_1"></select>
        <select id="recDQA1_2"></select>
        <br>

        <label for="recDQB1_1">HLA-DQB1<sup>†</sup></label>
        <select id="recDQB1_1"></select>
        <select id="recDQB1_2"></select>
        <br>

        <label for="recDPA1_1">HLA-DPA1</label>
        <select id="recDPA1_1"></select>
        <select id="recDPA1_2"></select>
        <br>

        <label for="recDPB1_1">HLA-DPB1</label>
        <select id="recDPB1_1"></select>
        <select id="recDPB1_2"></select>
        <br>
    </fieldset>

    <fieldset>
        <legend>Donator</legend>

        <label for="donA1">HLA-A</label>
        <select id="donA1"></select>
        <select id="donA2"></select>
        <br>

        <label for="donB1">HLA-B</label>
        <select id="donB1"></select>
        <select id="donB2"></select>
        <br>

        <label for="donC1">HLA-C</label>
        <select id="donC1"></select>
        <select id="donC2"></select>
        <br>

        <label for="donDRB1_1">HLA-DRB1<sup>†</sup></label>
        <select id="donDRB1_1"></select>
        <select id="donDRB1_2"></select>
        <br>

        <label for="donDRB345">HLA-DRB3/4/5<sup>†</sup></label>
        <select id="donDRB345_1"></select>
        <select id="donDRB345_2"></select>
        <br>

        <label for="donDQA1_1">HLA-DQA1<sup>†</sup></label>
        <select id="donDQA1_1"></select>
        <select id="donDQA1_2"></select>
        <br>

        <label for="donDQB1_1">HLA-DQB1<sup>†</sup></label>
        <select id="donDQB1_1"></select>
        <select id="donDQB1_2"></select>
        <br>

        <label for="donDPA1_1">HLA-DPA1</label>
        <select id="donDPA1_1"></select>
        <select id="donDPA1_2"></select>
        <br>

        <label for="donDPB1_1">HLA-DPB1</label>
        <select id="donDPB1_1"></select>
        <select id="donDPB1_2"></select>
        <br>
    </fieldset>

    <button type="button" onclick="javascript:showMismatchedEplets()">Jämför</button>
    <input type="reset" value="Rensa">
</form>


## Riskkategori (Wiebe et al. 2019)

<table>
    <tbody>
        <tr>
            <td>Riskkategori</td>
            <td id="wiebeCategory"></td>
        </tr>
        <tr>
            <td>Max mismatch DRB1/3/4/5</td>
            <td id="maxMismatchDRB"></td>
        </tr>
        <tr>
            <td>Allel DRB1/3/4/5</td>
            <td id="maxMismatchAlleleDRB"></td>
        </tr>
        <tr>
            <td>Max mismatch DQA1 + DQB1</td>
            <td id="maxMismatchDQAB"></td>
        </tr>
        <tr>
            <td>Alleler DQA1 + DQB1</td>
            <td id="maxMismatchAlleleDQAB"></td>
        </tr>
    </tbody>
</table>


## Mismatchade eplets (rejektionsriktning)

Verifierade epitoper är de som har visats kunna ge upphov till antikropp,
övriga är teoretiska.

<table>
    <thead>
        <tr>
            <th>Locus</th>
            <th>Antal</th>
            <th>Eplets</th>
        </tr>
    </thead>
    <tbody>
        <!-- Total -->
        <tr>
            <td>Totalt</td>
            <td id="mmEpletCountTotal"></td>
            <td></td>
        </tr>
        <tr>
            <td>Totalt (verifierade)</td>
            <td id="mmEpletCountTotalAbver"></td>
            <td></td>
        </tr>

        <!-- ABC -->
        <tr>
            <td>ABC</td>
            <td id="mmEpletCountABC"></td>
            <td id="mmMismatchedEpletsABC"></td>
        </tr>
        <tr>
            <td>ABC (verifierade)</td>
            <td id="mmEpletCountABCAbver"></td>
            <td id="mmMismatchedEpletsABCAbver"></td>
        </tr>

        <!-- DRB -->
        <tr>
            <td>DRB</td>
            <td id="mmEpletCountDRB"></td>
            <td id="mmMismatchedEpletsDRB"></td>
        </tr>
        <tr>
            <td>DRB (verifierade)</td>
            <td id="mmEpletCountDRBAbver"></td>
            <td id="mmMismatchedEpletsDRBAbver"></td>
        </tr>

        <!-- DQA1 -->
        <tr>
            <td>DQA1</td>
            <td id="mmEpletCountDQA1"></td>
            <td id="mmMismatchedEpletsDQA1"></td>
        </tr>
        <tr>
            <td>DQA1 (verifierade)</td>
            <td id="mmEpletCountDQA1Abver"></td>
            <td id="mmMismatchedEpletsDQA1Abver"></td>
        </tr>

        <!-- DQB1 -->
        <tr>
            <td>DQB1</td>
            <td id="mmEpletCountDQB1"></td>
            <td id="mmMismatchedEpletsDQB1"></td>
        </tr>
        <tr>
            <td>DQB1 (verifierade)</td>
            <td id="mmEpletCountDQB1Abver"></td>
            <td id="mmMismatchedEpletsDQB1Abver"></td>
        </tr>

        <!-- DPA1 -->
        <tr>
            <td>DPA1</td>
            <td id="mmEpletCountDPA1"></td>
            <td id="mmMismatchedEpletsDPA1"></td>
        </tr>
        <tr>
            <td>DPA1 (verifierade)</td>
            <td id="mmEpletCountDPA1Abver"></td>
            <td id="mmMismatchedEpletsDPA1Abver"></td>
        </tr>

        <!-- DPB1 -->
        <tr>
            <td>DPB1</td>
            <td id="mmEpletCountDPB1"></td>
            <td id="mmMismatchedEpletsDPB1"></td>
        </tr>
        <tr>
            <td>DPB1 (verifierade)</td>
            <td id="mmEpletCountDPB1Abver"></td>
            <td id="mmMismatchedEpletsDPB1Abver"></td>
        </tr>
    </tbody>
</table>


