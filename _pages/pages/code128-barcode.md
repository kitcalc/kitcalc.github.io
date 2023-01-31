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

            <label for="height">Höjd</label>
            <input type="text" id="height" value="80"><br>

            <label for="width">Bredd</label>
            <input type="text" id="width" value="180"><br>

            <label for="showframe">Visa ram</label>
            <input type="checkbox" checked="true" id="showframe"><br>

            <label for="showtext">Visa text</label>
            <input type="checkbox" checked="true" id="showtext"><br>

            <label for="textsize">Textstorlek</label>
            <input type="text" id="textsize" value="12"><br>

            <label for="fontfamily">Teckensnitt</label>
            <input type="text" id="fontfamily" value="sans-serif"><br>
            
            <label for="debugmode">Debug-läge</label>
            <input type="checkbox" checked="false" id="debugmode"><br>
            
            <label for="rawmode">Escape-sekvenser</label>
            <input type="checkbox" checked="false" id="rawmode">
        </details>

    </fieldset>
</form>


## Barcode

<div id="barcode"></div>

<details>
    <summary>SVG-källa</summary>
    <code id="svgsource"></code>
</details>

