import os, strutils, memory, cpu.instructions, cpu.types

type CPU = object
  registers: array[16, uint32]
  cursor: int

proc load(this: var CPU, filename: string): bool {.discardable.} =
  let file: File = open(filename)
  if file == nil:
    return false
  file.toMemory()
  file.close()
  return true
  
proc readByte(this: var CPU): uint8 =
  var typ: uint8 = uint8(bufferRead(this.cursor))
  this.cursor+=1
  return typ
  
proc readChar(this: var CPU): char =
  var typ: char = bufferRead(this.cursor)
  this.cursor+=1
  return typ
  
proc readString(this: var CPU): string =
  var str: string = ""
  while bufferRead(this.cursor) != char(0):
    str = str&bufferRead(this.cursor)
    this.cursor+=1
  return str

proc execPrint(this: var CPU) =
  case this.readByte():
  of TYPE_STRING:
    write(stdout, this.readString())
  else:
    sleep(0)

proc exec(this: var CPU) =
  case this.readByte():
    of INSTRUCTION_PRINT:
      this.execPrint()
    else:
      sleep(0)

proc start(this: var CPU) =
  while this.cursor < bufferSize():
    this.exec()
    this.cursor+=1
