import strutils, os

## Supported are tables B, C. FNC are not supported

type
  State = enum
    # tableA
    tableB,
    tableC

  Code128 = object
    s: string  # input string
    bar: string  # the barcode
    i: int  # current index in s


const
  switchB = 200.char  ## switch to B
  switchC = 199.char  # switch to C
  startB = 204.char  ## start with B
  startC = 205.char  ## start with C
  stop = 206.char  ## stop


func assertValidCharacters(s: string): bool =
  ## Asserts that all characters are valid
  for c in s:
    if c.ord notin 32..127:
      return false
  result = true


func initCode128(s: string): Code128 =
  ## Intialize a new Code128 from `s`
  assert assertValidCharacters(s)
  result.s = s


func symbolToValue(c: char): char =
  ## Convert the ascii symbol to Code 128 value
  debugecho c.ord
  result = if c.ord <= 127:
    (c.ord - 32).char
  else:
    (c.ord - 100).char


func valueToSymbol(c: char): char =
  ## Convert the Code 128 value to ascii symbol
  debugecho c.ord
  result = if c.ord <= 94 :
    (c.ord + 32).char
  else:
    (c.ord + 100).char


func calcChecksum(s: string): char =
  ## Calculate the checksum for `s`
  var sum = 0
  for i, c in s:
    let value = symbolToValue(c)
    if i == 0:
      # index is "1" for the start code, so don't multiply by i
      sum = value.ord
    else:
      # value times position
      sum += value.ord * i
  # mod 103 and convert to char, could also mod 103 for each iteration
  result = (sum mod 103).char


func pairToChar(a, b: char): char =
  ## Encode two chars to one char according to table C
  const zero = '0'.ord
  result = ((a.ord - zero) * 10 + (b.ord - zero)).char


func addChecksum(code: var Code128) =
  ## Calculates and adds checksum to `code`
  code.bar.add calcChecksum(code.s)


func isStart(code: Code128): bool =
  ## Check if we're at start
  code.i == 0


func isDone(code: Code128): bool =
  ## Check if we're done
  not (code.i < code.s.len)


func addTableBChar(code: var Code128) =
  ## Add current char from table B to barcode
  if code.isStart:
    code.bar.add startB
  code.bar.add code.s[code.i]
  inc code.i


func addTableCChar(code: var Code128) =
  ## Add current pair of digits from table C to barcode
  if code.isStart:
    code.bar.add startC
  let
    a = code.s[code.i]
    b = code.s[code.i + 1]  # in range because conditions checked by caller
  code.bar.add valueToSymbol(pairToChar(a, b))
  inc code.i, 2


func toTableB(code: var Code128) =
  ## Switch to table B
  code.bar.add switchB


func toTableC(code: var Code128) =
  ## Switch to table C
  if not code.isStart:
    # only add switch if we haven't started with C
    code.bar.add switchC


func addStop(code: var Code128) =
  ## Add stop
  code.bar.add stop


func tableCConditions(code: Code128): bool =
  ## Check if conditions for adding from table C are still met
  result = true
  if code.i > code.s.len - 2:
    result = false
  elif code.s[code.i] notin Digits or code.s[code.i+1] notin Digits:
    result = false


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
    debugecho "whole: streak ", streak, " code.i ", code.i, " whole string len ", code.s.len
    result = true
  elif streak >= 4 and (code.isStart or code.i + streak == code.s.len):
    # beginning of data 4+
    # end of data 4+
    result = true
    debugecho "begin/end: streak ", streak, " code.i ", code.i, " whole string len ", code.s.len
  elif streak >= 6:
    # middle of data 6+
    result = true
    debugecho "middle: streak ", streak, " code.i ", code.i, " whole string len ", code.s.len


func code128*(s: string|cstring): string {.exportc.} =
  ## Encodes `s` into a Code128 formatted string
  var
    code = initCode128($s)
    state = tableB  # start with B

  while not code.isDone:
    case state
    of tableB:
      if isTableCOptimal(code):
        # switch to C, don't add char
        code.toTableC
        state = tableC
      else:
        # add one char with table B
        code.addTableBChar
    of tableC:
      # we end up here because this was optimal given the current streak of
      # digits, continue until we are out of pairs of digits
      code.addTableCChar

      if not code.tableCConditions:
        # conditions for table C are not met anymore, switch to table B
        code.toTableB
        state = tableB

  code.addChecksum
  code.addStop

  # we're done
  result = code.bar


proc main =
  if paramCount() < 1:
    quit("usage: code128 STRING [STRING ...] | iconv -f ISO-8859-15")

  for s in commandLineParams():
    echo code128(s)
    stdout.write "ascii: "
    for c in code128(s):
      stdout.write c.ord, " "
    stdout.write "\n"

when isMainModule:
  main()
