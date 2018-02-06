var getGgroupData = function() {

  var url ="https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/wmda/hla_nom_g.txt"
  var xhttp = new XMLHttpRequest();
  var method = "GET";

  xhttp.onreadystatechange = function () {
    if(xhttp.readyState === XMLHttpRequest.DONE && xhttp.status === 200) {
      initGgroupData(xhttp.responseText);
      document.getElementById("helptext").innerHTML += "Laddade G-grupper<br>"
    }
  }

  xhttp.open(method, url, true);
  xhttp.send();

  // change id
  // document.getElementById('output').innerHTML = "Retrieving " + url + "...";
}

var getPgroupData = function() {

  var url ="https://raw.githubusercontent.com/ANHIG/IMGTHLA/Latest/wmda/hla_nom_p.txt"
  var xhttp = new XMLHttpRequest();
  var method = "GET";

  xhttp.onreadystatechange = function () {
    if(xhttp.readyState === XMLHttpRequest.DONE && xhttp.status === 200) {
      initPgroupData(xhttp.responseText);
      document.getElementById("helptext").innerHTML += "Laddade P-grupper<br>"
    }
  }

  xhttp.open(method, url, true);
  xhttp.send();

  // document.getElementById('output').innerHTML = "Retrieving " + url + "...";
}

// run scripts
getGgroupData();
getPgroupData();