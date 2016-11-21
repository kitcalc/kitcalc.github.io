prozone_ab = ->
    undiluted = document.getElementById('undiluted').value.trim().split(/\s+/)
    console.log 'undiluted:', undiluted
    diluted = document.getElementById('diluted').value.trim().split(/\s+/)
    console.log 'diluted:', diluted

    difference = (ag for ag in diluted when ag not in undiluted)
    document.getElementById('results').innerHTML = difference.join(" ")

