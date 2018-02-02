title: Beredskapsersättning
created: 2018-02-02
js: js/beredskapjs.js
    js/beredskapacc.js
summary: Beräkning av beredskapsersättning
---

Fyll i och lägg till ett beredskapstillfälle i taget. Använd punkt "." som
decimal, ej komma (då blir det tusental). Lägg in beredskap i timmar och arbete
under beredskap i minuter. Tänk på att allt arbete räknas per påbörjade
halvtimme så kortast. Sammanställning visas nederst i tabellform summerat och per
beredskapstillfälle.

Smärre avvikelse pga. avrundningsfel kan förekomma.


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

        <p>Fyll i tid i timmar. Fördefinierade tider finns för
        <a href="javascript:fyllvardag()">vardag</a> och
        <a href="javascript:fyllhelg()">helg</a>.
        </p>
    </fieldset>

    <fieldset>
        <legend>Arbete under beredskap i minuter</legend>

        <label for="arbetadeMinAnnan">Arbetad tid annan (min)</label>
        <input type="number" id="arbetadeMinAnnan" value=0 min=0 title="All annan arbetad tid (t.ex. vardag 16:30&ndash;21:00 och 07:00&ndash;08:00)"><br>

        <label for="arbetadeMinVardagkvall">Arbetad tid vardag 21:00&ndash;24:00 (min)</label>
        <input type="number" id="arbetadeMinVardagkvall" value=0 min=0 title="Vardag 21:00&ndash;24:00"><br>

        <label for="arbetadeMinNatt">Arbetad tid vardagnatt (min)</label>
        <input type="number" id="arbetadeMinNatt" value=0 min=0 title="Vardag 00:00&ndash;07:00"><br>

        <label for="arbetadeMinHelg">Arbetad tid helg (min)</label>
        <input type="number" id="arbetadeMinHelg" value=0 min=0 title="17:00 fredag eller vardag före helgdag&ndash;07:00 vardag efter sön- eller helgdag"><br>

        <label for="arbetadeMinStorhelg">Arbetad tid storhelg (min)</label>
        <input type="number" id="arbetadeMinStorhelg" value=0 min=0 title="Midsommar-, jul- och nyårsafton 07:00&ndash;dag efter aftonen 07:00"><br>

        <input type="button" onclick="javascript:clearForm()" value="Nollställ">
        <input type="submit" value="Lägg till och beräkna">
    </fieldset>

</form>

## Beredskaper

<div id="tabell">
Tabell kommer här.
</div>
