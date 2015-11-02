import os, strutils, unsigned, memory, cpu.instructions, cpu.types

#C import
proc getchar(): cchar {.importc, header: "<stdio.h>".}

#CPU Object
type CPU = object
  registers: array[16, uint64]
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

proc readNBytes(this: var CPU, n: int): uint64 =
  var value: uint64 = 0
  for i in countdown(n-1,0):
    var nvalue: uint64 = this.readByte()
    nvalue = nvalue shl uint64(8*i)
    value = value+nvalue
  return value

proc readShort(this: var CPU): uint16 =
  return uint16(this.readNBytes(2))

proc readInt(this: var CPU): uint32 =
  return uint32(this.readNBytes(4))

proc readLong(this: var CPU): uint64 =
  return this.readNBytes(8)

proc readString(this: var CPU): string =
  var str: string = ""
  while bufferRead(this.cursor) != char(0):
    str = str&bufferRead(this.cursor)
    this.cursor+=1
  this.cursor+=1
  return str

proc readValueForRegister(this: var CPU): uint64 =
  case this.readByte():
  of TYPE_REGISTER:
    return this.registers[int(this.readByte())]
  of TYPE_BYTE:
    return this.readByte()
  of TYPE_SHORT:
    return this.readShort()
  of TYPE_INT:
    return this.readInt()
  of TYPE_LONG:
    return this.readLong()
  else: return uint(0)

#Instructions
proc execPrint(this: var CPU) =
  case this.readByte():
  of TYPE_STRING:
    write(stdout, this.readString())
  of TYPE_BYTE:
    write(stdout, this.readByte())
  of TYPE_REGISTER:
    write(stdout, this.registers[int(this.readChar())])
  else: discard
  
proc execPutChar(this: var CPU) =
  case this.readByte():
  of TYPE_BYTE:
    write(stdout, this.readChar())
  of TYPE_REGISTER:
    write(stdout, char(this.registers[int(this.readChar())]))
  else: discard

proc execGetChar(this: var CPU) =
  case this.readByte():
  of TYPE_REGISTER:
    this.registers[int(this.readChar())] = uint64(getchar());
  else: discard

proc execBeep(this: var CPU) =
  case this.readByte():
  of TYPE_BYTE:
    write(stdout, this.readString())
  else: discard

proc execMove(this: var CPU) =
  var toMove: uint64 = this.readValueForRegister()
  case this.readByte():
  of TYPE_REGISTER:
    this.registers[int(this.readByte())] = toMove
  else: discard

proc execAdd(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  case this.readByte():
  of TYPE_REGISTER:
    this.registers[int(this.readByte())] = arg1+arg2
  else: discard

proc execSub(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  case this.readByte():
  of TYPE_REGISTER:
    this.registers[int(this.readByte())] = arg1-arg2
  else: discard

proc execMul(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  case this.readByte():
  of TYPE_REGISTER:
    this.registers[int(this.readByte())] = arg1*arg2
  else: discard

proc execDiv(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  case this.readByte():
  of TYPE_REGISTER:
    this.registers[int(this.readByte())] = arg1 div arg2
  else: discard

proc execMod(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  case this.readByte():
  of TYPE_REGISTER:
    this.registers[int(this.readByte())] = arg1 mod arg2
  else: discard

#Instructions slector
proc exec(this: var CPU) =
  case this.readByte():
    of INSTRUCTION_MOVE:
      this.execMove()
    of INSTRUCTION_ADD:
      this.execAdd()
    of INSTRUCTION_SUB:
      this.execSub()
    of INSTRUCTION_MUL:
      this.execMul()
    of INSTRUCTION_DIV:
      this.execDiv()
    of INSTRUCTION_MOD:
      this.execMod()
    of INSTRUCTION_PRINT:
      this.execPrint()
    of INSTRUCTION_PUT_CHAR:
      this.execPutChar()
    of INSTRUCTION_GET_CHAR:
      this.execGetChar()
    of INSTRUCTION_BEEP:
      this.execBeep()
    else: discard

#Start execution
proc start(this: var CPU) =
  while this.cursor < bufferSize():
    this.exec()
