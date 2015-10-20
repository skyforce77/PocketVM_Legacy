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
  of TYPE_REGISTER:
    write(stdout, this.registers[int(this.readChar())])
  else: nil

proc execBeep(this: var CPU) = #todo
  case this.readByte():
  of TYPE_BYTE:
    write(stdout, this.readString())
  else: nil
  
proc execMove(this: var CPU) =
  var toMove: uint32 = 0
  case this.readByte():
  of TYPE_BYTE:
    toMove = uint32(this.readByte())
  of TYPE_REGISTER:
    toMove = uint32(this.registers[int(this.readByte())])
  else: nil
  case this.readByte():
  of TYPE_REGISTER:
    this.registers[int(this.readByte())] = toMove
  else: nil

#Instructions slector
proc exec(this: var CPU) =
  case this.readByte():
    of INSTRUCTION_PRINT:
      this.execPrint()
    of INSTRUCTION_BEEP:
      this.execBeep()
    of INSTRUCTION_MOVE:
      this.execMove()
    else: nil
  this.cursor+=1

#Start execution
proc start(this: var CPU) =
  while this.cursor < bufferSize():
    this.exec()
