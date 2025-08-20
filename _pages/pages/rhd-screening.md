title: RHD screening
created: 2023-11-14
updated: 2025-08-18
js: js/rhd_screen.js
summary: Tolkning av <i>RHD</i>-screening
---
<style>
label {
    width: revert;
    margin-right: 0.5em;
    margin-left: 0.25em;
}
input[type="number"] {
    width: 5em;
}
</style>

### Välj exporterad fil (.csv)

<input type="file" onchange="fileLoaded()" id="fileInput" accept=".csv" />

<!-- first table: static and calculated parameters-->

<form onchange="onParameterChange()">
<table>
<thead>
  <tr>
    <th></th>
    <th><i>GAPDH</i></th>
    <th><i>RHD</i></th>
  </tr>
</thead>
<tbody>
  <tr>
    <td><b>Positiv kontroll</b></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>medelvärde</td>
    <td id="gapdhMean"></td>
    <td id="rhdMean"></td>
  </tr>
  <tr>
    <td>nedre gräns</td>
    <td>
      <input id="gapdhMinDiff" type="number" step="0.1" value="-1.5" class="number">
    </td>
    <td></td>
  </tr>
  <tr>
    <td>övre gräns</td>
    <td>
      <input id="gapdhMaxDiff" type="number" step="0.1" value="6.4" class="number">
    </td>
    <td></td>
  </tr>
  <tr>
    <td>intervall</td>
    <td id="gapdhInterval"></td>
    <td></td>
  </tr>
  <tr>
    <td><b>Negativ kontroll</b></td>
    <td id="gapdhControl"></td>
    <td id="rhdControl"></td>
  </tr>
</tbody>
</table>
</form>

<form onchange="onInterpretationChange()">
<div id="sampleOutput">Resultat visas här när konvertering är klar</div>
</form>

<div id="fileOutput">
