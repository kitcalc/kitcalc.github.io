import strutils, strformat

## Supported are tables A, B, C
## FNCs are not supported

type
  State = enum
    stateA,
    stateB,
    stateC

  Code128 = object
    s: string  # input string
    state: State
    bar: seq[Code128Range]  # the barcode
    i: int  # current index in s

  Code128Range = range[0..106]

  BarPattern = array[6, int]

  CodeA {.pure.} = enum
    # Table A specific
    FNC3 = 96
    FNC2 = 97
    shiftB = 98
    codeC = 99
    codeB = 100
    FNC4 = 101

  CodeB {.pure.} = enum
    # Table B specific
    FNC3 = 96
    FNC2 = 97
    shiftA = 98
    codeC = 99
    FNC4 = 100
    codeA = 101

  CodeC {.pure.} = enum
    # Table C specific
    codeB = 100
    codeA = 101

  Shared = enum
    # shared values
    FNC1 = 102
    startA = 103  ## start with Table A
    startB = 104  ## start with Table B
    startC = 105  ## start with Table C
    stop = 106  ## stop

const
  tableAChars = {
    # subset of printable ascii range and control codes (apart from \127 DEL)
    # printable listed here first since this is how they are ordered in Code128
    '\32' .. '\95',  # same as ' ' .. '_', shared with Table B
    '\0' .. '\31'  # C0 and C1 control codes
  }
  tableBChars = {
    # printable ascii range (apart from \127 DEL)
    '\32' .. '\95',  # same as ' ' .. '_', , shared with Table A
    '\96' .. '\127'  # same as '`' .. '\127'
  }

  # Bar widths for chars. Bar-space-Bar-space-Bar-space
  barWidths: array[Code128Range, BarPattern] = [
    [2, 1, 2, 2, 2, 2], [2, 2, 2, 1, 2, 2], [2, 2, 2, 2, 2, 1], [1, 2, 1, 2, 2, 3],
    [1, 2, 1, 3, 2, 2], [1, 3, 1, 2, 2, 2], [1, 2, 2, 2, 1, 3], [1, 2, 2, 3, 1, 2],
    [1, 3, 2, 2, 1, 2], [2, 2, 1, 2, 1, 3], [2, 2, 1, 3, 1, 2], [2, 3, 1, 2, 1, 2],
    [1, 1, 2, 2, 3, 2], [1, 2, 2, 1, 3, 2], [1, 2, 2, 2, 3, 1], [1, 1, 3, 2, 2, 2],
    [1, 2, 3, 1, 2, 2], [1, 2, 3, 2, 2, 1], [2, 2, 3, 2, 1, 1], [2, 2, 1, 1, 3, 2],
    [2, 2, 1, 2, 3, 1], [2, 1, 3, 2, 1, 2], [2, 2, 3, 1, 1, 2], [3, 1, 2, 1, 3, 1],
    [3, 1, 1, 2, 2, 2], [3, 2, 1, 1, 2, 2], [3, 2, 1, 2, 2, 1], [3, 1, 2, 2, 1, 2],
    [3, 2, 2, 1, 1, 2], [3, 2, 2, 2, 1, 1], [2, 1, 2, 1, 2, 3], [2, 1, 2, 3, 2, 1],
    [2, 3, 2, 1, 2, 1], [1, 1, 1, 3, 2, 3], [1, 3, 1, 1, 2, 3], [1, 3, 1, 3, 2, 1],
    [1, 1, 2, 3, 1, 3], [1, 3, 2, 1, 1, 3], [1, 3, 2, 3, 1, 1], [2, 1, 1, 3, 1, 3],
    [2, 3, 1, 1, 1, 3], [2, 3, 1, 3, 1, 1], [1, 1, 2, 1, 3, 3], [1, 1, 2, 3, 3, 1],
    [1, 3, 2, 1, 3, 1], [1, 1, 3, 1, 2, 3], [1, 1, 3, 3, 2, 1], [1, 3, 3, 1, 2, 1],
    [3, 1, 3, 1, 2, 1], [2, 1, 1, 3, 3, 1], [2, 3, 1, 1, 3, 1], [2, 1, 3, 1, 1, 3],
    [2, 1, 3, 3, 1, 1], [2, 1, 3, 1, 3, 1], [3, 1, 1, 1, 2, 3], [3, 1, 1, 3, 2, 1],
    [3, 3, 1, 1, 2, 1], [3, 1, 2, 1, 1, 3], [3, 1, 2, 3, 1, 1], [3, 3, 2, 1, 1, 1],
    [3, 1, 4, 1, 1, 1], [2, 2, 1, 4, 1, 1], [4, 3, 1, 1, 1, 1], [1, 1, 1, 2, 2, 4],
    [1, 1, 1, 4, 2, 2], [1, 2, 1, 1, 2, 4], [1, 2, 1, 4, 2, 1], [1, 4, 1, 1, 2, 2],
    [1, 4, 1, 2, 2, 1], [1, 1, 2, 2, 1, 4], [1, 1, 2, 4, 1, 2], [1, 2, 2, 1, 1, 4],
    [1, 2, 2, 4, 1, 1], [1, 4, 2, 1, 1, 2], [1, 4, 2, 2, 1, 1], [2, 4, 1, 2, 1, 1],
    [2, 2, 1, 1, 1, 4], [4, 1, 3, 1, 1, 1], [2, 4, 1, 1, 1, 2], [1, 3, 4, 1, 1, 1],
    [1, 1, 1, 2, 4, 2], [1, 2, 1, 1, 4, 2], [1, 2, 1, 2, 4, 1], [1, 1, 4, 2, 1, 2],
    [1, 2, 4, 1, 1, 2], [1, 2, 4, 2, 1, 1], [4, 1, 1, 2, 1, 2], [4, 2, 1, 1, 1, 2],
    [4, 2, 1, 2, 1, 1], [2, 1, 2, 1, 4, 1], [2, 1, 4, 1, 2, 1], [4, 1, 2, 1, 2, 1],
    [1, 1, 1, 1, 4, 3], [1, 1, 1, 3, 4, 1], [1, 3, 1, 1, 4, 1], [1, 1, 4, 1, 1, 3],
    # non-characters 95-106
    [1, 1, 4, 3, 1, 1], [4, 1, 1, 1, 1, 3], [4, 1, 1, 3, 1, 1], [1, 1, 3, 1, 4, 1],
    [1, 1, 4, 1, 3, 1], [3, 1, 1, 1, 4, 1], [4, 1, 1, 1, 3, 1], [2, 1, 1, 4, 1, 2],
    [2, 1, 1, 2, 1, 4], [2, 1, 1, 2, 3, 2], [2, 3, 3, 1, 1, 1]
  ]


func toTableAValue(c: char): Code128Range =
  ## Convert char to value according to Table A
  case c
  of '\32' .. '\95': result = c.ord - 32  # printable range of Table A
  of '\0' .. '\31':  result = c.ord + 64
  else: raise newException(ValueError, "char out of Table A range: " & $c.ord)

func toTableBValue(c: char): Code128Range =
  ## Convert char to value according to Table B
  case c
  of '\32' .. '\127': result = c.ord - 32  # whole range of Table B
  else: raise newException(ValueError, "char out of Table B range: " & $c.ord)

func toTableCValue(ab: string): Code128Range =
  ## Convert string ab (len == 2) value according to Table C
  # ab is all digits as checked by caller
  assert ab.len == 2
  result = parseInt(ab)

func initCode128(s: string): Code128 =
  ## Intialize a new Code128 from `s`
  for c in s:
    if c notin tableBChars + tableAChars:
      raise newException(ValueError, "char not in allowed range: '" & $c & "' " & $c.ord)
  result.state = stateB
  result.s = s


func calcChecksum(code: Code128): Code128Range =
  ## Calculate the checksum for encoded string `s`
  var sum = 0
  for i, c in code.bar:
    if i == 0:
      sum = c
    else:
      inc sum, i * c  # value x position, 1-based excluding start
  result = sum mod 103


func addChecksum(code: var Code128) =
  ## Calculates and adds checksum to `code`
  code.bar.add calcChecksum(code)


func isStart(code: Code128): bool =
  ## Check if we're at start
  code.i == 0

func isDone(code: Code128): bool =
  ## Check if we're done
  not (code.i < code.s.len)


func addABChar(code: var Code128) =
  ## Add current char from table B to barcode
  assert code.state in {stateA, stateB}
  if code.isStart:
    if code.state == stateA: code.bar.add Shared.startA.Code128Range
    elif code.state == stateB: code.bar.add Shared.startB.Code128Range

  if code.state == stateA: code.bar.add toTableAValue(code.s[code.i])
  elif code.state == stateB: code.bar.add toTableBValue(code.s[code.i])

  # advance
  inc code.i


func addCChar(code: var Code128) =
  ## Add current pair of digits from table C to barcode
  assert code.state == stateC
  if code.isStart:
    code.bar.add Shared.startC.Code128Range
  let pair = code.s[code.i .. code.i+1]  # in range, conditions checked by caller
  code.bar.add toTableCValue(pair)
  # two added
  inc code.i, 2


func changeState(code: var Code128, newState: State) =
  ## Change state

  # jump table, invalid if not new state
  assert code.state != newState
  const jumps: array[State, array[State, Code128Range]] = [
    [100.Code128Range, CodeA.codeB.Code128Range, CodeA.codeB.Code128Range],  # A to B, C
    [CodeB.codeA.Code128Range, 100, CodeB.codeC.Code128Range], # B to A, C
    [CodeC.codeA.Code128Range, CodeC.codeB.Code128Range, 100], # C to A, B
  ]
  if not code.isStart:
    # only add switch if we haven't started yet, otherwise there should be a
    # start char
    code.bar.add jumps[code.state][newState]
  # switch state
  code.state = newState


func addStop(code: var Code128) =
  ## Add stop
  code.bar.add Shared.stop.Code128Range


func tableCConditions(code: Code128): bool =
  ## Check if conditions for adding from table C are still met
  if code.i > code.s.len - 2:
    return false
  elif code.s[code.i] notin Digits or code.s[code.i+1] notin Digits:
    return false
  result = true


func isTableCOptimal(code: Code128): bool =
  ## Test if table is optimal here
  var
    streak = 0
    i = code.i
  while i < code.s.len and code.s[i] in Digits:
    inc streak
    inc i
  if streak == 2 and code.s.len == 2:
    # entire data either of 2 or 4+ (not 3)
    result = true
  elif streak >= 4 and (code.isStart or code.i + streak == code.s.len):
    # beginning of data 4+
    # end of data 4+
    result = true
  elif streak >= 6:
    # middle of data 6+
    result = true


func toCode128*(s: string): Code128 {.exportc.} =
  ## Encodes `s` into a Code128 object
  var code = initCode128($s)

  while not code.isDone:
    case code.state
    of stateA:
      if isTableCOptimal(code):
        # switch to C, don't add char from s
        code.changeState(stateC)
      else:
        let currChar = s[code.i]
        if currChar notin tableAChars and currChar in tableBChars:
          # switch to B, don't add char from s
          # TODO: implement use of shift
          code.changeState(stateB)
        else:
          # add one char from table A
          code.addABChar
    of stateB:
      if isTableCOptimal(code):
        # switch to C, don't add char
        code.changeState(stateC)
      else:
        let currChar = s[code.i]
        if currChar notin tableBChars and currChar in tableAChars:
          # switch to A, don't add char from s
          # TODO: implement use of shift
          code.changeState(stateA)
        else:
          # add one char from table B
          code.addABChar
    of stateC:
      # we end up here because this was optimal given the current streak of
      # digits, continue until we are out of pairs of digits
      code.addCChar

      if not code.tableCConditions and not code.isDone:
        # conditions for table C are not met anymore
        let currChar = s[code.i]
        if currChar in tableBChars:
          # switch to B
          code.changeState(stateB)
        else:
          # switch to A
          code.changeState(stateA)

  # finish up
  code.addChecksum
  code.addStop

  # we're done
  result = code


const
  defaulty = "5%"
  defaultHeight = "90%"
  textHeight = "75%"
  texty = "95%"
  quiet = 10


func necessaryWidth(code: Code128): int =
  ## Calculate necessary width for code
  # 11 units per value in bar, 2 for stop and quiet padding beginning and end
  result = code.bar.len * 11 + 2 + 2 * quiet


func getSvgHeader(code: Code128; totalWidth, barcodeWidth, totalHeight: string,
  showFrame: bool): string =
  result = &"""
<svg width="{totalWidth}" height="{totalHeight}" xmlns="http://www.w3.org/2000/svg">

  <!-- Code128 barcode for the string "{code.s}" -->

  <!-- contents of nested tag will scale -->
  <svg viewBox="0 0 {barcodeWidth} {totalHeight}" preserveAspectRatio="none">

    <!-- background -->
"""

  if showFrame:
    result.add """    <rect width="100%" height="100%" fill="white" stroke-width="1" stroke="black" />"""
  else:
    result.add """    <rect width="100%" height="100%" fill="white" stroke-width="0" />"""
  result.add "\n"

func svgBar(x: int, width, height: string): string =
  &"""    <rect x="{x}" y="{defaulty}" width="{width}" height="{height}" stroke-width="0" />"""

func svgStopBars(x: var int, height: string): string =
  const stopWidth = 2
  result.add svgBar(x, $stopWidth, height)
  result.add "\n"
  inc x, stopWidth

func svgBars(c: Code128Range, x: var int, height: string, debug = false): string =
  ## Add SVG
  if debug:
    result.add &"  <!-- Code128 value {c}) -->\n"
  for i, width in barWidths[c]:
    if i mod 2 == 0:
      result.add svgBar(x, $width, height)
      result.add "\n"
    else:
      # add whitespace only
      if debug:
        result.add &"    <!-- whitespace width {width} -->\n"
    inc x, width

  # add final 2-width bar for stop
  if c == Shared.stop.Code128Range:
    result.add svgStopBars(x, height)

func getText(code: Code128, textSize, fontFamily: string): string =
  ## Set text in barcode
  result = &"""    <text x="50%" y="{texty}" font-size="{textSize}" font-family="{fontFamily}" text-anchor="middle">{code.s}</text>
"""

func toSvg*(code: Code128, height, width, textSize, fontFamily: string,
  showFrame=true, showText=true, debug=false): string {.exportc.} =
  ## Retrieves `code` as a SVG bar code
  let
    barcodeWidth = $necessaryWidth(code)
    barHeight = if showText: textHeight else: defaultHeight

  result = getSvgHeader(code, width, barcodeWidth, height, showFrame)
  var x = quiet
  result.add "    <!-- barcode -->\n"
  for c in code.bar:
    result.add svgBars(c, x, barHeight, debug)
  result.add "  </svg>\n"
  if showText:
    result.add "\n  <!-- text, does not scale -->\n"
    result.add "  <svg>\n"
    result.add getText(code, textSize, fontFamily)
    result.add "  </svg>\n"
  result.add "</svg>"


func toSvg*(code: Code128, debug=false): string =
  ## Fewer options, sensible defaults
  let barcodeWidth = $necessaryWidth(code)
  code.toSvg("80", barcodeWidth, "12", "sans-serif", debug=debug)

func unescapeInput(text: string): string =
  ## Unescapes a subset of characters to be able to input data like "hello\nworld"
  result = text.multiReplace(
     (r"\\", r"\"),
     (r"\n", "\n"),
     (r"\t", "\t"),
     (r"\f", "\f"),
     (r"\c", "\c")
  )

when defined(js):
  import dom

  proc genBarcode*() {.exportc.} =
    ## Generate a barcode
    let
      texts = ($document.getElementById("text").value).splitLines
      height = $document.getElementById("height").value
      width = $document.getElementById("width").value
      showframe = document.getElementById("showframe").checked
      showtext = document.getElementById("showtext").checked
      textsize = $document.getElementById("textsize").value
      fontfamily = $document.getElementById("fontfamily").value
      debugmode = document.getElementById("debugmode").checked
      rawmode = document.getElementById("rawmode").checked

    # clear output
    document.getElementById("barcode").innerHtml = ""
    document.getElementById("svgsource").innerHtml = ""

    for line in texts:
      if line.len == 0: continue
      let
        final = if rawmode: line.unescapeInput else: line
        code = toCode128(final)
        svg = code.toSvg(height, width, textsize, fontfamily, showframe, showtext, debugmode)
        source = svg.replace("<", "&lt;")

      document.getElementById("barcode").innerHtml &= svg.cstring
      document.getElementById("barcode").innerHtml &= "\n<br>\n".cstring

      document.getElementById("svgsource").innerHtml &= source.cstring
      document.getElementById("svgsource").innerHtml &= "\n\n"  # a bit ugly
else:
  import os
  echo paramCount()
  if paramCount() == 1:
    echo toCode128(paramStr(1)).toSvg
  elif paramCount() > 1:
    echo toCode128(paramStr(1)).toSvg(debug=true)
  else:
    echo "usage: code128 string debug:bool"
