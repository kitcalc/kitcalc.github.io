title: Beredskapsersättning
created: 2018-02-02
updated: 2025-09-12
js: js/beredskap.js
summary: Beräkning av beredskapsersättning
---
<script>
var fyllvardag = function() {
    document.getElementById("beredskapTimmarAnnan").value = 15.5;
    document.getElementById("beredskapTimmarHelg").value = 0.0;
}

var fyllhelg = function() {
    document.getElementById("beredskapTimmarAnnan").value = 1.5;
    document.getElementById("beredskapTimmarHelg").value = 62;
};
</script>

*Uppdaterat för lokalt avtal 2025*

Avvikelser pga. avrundningsfel eller buggar kan förekomma.


## Inmatning

<!-- moved outside of form to avoid resetting -->
<ul><li>
<label for="manadslon">Månadslön</label>
<input type="number" id="manadslon" min=0 required><br>
</ul>

<form id="calc" action="javascript:addBeredskap()">

    <fieldset>
        <legend>Beredskap</legend>

        <ul>
        <li>
        <label for="beredskapsTypA">Beredskap A</label>
        <input type="radio" name="beredskapsTyp" id="beredskapsTypA" value="berA" checked>

        <li>
        <label for="beredskapsTypB">Beredskap B</label>
        <input type="radio" name="beredskapsTyp" id="beredskapsTypB" value="berB">

        <li>
        <label for="beredskapsTypJour">Jour</label>
        <input type="radio" name="beredskapsTyp" id="beredskapsTypJour" value="Jour">

        <li>
        <label for="kortVarsel">Kort varsel</label>
        <input type="checkbox" name="kortVarsel" id="kortVarsel" value="kv">

        <li>
        <label for="beredskapTimmarAnnan">Beredskap annan (h)</label>
        <input type="number" id="beredskapTimmarAnnan" value=0 min=0 step=0.000001>

        <li>
        <label for="beredskapTimmarHelg">Beredskap helg (h)</label>
        <input type="number" id="beredskapTimmarHelg" value=0 min=0 step=0.000001>
        </ul>

        <p>
        <a href="javascript:fyllvardag()">Vardag</a> och
        <a href="javascript:fyllhelg()">helg</a>.
        </p>
    </fieldset>

    <fieldset>
        <legend>Arbetad tid</legend>

        <ul>
        <li>
        <label for="arbetadeMinAnnan">Arbetad tid annan (min)</label>
        <input type="number" id="arbetadeMinAnnan" value=0 min=0 title="All annan arbetad tid (t.ex. vardag 16:30&ndash;21:00 och 07:00&ndash;08:00)">

        <li>
        <label for="arbetadeMinVardagkvall">Arbetad tid vardag 21:00&ndash;24:00 (min)</label>
        <input type="number" id="arbetadeMinVardagkvall" value=0 min=0 title="Vardag 21:00&ndash;24:00">

        <li>
        <label for="arbetadeMinNatt">Arbetad tid vardagnatt (min)</label>
        <input type="number" id="arbetadeMinNatt" value=0 min=0 title="Vardag 00:00&ndash;07:00">

        <li>
        <label for="arbetadeMinHelg">Arbetad tid helg (min)</label>
        <input type="number" id="arbetadeMinHelg" value=0 min=0 title="17:00 fredag eller vardag före helgdag&ndash;07:00 vardag efter sön- eller helgdag">

        <li>
        <label for="arbetadeMinStorhelg">Arbetad tid storhelg (min)</label>
        <input type="number" id="arbetadeMinStorhelg" value=0 min=0 title="Midsommar-, jul- och nyårsafton 07:00&ndash;dag efter aftonen 07:00">

        <li>
        <input value="Nollställ" type="reset">
        <input type="submit" value="Lägg till">
        </ul>
    </fieldset>

</form>

<div id="tabell">
</div>
