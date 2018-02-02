var fyllvardag = function() {
    document.getElementById("beredskapTimmarAnnan").value = 15.5;
    document.getElementById("beredskapTimmarHelg").value = 0.0;
}

var fyllhelg = function() {
    document.getElementById("beredskapTimmarAnnan").value = 1.5;
    document.getElementById("beredskapTimmarHelg").value = 62;
};

var clearForm = function() {
    document.getElementById("kortVarsel").checked = false
    document.getElementById("beredskapTimmarAnnan").value = "0.0";
    document.getElementById("beredskapTimmarHelg").value = "0.0";

    document.getElementById("arbetadeTimmarAnnan").value = "0.0";
    document.getElementById("arbetadeTimmarVardagkvall").value = "0.0";
    document.getElementById("arbetadeTimmarNatt").value = "0.0";
    document.getElementById("arbetadeTimmarHelg").value = "0.0";
    document.getElementById("arbetadeTimmarStorhelg").value = "0.0";
}

