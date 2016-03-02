import os, strutils, tables, hashes, math

type Compiler = object
  filename: string
  tomake: string
  labels: TableRef[string, int64]
  jumps: TableRef[int64, string]

proc getTranslation(val: string): uint8 =
  case val:
  of "VM_ID":
    return 0x01
  of "VM_VERSION":
    return 0x02
  of "VM_CHECK_VERSION":
    return 0x03
  of "MOVE":
    return 0x10
  of "PUSH":
    return 0x11
  of "POP":
    return 0x12
  of "STORE":
    return 0x13
  of "LOAD":
    return 0x14
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
  of "GPU_SWAP_BUFFERS":
    return 0x50
  of "GET_CHAR":
    return 0xfd
  of "PUT_CHAR":
    return 0xfe
  of "PRINT":
    return 0xff
  else:
    echo "Unknown code: ",val
    return 0x00

proc writeNBytes(to: File, n: int, value: uint64) =
  for i in countdown(n-1,0):
    to.write(char(value shr uint64(8*i)))

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
  elif val.startsWith("0x") and val.len() == 16+2:
    to.write('\6')
    to.writeNBytes(8, uint64(parseHexInt(val)))
  elif val.startsWith("0x") and val.len() == 8+2:
    to.write('\5')
    to.writeNBytes(4, uint64(parseHexInt(val)))
  elif val.startsWith("0x") and val.len() == 4+2:
    to.write('\4')
    to.writeNBytes(2, uint64(parseHexInt(val)))
  elif val.startsWith("0x") and val.len() == 2+2:
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
      let index: uint64 = uint64(this.labels.mgetOrPut(this.jumps.mgetOrPut(key=file.getFileSize(),""),0))
      for i in countdown(7,0):
        file.write(char(index shr uint64(8*i)))
        discard temp.readChar()
    else:
      file.write(temp.readChar())

iterator splitInstruction(s: string): string =
  var last = 0
  if len(s) > 0:
    while last <= len(s):
      var first = last
      if s[first] == '"':
        inc(last)
        while last < len(s) and s.substr(last, last + <1) != "\"":
          inc(last)
        inc(last)
      else:
        while last < len(s) and s.substr(last, last + <1) != " ":
          inc(last)
      yield substr(s, first, last-1)
      inc(last, 1)

proc splitInstruction(s: string): seq[string] =
  accumulateResult(s.splitInstruction())

proc run(this: var Compiler): string =
  this.labels = newTable[string, int64]()
  this.jumps = newTable[int64, string]()
  if fileExists(this.filename):
    if this.tomake == nil:
      this.tomake = this.filename.replace(".pvm","")
    var temp = this.tomake & ".temp"
    var file = open(this.filename)
    var to = open(temp, mode=fmReadWrite)
    while not file.endOfFile():
      var line = file.readLine()
      if not line.startsWith("//"):
        line = line.strip(leading=true, trailing=false)
        var split = line.splitInstruction()
        for inst in split:
          var vinst = inst.replace("\\n", "\n")
          if vinst.startsWith("\\"):
            vinst = unescape(inst)
          this.writeTranslated(to, vinst)
    file.close()
    to.close()
    var starts = open(temp, mode=fmRead)
    var ends = open(this.tomake, mode=fmReadWrite)
    this.rewriteJumps(starts,ends)
    starts.close()
    ends.close()
    removeFile(temp)
    return this.tomake
  else:
    echo "Could not compile: file does not exists"
    quit(QuitFailure)
