import dom, strutils, tables, unicode, htmlgen
import codetable

const codes* = genCodeTable()

# get elements

var
  codeForm = getElementById("codeForm")
  codeInput = InputElement getElementById("codeInput")
  parseButton = getElementById("parseButton")
  clearButton = getElementById("clearButton")
  codesButton = getElementById("codesButton")
  answerOutput = InputElement getElementById("answerOutput")


# event handling

proc resetInputOutput() =
  ## Reset input/output and set focus on input area
  echo "clearing fields"
  codeInput.value = ""
  answerOutput.value = ""
  codeInput.focus

  
proc formOnKeyDown*(event: Event) =
  ## Handle keyboard shortcuts
  ##
  ## Function keys proved difficult to handle so some other combinations are 
  ## used:
  ##
  ## ======   =====================================
  ## Key(s)   Event
  ## ======   =====================================
  ## Ctrl-3   Reset fields and focus on code input
  ## Ctrl-4   TODO: copy to clipboard
  ## Ctrl-5   TODO: show available codes
  ## Ctrl-O   Read list of codes and texts
  ## ======   =====================================
  ##
  ## The following are not planned to be implemented:
  ##
  ## ======   ============================
  ## Key(s)   Event
  ## ======   ============================
  ## Ctrl-6   N/A (was: make window modal)
  ## ======   ============================
  ##
  ## Key values can be found at
  ## https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values
  
  let event = KeyboardEvent(event)
  
  case $event.key
  of "3":
    if event.ctrlKey:
      resetInputOutput()
  else:
    discard


proc parseCodes() {.exportc.} =
  let shorts = strutils.splitWhitespace $codeInput.value
  if shorts.len == 0:
    return
  var text: seq[string]
  for short in shorts:
    echo "code '" & short & "'"
    if short notin codes:
      echo "...unknown!"
      window.alert "unknown short code: " & short
      return
    echo "ok"
    text.add codes[short].long
    
  # focusing first sets the cursor at end
  answerOutput.focus
  answerOutput.value = text.join("\n\n")


proc insertTextInplace() =
  let
    # get the text, we need unicode procs or non-ascii letters won't work
    text = toRunes($answerOutput.value)
    # were are we now?
    pos = answerOutput.selectionStart
  
    # pos of previous whitespace or start of the string
    prevPos = block:
      var prevPos = 0
      for i in countDown(pos-1, 0):
        if text[i] == Rune(' ') or text[i] == Rune('\n'):
          prevPos = i + 1
          break
      prevPos

  # the word
  let codeCandidate = $text[prevPos..<pos]
    
  if codeCandidate in codes:
    # unsupported in IE/Edge :(
    # answerOutput.setRangeText(codes[codeCandidate].long, prevPos, pos, "end")
    
    let 
      runeCode = toRunes(codes[codeCandidate].long)
      newText = text[0..<prevPos] & runeCode & text[pos..text.high]
    answerOutput.value = $newText
    
    # set cursor at end of inserted text
    answerOutput.selectionStart = pos + runeCode.len - codeCandidate.len
    answerOutput.selectionEnd = answerOutput.selectionStart


proc parseButtonClick(ev: Event) =
  parseCodes()


proc clearButtonClick(ev: Event) =
  resetInputOutput()


proc codesButtonClick(ev: Event) =
  ## Shows the code window

  var win = window.open("", "Available codes", "target=_blank,width=640px,height=440px,left=760,top=540")

  win.document.open()
  let contents = html:
    body:
      table(
        thead(
          tr(th("Kortkod"), th("Beskrivning"), th("Text"))
        ),
        tbody(
          block:
            var rows: string
            for value in codes.values:
              rows.add tr(td(value.short), td(value.description), td(value.long))
            rows
        )
      )
  
  echo contents
  win.document.write contents
  
proc codeInputKeydown(ev: Event) =
  let event = KeyboardEvent(ev)
  if $event.key == "Enter":
    # important, or nothing will happen
    event.preventDefault()
    parseCodes()


proc answerOutputKeydown(ev: Event) =
  let event = KeyboardEvent(ev)
  if $event.key == "Tab":
    # suppress default tab action
    event.preventDefault()
    insertTextInplace()
    
parseButton.addEventListener("click", parseButtonClick)
clearButton.addEventListener("click", clearButtonClick)
codesButton.addEventListener("click", codesButtonClick)
codeInput.addEventListener("keydown", codeInputKeydown)
answerOutput.addEventListener("keydown", answerOutputKeydown)

# not yet mature enough, intended for keyboard shortcuts
# codeForm.addEventListener("keydown", formOnKeyDown)