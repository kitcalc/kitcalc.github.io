# an attempt to increase performance for the js target

# string handling
#

proc split*(s, sep: cstring): seq[cstring] {.importjs: "#.split(#)", nodecl.}
proc split*(s, sep: cstring; maxsplit: int): seq[cstring] {.importjs: "#.split(@)", nodecl.}

proc strip*(s: cstring): cstring {.importjs: "#.trim()", nodecl.}

proc startsWith*(a, b: cstring): bool {.importjs: "#.startsWith(#)", nodecl.}
proc endsWith*(a, b: cstring): bool {.importjs: "#.endsWith(#)", nodecl.}

proc contains*(a, b: cstring): bool {.importjs: "(#.indexOf(#)>=0)", nodecl.}

proc substr*(s: cstring; first: int): cstring {.importjs: "#.substr(#)", nodecl.}
proc substr*(s: cstring; first, last: int): cstring {.importjs: "#.slice(@)", nodecl.}

proc toUpperAscii*(s: cstring): cstring {.importjs: "#.toUpperCase()", nodecl.}

proc `&`*(a, b: cstring): cstring {.importjs: "(# + #)", nodecl.}
proc toCstr*(s: int): cstring {.importjs: "((#)+'')", nodecl.}
proc `&`*(s: int): cstring {.importjs: "((#)+'')", nodecl.}
proc `&`*(s: bool): cstring {.importjs: "((#)+'')", nodecl.}
proc `&`*(s: float): cstring {.importjs: "((#)+'')", nodecl.}
proc `&`*(s: cstring): cstring {.importjs: "(#)", nodecl.}

proc parseInt*(s: cstring): int {.importjs: "parseInt(#, 10)", nodecl.}
proc parseFloat*(s: cstring): BiggestFloat {.importc, nodecl.}


# js tables

type
  JsTable*[K, V] = ref object

proc newJsTable*[K, V](): JsTable[K, V] {.importcpp: "{@}".}

proc `[]`*[K, V](d: JsTable[K, V], key: K): V {.importcpp: "#[#]".}
proc `[]=`*[K, V](d: JsTable[K, V], key: K, value: V) {.importcpp: "#[#] = #"}

proc contains*[K, V](d: JsTable[K, V], key: K): bool {.importcpp: "#.hasOwnProperty(#)".}

proc del*[K, V](d: JsTable[K, V], key: K) {.importcpp: "delete #[#]".}

iterator keys*[K, V](d: JsTable[K, V]): K =
  var kkk: K
  {.emit: ["for (", kkk, " in ", d, ") {"].}
  yield kkk
  {.emit: ["}"].}


# some html templates
func a*(href, text: cstring): cstring =
  result = "<a href =\"".cstring & href & "\">".cstring & text & "</a>".cstring

func br*(): cstring = "<br>".cstring
