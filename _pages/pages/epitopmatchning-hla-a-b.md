title: Epitopmatchning HLA-A,B
created: 2018-02-09
summary: Epitopmatchning för HLA-A,B för t.ex. trombocytrefraktäritet.
js: js/epitopes.js
---

Att minimera antalet allogena HLA-epitoper på transfunderade trombocyter har
visats förbättra trombocytöverlevnad. Verktyget nedan kan användas för att
beräkna antalet mismatchade HLA-epitoper (i HvG-riktning som vid transfusion).
Allel- och epitopdata är extraherade från
[HLAMatchmaker](http://www.epitopes.net/).

Overifierade epitoper är epitoper som är teoretiska och som ej visats förekomma
i humana sera.


## Länkar och information

[HLA-Epitope Registry ABC](http://epregistry.ufpi.br/index/databases/database/ABC/)

Artiklar av Rene Duquesnoy om [trombocyter och
epitopmatchning](https://www.ncbi.nlm.nih.gov/pubmed/?term=duquesnoy+platelet).


## Inmatning

<form>
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
    </fieldset>

    <label for="includeOther">Inkludera overifierade eplets</label>
    <input type="checkbox" id="includeOther" value="checked">
    <br>

    <button type="button" onclick="javascript:showMismatchedEplets()">Jämför</button>
    <input type="reset" value="Rensa">

    <fieldset>
        <legend>Mismatchade eplets (HvG)</legend>

        <table>
            <tr>
                <td>Antal HvG-mismatchade eplets</td>
                <td id="hvgEpletCount"></td>
            </tr>
            <tr>
                <td>HvG-mismatchade eplets</td>
                <td id="hvgMismatchedEplets"></td>
            </tr>
        </table>
    </fieldset>

</form>
