prozone_ab = ->
    undiluted = document.getElementById('undiluted').value.trim().split(/\s+/)
    diluted = document.getElementById('diluted').value.trim().split(/\s+/)

    difference = (ag for ag in diluted when ag not in undiluted)
    output = document.getElementById('results').innerHTML 
    if difference.length == 0
       output = "inga prozone-antikroppar"
    else
        output = difference.join(" ")

