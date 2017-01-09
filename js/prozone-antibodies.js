var prozone_ab,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

prozone_ab = function() {
    var ag, difference, diluted, output, undiluted;
    undiluted = document.getElementById('undiluted').value.trim().split(/\s+/);
    diluted = document.getElementById('diluted').value.trim().split(/\s+/);
    difference = (function() {
	var i, len, results;
	results = [];
	for (i = 0, len = diluted.length; i < len; i++) {
	    ag = diluted[i];
	    if (indexOf.call(undiluted, ag) < 0) {
		results.push(ag);
	    }
	}
	return results;
    })();
    output = document.getElementById('results');
    if (difference.length === 0) {
	return output.innerHTML = "inga prozone-antikroppar";
    } else {
	return output.innerHTML = difference.join(" ");
    }
};
