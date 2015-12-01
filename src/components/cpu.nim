import os, strutils, cpu.instructions, cpu.types, cpu.flags
include memory

#C import
proc getchar(): cchar {.importc, header: "<stdio.h>".}

#CPU Object
type CPU = object
  memory: Memory
  registers: array[16, uint64]
  flags: array[8, bool]
  cursor: int64

#Loading CPU
proc load(this: var CPU, filename: string): bool {.discardable.} =
  let file: File = open(filename)
  if file == nil:
    return false
  this.memory = Memory()
  this.memory.init();
  this.memory.loadCode(file)
  file.close()
  return true

#Read program
proc readByte(this: var CPU): uint8 =
  var typ: uint8 = uint8(this.memory.bufferRead(this.cursor))
  this.cursor+=1
  return typ

proc readChar(this: var CPU): char =
  var typ: char = this.memory.bufferRead(this.cursor)
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
  while this.memory.bufferRead(this.cursor) != char(0):
    str = str&this.memory.bufferRead(this.cursor)
    this.cursor+=1
  this.cursor+=1
  return str

proc readRegister(this: var CPU): uint64 =
  var intid: int = int(this.readByte())
  if intid >= 0 and intid <= 15:
    return this.registers[intid]
  else:
    return uint64(0)

proc readValueForRegister(this: var CPU): uint64 =
  case this.readByte():
  of TYPE_REGISTER:
    return this.readRegister()
  of TYPE_BYTE:
    return this.readByte()
  of TYPE_SHORT:
    return this.readShort()
  of TYPE_INT:
    return this.readInt()
  of TYPE_LONG:
    return this.readLong()
  else: return uint(0)

proc writeRegister(this: var CPU, value: uint64) =
  var intid: int = int(this.readByte())
  if intid >= 0 and intid <= 15:
    this.registers[intid] = value;
  else:
    discard

proc zapBytes(this: var CPU, number: int) =
  for i in 1..number:
    discard this.readChar()

#Instructions
proc execPrint(this: var CPU) =
  case this.readByte():
  of TYPE_STRING:
    write(stdout, this.readString())
  of TYPE_BYTE:
    write(stdout, this.readByte())
  of TYPE_REGISTER:
    write(stdout, this.readRegister())
  else: discard

proc execPutChar(this: var CPU) =
  case this.readByte():
  of TYPE_BYTE:
    write(stdout, this.readChar())
  of TYPE_REGISTER:
    write(stdout, char(this.readRegister()))
  else: discard

proc execGetChar(this: var CPU) =
  case this.readByte():
  of TYPE_REGISTER:
    this.writeRegister(uint64(getchar()));
  else: discard

proc execJump(this: var CPU) =
  let pointer: uint64 = this.readValueForRegister()
  this.cursor = int64(pointer)

proc execMove(this: var CPU) =
  var toMove: uint64 = this.readValueForRegister()
  case this.readByte():
  of TYPE_REGISTER:
    this.writeRegister(toMove)
  else: discard

proc execPush(this: var CPU) =
  var toPush: uint64 = this.readValueForRegister()
  this.memory.push(toPush);

proc execPop(this: var CPU) =
  discard this.readByte()
  this.writeRegister(this.memory.pop());

proc execStore(this: var CPU) =
  var id: uint64 = this.readValueForRegister()
  var value: uint64 = this.readValueForRegister()
  this.memory.store(id, value);

proc execLoad(this: var CPU) =
  var id: uint64 = this.readValueForRegister()
  discard this.readByte()
  this.writeRegister(this.memory.load(id));

proc execAdd(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  case this.readByte():
  of TYPE_REGISTER:
    this.writeRegister(arg1+arg2)
  else: discard

proc execSub(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  case this.readByte():
  of TYPE_REGISTER:
    this.writeRegister(arg1-arg2)
  else: discard

proc execMul(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  case this.readByte():
  of TYPE_REGISTER:
    this.writeRegister(arg1*arg2)
  else: discard

proc execDiv(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  case this.readByte():
  of TYPE_REGISTER:
    this.writeRegister(arg1 div arg2)
  else: discard

proc execMod(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  case this.readByte():
  of TYPE_REGISTER:
    this.writeRegister(arg1 mod arg2)
  else: discard

proc execShiftLeft(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  case this.readByte():
  of TYPE_REGISTER:
    this.writeRegister(arg1 shl arg2)
  else: discard

proc execShiftRight(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  case this.readByte():
  of TYPE_REGISTER:
    this.writeRegister(arg1 shr arg2)
  else: discard

proc execAnd(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  case this.readByte():
  of TYPE_REGISTER:
    this.writeRegister(arg1 and arg2)
  else: discard

proc execOr(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  case this.readByte():
  of TYPE_REGISTER:
    this.writeRegister(arg1 or arg2)
  else: discard

proc execXor(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  case this.readByte():
  of TYPE_REGISTER:
    this.writeRegister(arg1 xor arg2)
  else: discard

proc execNot(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  case this.readByte():
  of TYPE_REGISTER:
    this.writeRegister(not arg1)
  else: discard

proc execIfEQ(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  if arg1 == arg2:
    this.zapBytes(9)

proc execIfNE(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  if not (arg1 == arg2):
    this.zapBytes(9)

proc execIfLT(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  if arg1 < arg2:
    this.zapBytes(9)

proc execIfGT(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  if arg1 > arg2:
    this.zapBytes(9)

proc execIfLE(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  if arg1 <= arg2:
    this.zapBytes(9)

proc execIfGE(this: var CPU) =
  let arg1: uint64 = this.readValueForRegister()
  let arg2: uint64 = this.readValueForRegister()
  if arg1 >= arg2:
    this.zapBytes(9)

#Instructions selector
proc exec(this: var CPU) =
  case this.readByte():
    of INSTRUCTION_MOVE:
      this.execMove()
    of INSTRUCTION_PUSH:
      this.execPush()
    of INSTRUCTION_POP:
      this.execPop()
    of INSTRUCTION_STORE:
      this.execStore()
    of INSTRUCTION_LOAD:
      this.execLoad()
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
    of INSTRUCTION_SHIFT_LEFT:
      this.execShiftLeft()
    of INSTRUCTION_SHIFT_RIGHT:
      this.execShiftRight()
    of INSTRUCTION_AND:
      this.execAnd()
    of INSTRUCTION_OR:
      this.execOr()
    of INSTRUCTION_XOR:
      this.execXor()
    of INSTRUCTION_NOT:
      this.execNot()
    of INSTRUCTION_PRINT:
      this.execPrint()
    of INSTRUCTION_PUT_CHAR:
      this.execPutChar()
    of INSTRUCTION_GET_CHAR:
      this.execGetChar()
    of INSTRUCTION_JUMP:
      this.execJump()
    of INSTRUCTION_IF_EQ:
      this.execIfEQ()
    of INSTRUCTION_IF_NE:
      this.execIfNE()
    of INSTRUCTION_IF_LT:
      this.execIfLT()
    of INSTRUCTION_IF_GT:
      this.execIfGT()
    of INSTRUCTION_IF_LE:
      this.execIfLE()
    of INSTRUCTION_IF_GE:
      this.execIfGE()
    else: discard

#Start execution
proc start(this: var CPU) =
  while this.cursor < this.memory.bufferSize():
    this.exec()
