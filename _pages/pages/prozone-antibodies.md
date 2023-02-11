title: Prozone-antikroppar
created: 2016-10-23
js: js/prozone-antibodies.js
summary: Tolkning av prozone-liknande mönster för HLA-antikroppar
---

Mata in antikroppsspecificiteter ospätt och i spädning

<form id="calc">
    <fieldset>
        <legend>Inmatning</legend>

        <ul>
        <li>
        <label for="undiluted">Ospätt</label>
        <textarea rows=4 id="undiluted"></textarea>

        <li>
        <label for="diluted">Spädning</label>
        <textarea rows=4 id="diluted"></textarea>

        <li>
        <input type="button" value="Jämför" onclick="prozone_ab()">
        <input type="reset" value="Nollställ">
        </ul>
    </fieldset>

    <fieldset>
        <legend>Resultat</legend>

        <label for="results">Specificiteter unika för spädning</label>
        <textarea id="results" readonly></textarea>
    </fieldset>
</form>

