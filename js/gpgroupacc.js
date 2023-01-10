var getGgroupData = function() {

  var url ="https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/wmda/hla_nom_g.txt"
  var xhttp = new XMLHttpRequest();
  var method = "GET";

  xhttp.onload = function () {
    initGgroupData(xhttp.responseText);
    document.getElementById("helptext").innerHTML += "Laddade G-grupper<br>"
  }

  xhttp.open(method, url, true);
  xhttp.send();

}

var getPgroupData = function() {

  var url ="https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/wmda/hla_nom_p.txt"
  var xhttp = new XMLHttpRequest();
  var method = "GET";

  xhttp.onload = function () {
    initPgroupData(xhttp.responseText);
    document.getElementById("helptext").innerHTML += "Laddade P-grupper<br>"
  }

  xhttp.open(method, url, true);
  xhttp.send();

}

var getAlleleIdData = function() {

  var url ="https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/Allelelist.txt"
  var xhttp = new XMLHttpRequest();
  var method = "GET";

  xhttp.onload = function () {
    initAlleleIdData(xhttp.responseText);
    document.getElementById("helptext").innerHTML += "Laddade Allelelist<br>"
  }

  xhttp.open(method, url, true);
  xhttp.send();

}

var getSeroData = function() {

  var url ="https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/wmda/rel_dna_ser.txt"
  var xhttp = new XMLHttpRequest();
  var method = "GET";

  xhttp.onload = function () {
    initSerologicalData(xhttp.responseText);
    document.getElementById("helptext").innerHTML += "Laddade antigendata<br>"
  }

  xhttp.open(method, url, true);
  xhttp.send();

}

var getSplitData = function() {

  var url ="https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/wmda/rel_ser_ser.txt"
  var xhttp = new XMLHttpRequest();
  var method = "GET";

  xhttp.onload = function () {
    initSplitData(xhttp.responseText);
    document.getElementById("helptext").innerHTML += "Laddade splitdata<br>"
  }

  xhttp.open(method, url, true);
  xhttp.send();

}

// run scripts
getGgroupData();
getPgroupData();
getAlleleIdData();
getSeroData();
getSplitData();
