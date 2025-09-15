title: Code128 barcode
created: 2023-01-30
js: js/code128.js
summary: Generera en barcode i Code128-format
---

Barcode i [Code128](https://en.wikipedia.org/wiki/Code_128)-format.

<form id="barcodeform" onchange="javascript:genBarcode()">
    <fieldset>
        <legend>Inmatning</legend>

        <label for="text">Text</label>
        <textarea id="text" rows="3" onkeyup="javascript:genBarcode()"></textarea>

        <!-- For help text output -->
        <!-- <div id="helptext"></div> -->

        <details>
            <summary>Fler inställningar</summary>

            <ul>
            <li>
            <label for="height">Höjd</label>
            <input type="text" id="height" value="80">

            <li>
            <label for="width">Bredd</label>
            <input type="text" id="width" value="180">

            <li>
            <label for="showframe">Visa ram</label>
            <input type="checkbox" id="showframe" checked>

            <li>
            <label for="showtext">Visa text</label>
            <input type="checkbox" id="showtext" checked>

            <li>
            <label for="textsize">Textstorlek</label>
            <input type="text" id="textsize" value="12">

            <li>
            <label for="fontfamily">Teckensnitt</label>
            <input type="text" id="fontfamily" value="sans-serif">

            <li>
            <label for="barheight">Streckhöjd</label>
            <input type="text" id="barheight" placeholder="75% / 90%">

            <li>
            <label for="debugmode">Debug-läge</label>
            <input type="checkbox" id="debugmode">

            <li>
            <label for="rawmode">Escape-sekvenser</label>
            <input type="checkbox" id="rawmode">
            </ul>
        </details>

    </fieldset>
</form>


## Barcode

<div id="barcodeout"></div>

<details>
    <summary>SVG-källa</summary>
    <pre><code id="svgsource"></code></pre>
</details>

