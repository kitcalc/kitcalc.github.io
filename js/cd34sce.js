function cd34calc() {

    // convert form input to usable variables
    var weight = parseInt(document.getElementById("recipient_weight").value);
    var volume = parseInt(document.getElementById("volume").value);
    var dilution_factor = parseInt(document.getElementById("dilution_factor").value);
    var beads = parseInt(document.getElementById("beads").value);
    var all_but_beads = parseInt(document.getElementById("all_but_beads").value);
    var vCD45 = parseInt(document.getElementById("vCD45").value);
    var count_vCD34 = parseInt(document.getElementById("count_vCD34").value);
    var vMNC = parseInt(document.getElementById("vMNC").value);
    var CD34_CD45dim = parseInt(document.getElementById("CD34_CD45dim").value);

    var bead_count = parseInt(document.getElementById("bead_count").value);

    // calculate
    var dilution_compensation = 100 / dilution_factor;

    var CD45_per_bead = vCD45 / beads;
    var CD45pos_per_ul = CD45_per_bead * bead_count / dilution_compensation;
    var CD45pos_total = CD45pos_per_ul * volume / 1000000;
    var CD45pos_per_kg = CD45pos_total / weight * 10;
    var CD45pos_viability = vCD45 / all_but_beads *100;

    var count_vCD34_per_bead = count_vCD34 / beads;
    var CD34pos_per_ul = count_vCD34_per_bead * bead_count / dilution_compensation;
    var CD34pos_total = CD34pos_per_ul * volume / 1000;
    var CD34pos_percent = CD34pos_per_ul / CD45pos_per_ul * 100;
    var CD34pos_per_kg = CD34pos_total / weight;
    var CD34pos_viability = count_vCD34 / CD34_CD45dim * 100;

    var MNC_per_bead = vMNC / beads;
    var MNC_per_ul = MNC_per_bead * bead_count / dilution_compensation;
    var MNC_total = MNC_per_ul * volume / 1000000;
    var MNC_percent = MNC_per_ul / CD45pos_per_ul * 100;
    var MNC_per_kg = MNC_total / weight * 10;

    // print it
    document.getElementById("CD45_cells").innerHTML = CD45pos_per_ul.toFixed(0);
    document.getElementById("CD45_tot").innerHTML = CD45pos_total.toFixed(1);
    document.getElementById("CD45_kg").innerHTML = CD45pos_per_kg.toFixed(1);
    document.getElementById("CD45_viability").innerHTML = CD45pos_viability.toFixed(1);

    document.getElementById("CD34_cells").innerHTML = CD34pos_per_ul.toFixed(0);
    document.getElementById("CD34_tot").innerHTML = CD34pos_total.toFixed(1);
    document.getElementById("CD34_percent").innerHTML = CD34pos_percent.toFixed(1);
    document.getElementById("CD34_kg").innerHTML = CD34pos_per_kg.toFixed(1);
    document.getElementById("CD34_viability").innerHTML = CD34pos_viability.toFixed(1);

    document.getElementById("MNC_cells").innerHTML = MNC_per_ul.toFixed(0);
    document.getElementById("MNC_tot").innerHTML = MNC_total.toFixed(1);
    document.getElementById("MNC_percent").innerHTML = MNC_percent.toFixed(1);
    document.getElementById("MNC_kg").innerHTML = MNC_per_kg.toFixed(1);
}
