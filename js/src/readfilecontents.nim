import dom

asm """var readFileContents = function(elementId, cb) {

  var files = document.getElementById(elementId).files;
  var reader = new FileReader();

  reader.addEventListener(
    "load",
    function (e) {
      // call callback function
      cb(reader.result);
    },
    false);

  // start reading first file in list
  reader.readAsText(files[0])
}
"""

proc readFileContents*(elementId: cstring, cb: proc(filecontents: cstring)) {.importc.}
  ## Read the contents of the file in element id pointed to in ``elementId`´.
  ## Runs the proc ``cb`` on the file contents.

## Example usage
##
## .. code-block:: nim
##
##   var global: cstring
##
##   proc setGlobalVariable(filecontents: cstring) =
##     global = filecontents
##
##   # this is bound to the file input control
##   proc doActionOnChange*() {.exportc.} =
##     readFileContents("myinput", setGlobalVariable)
##
##   # this could be bound to a button
##   proc downStream*() {.exportc.} =
##     echo global
##