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
  of "IF_NE":
    return 0x22
  of "IF_GT":
    return 0x23
  of "IF_LT":
    return 0x24
  of "IF_GE":
    return 0x25
  of "IF_LE":
    return 0x26
  of "ADD":
    return 0x31
  of "SUB":
    return 0x32
  of "MUL":
    return 0x33
  of "DIV":
    return 0x34
  of "MOD":
    return 0x35
  of "SHIFT_LEFT":
    return 0x40
  of "SHIFT_RIGHT":
    return 0x41
  of "AND":
    return 0x42
  of "OR":
    return 0x43
  of "XOR":
    return 0x44
  of "NOT":
    return 0x45
  of "GET_CHAR":
    return 0xfd
  of "PUT_CHAR":
    return 0xfe
  of "PRINT":
    return 0xff
  else:
    echo "Unknown code: ",val
    return 0x00

proc writeTranslated(this: File, val: var string) =
  if val.startsWith("r"):
    val.delete(first=0, last=0)
    this.write('\1')
    this.write(char(parseInt(val)))
  elif val.startsWith("\""):
    val.delete(first=0, last=0)
    val.delete(first=val.len-1, last=val.len-1)
    this.write('\2')
    this.write(val)
    this.write('\0')
  elif val.startsWith("'"):
    val.delete(first=0, last=0)
    val.delete(first=val.len-1, last=val.len-1)
    this.write('\3')
    this.write(val[0])
  elif val.startsWith("0x"):
    this.write('\3')
    this.write(char(parseHexInt(val)))
  else:
    let translated = val.getTranslation()
    if not(translated == 0):
      this.write(char(translated))
    else:
      echo translated

type Compiler = object
  filename: string

proc run(this: Compiler): string =
  if fileExists(this.filename):
    var compiled = this.filename.replace(".pvm","")
    var file = open(this.filename)
    var to = open(compiled, mode=fmReadWrite)
    while not file.endOfFile():
      var line = file.readLine()
      var split = line.split(" ")
      for inst in split:
        var vinst = inst.replace("\\n", "\n")
        vinst = vinst.replace("__", " ")
        if vinst.startsWith("\\"):
          vinst = unescape(inst)
        to.writeTranslated(vinst)
    to.close()
    file.close()
    return compiled
  else:
    echo "Could not compile: file does not exists"
    quit(QuitFailure)
