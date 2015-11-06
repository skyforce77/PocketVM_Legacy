import os, strutils

proc getTranslation(val: string): uint8 =
  case val:
  of "BEEP":
    return 0x01
  of "MOVE":
    return 0x10
  of "PUSH":
    return 0x11
  of "POP":
    return 0x12
  of "GOTO":
    return 0x20
  of "IF_EQ":
    return 0x21
  else:
    echo "Unknown code: ",val
    discard

proc writeTranslated(this: File, val: var string) =
  if val.startsWith("\""):
    val.delete(first=0, last=0)
    val.delete(first=val.len-1, last=val.len-1)
    echo val
    #this.write(val)
  else:
    let translated = val.getTranslation()
    echo translated
    #write(char(translated))

type Compiler = object
  filename: string

proc run(this: Compiler): string =
  if fileExists(this.filename):
    var compiled = this.filename.replace(".pvm","")
    var file = open(this.filename)
    var to = open(compiled)
    while not file.endOfFile():
      var line = file.readLine()
      var split = line.split(" ")
      for inst in split:
        var vinst = inst
        to.writeTranslated(vinst)
    to.close()
    file.close()
    return compiled
  else:
    echo "Could not compile: file does not exists"
    quit(QuitFailure)
