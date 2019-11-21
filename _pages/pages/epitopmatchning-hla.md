title: Epitopmatchning HLA
created: 2018-02-09
updated: 2018-03-12
summary: Epitopmatchning HLA för t.ex. transplantation och trombocytrefraktäritet.
js: js/epitopes.js
---

Att minimera antalet allogena HLA-epitoper på transfunderade trombocyter har
visats förbättra trombocytöverlevnad. Liknande resultat har setts vid
njurtransplantation. Verktyget nedan kan användas för att beräkna antalet
mismatchade HLA-epitoper (i HvG-riktning). Allel- och epitopdata är extraherade
från [HLAMatchmaker](http://www.epitopes.net/).

Overifierade epitoper är epitoper som är teoretiska och som ej visats förekomma
i humana sera.


## Länkar och information

[HLA - Epitope Registry](http://epregistry.ufpi.br/)

Artiklar av Rene Duquesnoy om
[epitopmatchning](https://www.ncbi.nlm.nih.gov/pubmed/?term=duquesnoy+hlamatchmaker).


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

        <label for="recDRB1_1">HLA-DRB1</label>
        <select id="recDRB1_1"></select>
        <select id="recDRB1_2"></select>
        <br>

        <label for="recDRB345">HLA-DRB3/4/5</label>
        <select id="recDRB345_1"></select>
        <select id="recDRB345_2"></select>
        <br>

        <label for="recDQA1_1">HLA-DQA1</label>
        <select id="recDQA1_1"></select>
        <select id="recDQA1_2"></select>
        <br>

        <label for="recDQB1_1">HLA-DQB1</label>
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

        <label for="donDRB1_1">HLA-DRB1</label>
        <select id="donDRB1_1"></select>
        <select id="donDRB1_2"></select>
        <br>

        <label for="donDRB345">HLA-DRB3/4/5</label>
        <select id="donDRB345_1"></select>
        <select id="donDRB345_2"></select>
        <br>

        <label for="donDQA1_1">HLA-DQA1</label>
        <select id="donDQA1_1"></select>
        <select id="donDQA1_2"></select>
        <br>

        <label for="donDQB1_1">HLA-DQB1</label>
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

    <label for="includeOther">Inkludera overifierade eplets</label>
    <input type="checkbox" id="includeOther" value="checked">
    <br>

    <button type="button" onclick="javascript:showMismatchedEplets()">Jämför</button>
    <input type="reset" value="Rensa">

    <fieldset>
        <legend>Mismatchade eplets (HvG)</legend>

        <table>
            <!-- Sum of mismatches -->
            <tr>
                <td>Antal HvG-mismatchade eplets totalt</td>
                <td id="hvgEpletCountTotal"></td>
            </tr>
            <!-- ABC -->
            <tr>
                <td>Antal HvG-mismatchade eplets ABC</td>
                <td id="hvgEpletCountABC"></td>
            </tr>
            <tr>
                <td>HvG-mismatchade eplets ABC</td>
                <td id="hvgMismatchedEpletsABC"></td>
            </tr>
            <!-- DRB -->
            <tr>
                <td>Antal HvG-mismatchade eplets DRB</td>
                <td id="hvgEpletCountDRB"></td>
            </tr>
            <tr>
                <td>HvG-mismatchade eplets DRB</td>
                <td id="hvgMismatchedEpletsDRB"></td>
            </tr>
            <!-- DQA1 -->
            <tr>
                <td>Antal HvG-mismatchade eplets DQA1</td>
                <td id="hvgEpletCountDQA1"></td>
            </tr>
            <tr>
                <td>HvG-mismatchade eplets DQA1</td>
                <td id="hvgMismatchedEpletsDQA1"></td>
            </tr>
            <!-- DQB1 -->
            <tr>
                <td>Antal HvG-mismatchade eplets DQB1</td>
                <td id="hvgEpletCountDQB1"></td>
            </tr>
            <tr>
                <td>HvG-mismatchade eplets DQB1</td>
                <td id="hvgMismatchedEpletsDQB1"></td>
            </tr>
            <!-- DPA1 -->
            <tr>
                <td>Antal HvG-mismatchade eplets DPA1</td>
                <td id="hvgEpletCountDPA1"></td>
            </tr>
            <tr>
                <td>HvG-mismatchade eplets DPA1</td>
                <td id="hvgMismatchedEpletsDPA1"></td>
            </tr>
            <!-- DPB1 -->
            <tr>
                <td>Antal HvG-mismatchade eplets DPB1</td>
                <td id="hvgEpletCountDPB1"></td>
            </tr>
            <tr>
                <td>HvG-mismatchade eplets DPB1</td>
                <td id="hvgMismatchedEpletsDPB1"></td>
            </tr>
        </table>
    </fieldset>

</form>