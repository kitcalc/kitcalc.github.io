import dom
import ajax

proc makeRequest*(url: cstring, cb: proc (c: cstring)) =
  var xhr = newXMLHttpRequest()
  xhr.responseType = "text"  # default type is xml, raises error otherwise

  if xhr.isNil:
    echo "Cannot create an XMLHTTP instance for url ", url
    return
  proc alertContents(e:Event) =
    if xhr.readyState == rsDONE:
      if xhr.status == 200:
        cb(xhr.responseText)
      else:
        echo "Could not retrieve data from ", url
  xhr.onreadystatechange = alertContents
  xhr.open("GET", url)
  xhr.send()