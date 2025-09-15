title: RHD-screening
created: 2023-11-14
updated: 2025-09-15
js: js/rhd_screen.js
summary: Tolkning av RHD-screening
---

<style>
  /* override standard styles */

  input[type="number"] {
      width: 4em;
      border: 1px;
      padding: 5px;
  }
  table {
    overflow-x: auto;
  }
  select {
    padding: 5px;
    margin: 0;
    border: 0;
  }
  @media print {
    /* print styles */
    /* stronger color */
    td, th {
      border-color: #aaa;
    }
    /* hide elements from output */
    header,
    footer,
    #fileOutput {
      display: none !important;
    }
  }
</style>

### Välj exporterad fil (.csv)

<input type="file" onchange="fileLoaded()" id="fileInput" accept=".csv">

<!-- first table: static and calculated parameters-->

<form onchange="onParameterChange()">
  <table>
    <thead>
      <tr>
        <th></th>
        <th colspan="4">Positiv kontroll</th>
        <th>Negativ kontroll</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td></td>
        <td>medelvärde</td>
        <td>nedre gräns</td>
        <td>övre gräns</td>
        <td>intervall</td>
        <td></td>
      </tr>
      <tr>
        <td>
          <i><b>GAPDH</b></i>
        </td>
        <td id="gapdhMean">
        </td>
        <td>
          <input id="gapdhMinDiff" type="number" step="0.1" value="-1.5">
        </td>
        <td>
          <input id="gapdhMaxDiff" type="number" step="0.1" value="6.4">
        </td>
        <td id="gapdhInterval"></td>
        <td id="gapdhControl"></td>
      </tr>
      <tr>
        <td><i><b>RHD</b></i></td>
        <td id="rhdMean"></td>
        <td></td>
        <td></td>
        <td></td>
        <td id="rhdControl"></td>
      </tr>
    </tbody>
  </table>
</form>

<form onchange="onInterpretationChange()">
<div id="sampleOutput"></div>
</form>

<div id="fileOutput"></div>
