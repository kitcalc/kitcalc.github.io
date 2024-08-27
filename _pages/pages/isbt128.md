title: ISBT 128
created: 2024-06-25
summary: Tolka ISBT 128-koder
---
<!-- must be run last -->
<script src="js/isbt128.js" defer></script>

Tolka koder i [ISBT 128](https://www.isbt128.org/tech-spec)-format.


<form id="codeinputform" action="javascript:readInput()">
    <fieldset>
        <label for="code">Ange kod</label>
        <input type="text" id="code" autofocus>
        <input type="submit" hidden />
    </fieldset>
    <fieldset id="detectionFields" style="display: none;">
        <label for="fileinput">Eller läs in bild 📷</label>
        <input type="file" accept="image/*" id="fileinput" onchange="javascript:readBarcode()">
    </fieldset>
</form>

<div id="isbt128out"></div>

<h2>Sökhistorik</h2>
<div id="isbt128history"></div>

<h3>Hjälp</h3>
<div id="detectionInformation">
    <details>
        <summary>Vill du läsa barcodes med iPhone?</summary>
        Aktivera barcode-läsaren i iPhone (iOS 17) så här:<br>

        &rarr; Inställningar <br>
        &rarr; Safari <br>
        &rarr; Avancerat <br>
        &rarr; Funktionsflaggor <br>
        &rarr; Shape Detection API <br>
    </details>
</div>

<details>
    <summary>Visa alla dataidentitetstecken i standarden</summary>
    <table>
        <thead>
            <tr>
                <th>Tecken</th>
                <th>Kodstruktur</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                 <td><code>={A-N,P-Z,1-9}</code></td>
                 <td>Donation Identification Number</td>
             </tr>
             <tr>
                 <td><code>=%</code></td>
                 <td>Blood Groups [ABO and RhD]</td>
             </tr>
             <tr>
                 <td><code>=<</code></td>
                 <td>Product Code</td>
             </tr>
             <tr>
                 <td><code>=></code></td>
                 <td>Expiration Date</td>
             </tr>
             <tr>
                 <td><code>&></code></td>
                 <td>Expiration Date and Time</td>
             </tr>
             <tr>
                 <td><code>=*</code></td>
                 <td>Collection Date</td>
             </tr>
             <tr>
                 <td><code>&*</code></td>
                 <td>Collection Date and Time</td>
             </tr>
             <tr>
                 <td><code>=}</code></td>
                 <td>Production Date</td>
             </tr>
             <tr>
                 <td><code>&}</code></td>
                 <td>Production Date and Time</td>
             </tr>
             <tr>
                 <td><code>&(</code></td>
                 <td>Special Testing: General</td>
             </tr>
             <tr>
                 <td><code>={</code></td>
                 <td>Special Testing: Red Blood Cell Antigens</td>
             </tr>
             <tr>
                 <td><code>=\</code></td>
                 <td>Special Testing: Red Blood Cell Antigens—General</td>
             </tr>
             <tr>
                 <td><code>&\</code></td>
                 <td>Special Testing: Red Blood Cell Antigens—Finnish</td>
             </tr>
             <tr>
                 <td><code>&{</code></td>
                 <td>Special Testing: Platelet HLA and Platelet Specific Antigens</td>
             </tr>
             <tr>
                 <td><code>=[</code></td>
                 <td>Special Testing: HLA-A and -B Alleles</td>
             </tr>
             <tr>
                 <td><code>=\</code></td>
                 <td>Special Testing: HLA-DRB1 Alleles</td>
             </tr>
             <tr>
                 <td><code>=)</code></td>
                 <td>Container Manufacturer and Catalog Number</td>
             </tr>
             <tr>
                 <td><code>&)</code></td>
                 <td>Container Lot Number</td>
             </tr>
             <tr>
                 <td><code>=;</code></td>
                 <td>Donor Identification Number</td>
             </tr>
             <tr>
                 <td><code>='</code></td>
                 <td>Staff Member Identification Number</td>
             </tr>
             <tr>
                 <td><code>=-</code></td>
                 <td>Manufacturer and Catalog Number: Items Other Than Containers</td>
             </tr>
             <tr>
                 <td><code>&-</code></td>
                 <td>Lot Number: Items Other Than Containers</td>
             </tr>
             <tr>
                 <td><code>=+</code></td>
                 <td>Compound Message</td>
             </tr>
             <tr>
                 <td><code>=#</code></td>
                 <td>Patient Date of Birth</td>
             </tr>
             <tr>
                 <td><code>&#</code></td>
                 <td>Patient Identification Number</td>
             </tr>
             <tr>
                 <td><code>=]</code></td>
                 <td>Expiration Month and Year</td>
             </tr>
             <tr>
                 <td><code>&\</code></td>
                 <td>Transfusion Transmitted Infection Marker</td>
             </tr>
             <tr>
                 <td><code>=$</code></td>
                 <td>Product Consignment</td>
             </tr>
             <tr>
                 <td><code>&$</code></td>
                 <td>Dimensions</td>
             </tr>
             <tr>
                 <td><code>&%</code></td>
                 <td>Red Cell Antigens with Test History</td>
             </tr>
             <tr>
                 <td><code>=␣</code> (blank)</td>
                 <td>Flexible Date and Time</td>
             </tr>
             <tr>
                 <td><code>=,</code></td>
                 <td>Product Divisions</td>
             </tr>
             <tr>
                 <td><code>&+</code></td>
                 <td>Processing Facility Information Code</td>
             </tr>
             <tr>
                 <td><code>=/</code></td>
                 <td>Processor Product Identification Code</td>
             </tr>
             <tr>
                 <td><code>&,1</code></td>
                 <td>MPHO Lot Number</td>
             </tr>
             <tr>
                 <td><code>&,2</code></td>
                 <td>MPHO Supplemental Identification Number</td>
             </tr>
             <tr>
                 <td><code>&,3</code></td>
                 <td>Global Registration Identifier for Donors</td>
             </tr>
             <tr>
                 <td><code>&,4</code></td>
                 <td>Single European Code</td>
             </tr>
             <tr>
                 <td><code>&):</code></td>
                 <td>Global Registration Identifier for Donors</td>
             </tr>
             <tr>
                 <td><code>&/</code></td>
                 <td>Chain of Identity Identifier</td>
             </tr>
             <tr>
                 <td><code>&{a-z}</code></td>
                 <td>Data Structures Not Defined by ICCBBA</td>
             </tr>
             <tr>
                 <td><code>&;</code></td>
                 <td>Reserved Data Identifiers for a Nationally Specified Donor Identification Number</td>
             </tr>
             <tr>
                 <td><code>&!</code></td>
                 <td>Confidential Unit Exclusion Status Data Structure</td>
             </tr>
        </tbody>
    </table>
</details>
