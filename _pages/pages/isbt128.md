title: ISBT 128
created: 2024-06-25
js: js/isbt128.js
summary: Tolka ISBT 128-koder
---

Tolka koder i [ISBT 128](https://www.isbt128.org/tech-spec)-format.

<details>
    <summary>Visa alla dataidentitetstecken</summary>
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

<form id="codeinputform" action="javascript:interpretCode()">
  <fieldset>
      <!-- <legend>Inmatning</legend> -->
      <label for="code">Ange kod</label>
      <input type="text" id="code">
      <input type="submit" hidden />
    </fieldset>
</form>

<div id="isbt128out"></div>

