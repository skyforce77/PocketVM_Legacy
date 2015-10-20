import os, strutils, memory, cpu.instructions, cpu.types

#CPU Object
type CPU = object
  registers: array[16, uint32]
  cursor: int

#Loading CPU
proc load(this: var CPU, filename: string): bool {.discardable.} =
  let file: File = open(filename)
  if file == nil:
    return false
  file.toMemory()
  file.close()
  return true

#Read program
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

#Instructions
proc execPrint(this: var CPU) =
  case this.readByte():
  of TYPE_STRING:
    write(stdout, this.readString())
  of TYPE_BYTE:
    write(stdout, this.readChar())
  else: nil

proc execBeep(this: var CPU) =
  case this.readByte():
  of TYPE_BYTE:
    write(stdout, this.readString())
  else: nil

#Instructions slector
proc exec(this: var CPU) =
  case this.readByte():
    of INSTRUCTION_PRINT:
      this.execPrint()
    of INSTRUCTION_BEEP:
      this.execBeep()
    else:
      sleep(0)

#Start execution
proc start(this: var CPU) =
  while this.cursor < bufferSize():
    this.exec()
    this.cursor+=1
