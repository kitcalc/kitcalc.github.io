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

    document.getElementById("arbetadeMinAnnan").value = "0.0";
    document.getElementById("arbetadeMinVardagkvall").value = "0.0";
    document.getElementById("arbetadeMinNatt").value = "0.0";
    document.getElementById("arbetadeMinHelg").value = "0.0";
    document.getElementById("arbetadeMinStorhelg").value = "0.0";
}

