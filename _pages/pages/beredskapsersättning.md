title: Beredskapsersättning
created: 2018-02-02
js: js/beredskapjs.js
    js/beredskapacc.js
summary: Beräkning av beredskapsersättning
---

Fyll i och lägg till ett beredskapstillfälle i taget. Använd punkt "." som
decimal, ej komma (då blir det tusental). Sammanställning visas nederst i
tabellform summerat och per beredskapstillfälle.

Smärre avvikelse pga. avrundningsfel förekommer.


## Inmatning

<form id="calc" action="javascript:addBeredskap()">

    <label for="manadslon">Månadslön</label>
    <input type="number" id="manadslon" min=0 required><br>

    <fieldset>
        <legend>Beredskap</legend>

        <label for="beredskapsTypA">Beredskap A</label>
        <input type="radio" name="beredskapsTyp" id="beredskapsTypA" value="berA" checked><br>
        <label for="beredskapsTypB">Beredskap B</label>
        <input type="radio" name="beredskapsTyp" id="beredskapsTypB" value="berB"><br>

        <label for="kortVarsel">Kort varsel</label>
        <input type="checkbox" name="kortVarsel" id="kortVarsel" value="kv"><br>

        <label for="beredskapTimmarAnnan">Beredskap annan (h)</label>
        <input type="number" id="beredskapTimmarAnnan" value=0 min=0 step=0.000001><br>

        <label for="beredskapTimmarHelg">Beredskap helg (h)</label>
        <input type="number" id="beredskapTimmarHelg" value=0 min=0 step=0.000001><br>

        <p>Fördefinierade tider finns för
        <a href="javascript:fyllvardag()">vardag</a> och
        <a href="javascript:fyllhelg()">helg</a>.
        </p>

    </fieldset>

    <fieldset>
        <legend>Arbete under beredskap</legend>

        <label for="arbetadeTimmarAnnan">Arbetad tid annan (h)</label>
        <input type="number" id="arbetadeTimmarAnnan" value=0 min=0 step=0.000001 title="All annan arbetad tid (t.ex. vardag 16:30&ndash;21:00 och 07:00&ndash;08:00)"><br>

        <label for="arbetadeTimmarVardagkvall">Arbetad tid vardag 21:00&ndash;24:00 (h)</label>
        <input type="number" id="arbetadeTimmarVardagkvall" value=0 min=0 step=0.000001 title="Vardag 21:00&ndash;24:00"><br>

        <label for="arbetadeTimmarNatt">Arbetad tid vardagnatt (h)</label>
        <input type="number" id="arbetadeTimmarNatt" value=0 min=0 step=0.000001 title="Vardag 00:00&ndash;07:00"><br>

        <label for="arbetadeTimmarHelg">Arbetad tid helg (h)</label>
        <input type="number" id="arbetadeTimmarHelg" value=0 min=0 step=0.000001 title="17:00 fredag eller vardag före helgdag&ndash;07:00 vardag efter sön- eller helgdag"><br>

        <label for="arbetadeTimmarStorhelg">Arbetad tid storhelg (h)</label>
        <input type="number" id="arbetadeTimmarStorhelg" value=0 min=0 step=0.000001 title="Midsommar-, jul- och nyårsafton 07:00&ndash;dag efter aftonen 07:00"><br>

        <input type="button" onclick="javascript:clearForm()" value="Nollställ">
        <input type="submit" value="Lägg till och beräkna">

    </fieldset>

</form>

## Beredskaper

<div id="tabell">
Tabell kommer här.
</div>
