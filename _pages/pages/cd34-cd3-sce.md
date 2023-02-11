title: CD34 CD3 SCE
created: 2016-10-14
updated: 2018-05-23
js: js/cd34cd3sce.js
summary: CD34+ och CD3+ i stamcellsskörd
---

# Input

<form id="calc" action="javascript:cd34cd3calc()">

    <fieldset>
        <legend>Patientdata</legend>

        <ul>
        <li>
        <label for="recipient_weight">Recipientvikt (kg)</label>
        <input type="number" id="recipient_weight" pattern="\d*">

        <li>
        <label for="volume">Volym (ml)</label>
        <input type="number" id="volume" pattern="\d*">
        </ul>
    </fieldset>

    <fieldset>
        <legend>Events från analysprotokoll</legend>

        <ul>
        <li>
        <label for="dilution_factor">Spädn faktor</label>
        <input type="number" id="dilution_factor" pattern="\d*">

        <li>
        <label for="beads">Beads</label>
        <input type="number" id="beads" pattern="\d*">

        <li>
        <label for="all_but_beads">All but beads</label>
        <input type="number" id="all_but_beads" pattern="\d*">

        <li>
        <label for="vCD45">vCD45+</label>
        <input type="number" id="vCD45" pattern="\d*">

        <li>
        <label for="count_vCD34">Count vCD34+</label>
        <input type="number" id="count_vCD34" pattern="\d*">

        <li>
        <label for="vMNC">vMNC</label>
        <input type="number" id="vMNC" pattern="\d*">

        <li>
        <label for="CD34_CD45dim">CD34+ CD45dim</label>
        <input type="number" id="CD34_CD45dim" pattern="\d*">

        <li>
        <label for="vCD3">vCD3+</label>
        <input type="number" id="vCD3" pattern="\d*">

        <li>
        <label for="bead_count">Bead count</label>
        <input type="number" id="bead_count" pattern="\d*">

        <li>
        <input type="submit" value="Beräkna">
        </ul>
    </fieldset>
</form>

# Innehåll

<table>
    <thead>
        <tr>
            <th>Variabel</th>
            <th>Resultat</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>vCD45<sup>+</sup> (cells/&mu;l)</td>
            <td id="CD45_cells"></td>
        </tr>
        <tr>
            <td>vCD45<sup>+</sup> (10<sup>9</sup>)</td>
            <td id="CD45_tot"></td>
        </tr>
        <tr>
            <td>vCD45<sup>+</sup> (10<sup>8</sup>/kg)</td>
            <td id="CD45_kg"></td>
        </tr>
        <tr>
            <td>Viabilitet CD45<sup>+</sup> (%)</td>
            <td id="CD45_viability"></td>
        </tr>
        <tr>
            <td>vCD34<sup>+</sup> (cells/&mu;l)</td>
            <td id="CD34_cells"></td>
        </tr>
        <tr>
            <td>vCD34<sup>+</sup> (10<sup>6</sup>)</td>
            <td id="CD34_tot"></td>
        </tr>
        <tr>
            <td>vCD34<sup>+</sup> (%)</td>
            <td id="CD34_percent"></td>
        </tr>
        <tr class="info">
            <td>vCD34<sup>+</sup> (10<sup>6</sup>/kg)</td>
            <td id="CD34_kg"></td>
        </tr>
        <tr>
            <td>Viabilitet CD34<sup>+</sup> (%)</td>
            <td id="CD34_viability"></td>
        </tr>
        <tr>
            <td>vMNC (cells/&mu;l)</td>
            <td id="MNC_cells"></td>
        </tr>
        <tr>
            <td>vMNC (10<sup>9</sup>)</td>
            <td id="MNC_tot"></td>
        </tr>
        <tr>
            <td>vMNC (%)</td>
            <td id="MNC_percent"></td>
        </tr>
        <tr>
            <td>vMNC (10<sup>8</sup>/kg)</td>
            <td id="MNC_kg"></td>
        </tr>
        <tr>
            <td>vCD3<sup>+</sup> (cells/&mu;l)</td>
            <td id="CD3_cells"></td>
        </tr>
        <tr>
            <td>vCD3<sup>+</sup> (10<sup>9</sup>)</td>
            <td id="CD3_tot"></td>
        </tr>
        <tr>
            <td>vCD3<sup>+</sup> (%)</td>
            <td id="CD3_percent"></td>
        </tr>
        <tr>
            <td>vCD3<sup>+</sup> (10<sup>6</sup>/kg)</td>
            <td id="CD3_kg"></td>
        </tr>
    </tbody>
</table>
