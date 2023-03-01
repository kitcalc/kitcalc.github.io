title: P- och G-grupper
created: 2018-02-06
updated: 2022-12-31
js: js/gpgroup.js
    js/gpgroupacc.js
summary: Bestämning av P- och G-grupper för HLA-alleler
---

Information om [P-grupper](https://hla.alleles.org/alleles/p_groups.html),
[G-grupper](https://hla.alleles.org/alleles/g_groups.html) och
[antigen](https://hla.alleles.org/antigens/index.html)

<form id="gpgroupform" action="javascript:lookupAllele()">
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
        <legend>P-grupp</legend>

        <table>
            <tr>
                <td>P-grupp</td>
                <td id="pgroup"></td>
            </tr>
            <tr>
                <td>Antal i grupp</td>
                <td id="pgrouplen"></td>
            </tr>
            <tr>
                <td>Allel(er)</td>
                <td id="pother"></td>
            </tr>
        </table>
    </fieldset>

    <fieldset>
        <legend>G-grupp</legend>

        <table>
            <tr>
                <td>G-grupp</td>
                <td id="ggroup"></td>
            </tr>
            <tr>
                <td>Antal i grupp</td>
                <td id="ggrouplen"></td>
            </tr>
            <tr>
                <td>Allel(er)</td>
                <td id="gother"></td>
            </tr>
        </table>
    </fieldset>

    <fieldset>
        <legend>Serologi</legend>

        <table>
            <tr>
                <td>Evidens</td>
                <td id="serokind"></td>
            </tr>
            <tr>
                <td>Antigen</td>
                <td id="seroantigen"></td>
            </tr>
        </table>

    </fieldset>
</form>

Data hämtas från
[https://github.com/ANHIG/IMGTHLA](https://github.com/ANHIG/IMGTHLA)
och används under licensen Creative Commons Attribution-NoDerivs.

## Referenser

- Robinson J, Barker DJ, Georgiou X, Cooper MA, Flicek P, Marsh SGE:
  IPD-IMGT/HLA Database. Nucleic Acids Research (2020), 48:D948-55.
- Robinson J, Malik A, Parham P, Bodmer JG, Marsh SGE: IMGT/HLA - a sequence
  database for the human major histocompatibility complex Tissue Antigens
  (2000), 55:280-287.
