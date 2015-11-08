import os, strutils, tables, hashes, math

type Compiler = object
  filename: string
  labels: TableRef[string, int64]
  jumps: TableRef[int64, string]

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
  of "JUMP":
    return 0x20
  of "ELSE":
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

proc writeTranslated(this: Compiler, to: File, val: var string) =
  if val.startsWith("r"):
    val.delete(first=0, last=0)
    to.write('\1')
    to.write(char(parseInt(val)))
  elif val.startsWith("\""):
    val.delete(first=0, last=0)
    val.delete(first=val.len-1, last=val.len-1)
    to.write('\2')
    to.write(val)
    to.write('\0')
  elif val.startsWith("'"):
    val.delete(first=0, last=0)
    val.delete(first=val.len-1, last=val.len-1)
    to.write('\3')
    to.write(val[0])
  elif val.startsWith("0x"):
    to.write('\3')
    to.write(char(parseHexInt(val)))
  elif val.startsWith(":"):
    val.delete(first=0, last=0)
    this.labels.add(key=val, val=to.getFileSize())
  elif val.startsWith(">"):
    val.delete(first=0, last=0)
    to.write('\6')
    this.jumps.add(key=to.getFileSize(), val=val)
    for i in countdown(7,0):
      to.write('\0')
  else:
    let translated = val.getTranslation()
    if not(translated == 0):
      to.write(char(translated))
    else:
      echo translated

proc rewriteJumps(this: Compiler, temp: File, file: File) =
  while not temp.endOfFile():
    if this.jumps.hasKey(file.getFileSize()):
      let index: int64 = this.labels.mget(this.jumps.mget(key=file.getFileSize()))
      for i in countdown(7,0):
        file.write(char(index shr int64(8*i)))
        discard temp.readChar()
    else:
      file.write(temp.readChar())

proc run(this: var Compiler): string =
  this.labels = newTable[string, int64]()
  this.jumps = newTable[int64, string]()
  if fileExists(this.filename):
    var compiled = this.filename.replace(".pvm","")
    var temp = compiled & ".temp"
    var file = open(this.filename)
    var to = open(temp, mode=fmReadWrite)
    while not file.endOfFile():
      var line = file.readLine()
      var split = line.split(" ")
      for inst in split:
        var vinst = inst.replace("\\n", "\n")
        vinst = vinst.replace("__", " ")
        if vinst.startsWith("\\"):
          vinst = unescape(inst)
        this.writeTranslated(to, vinst)
    file.close()
    to.close()
    var starts = open(temp, mode=fmRead)
    var ends = open(compiled, mode=fmReadWrite)
    this.rewriteJumps(starts,ends)
    starts.close()
    ends.close()
    removeFile(temp)
    return compiled
  else:
    echo "Could not compile: file does not exists"
    quit(QuitFailure)
