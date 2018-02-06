title: P- och G-grupper
created: 2018-02-06
js: js/gpgroup.js
    js/gpgroupacc.js
summary: Bestämning av P- och G-grupper för HLA-alleler
---

Information om [P-grupper](http://hla.alleles.org/alleles/p_groups.html) och
[G-grupper](http://hla.alleles.org/alleles/g_groups.html).

<form id="gpgroupform">
    <fieldset>
        <legend>Inmatning</legend>

        <label for="allele">Ange allel</label>
        <input type="text" id="allele">
        <!-- type="button" is important, or form will reload page on every click -->
        <button type="button" onclick="javascript:lookupAllele()">Slå upp</button>
        <!-- For help text output -->
        <div id="helptext"></div>
    </fieldset>

    <fieldset>
        <legend>Allelinfo</legend>
        <table>
            <tr>
                <td>Länk till info</td>
                <td id="alleleinfo"></td>
            </tr>
        </table>
    </fieldset>

    <fieldset>
        <legend>P-grupper</legend>

        <table>
            <tr>
                <td>P-grupp</td>
                <td id="pgroup"></td>
            </tr>
            <tr>
                <td>Antal i grupp</td>
                <td id="pgrouplen"></td>
            <tr>
                <td>Allel(er)</td>
                <td id="pother"></td>
            </tr>
        </table>
    </fieldset>

    <fieldset>
        <legend>G-grupper</legend>

        <table>
            <tr>
                <td>G-grupp</td>
                <td id="ggroup"></td>
            </tr>
            <tr>
                <td>Antal i grupp</td>
                <td id="ggrouplen"></td>
            <tr>
                <td>Allel(er)</td>
                <td id="gother"></td>
            </tr>
        </table>
    </fieldset>
</form>