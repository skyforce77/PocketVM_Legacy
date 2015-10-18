import os, strutils, memory, cpu.instructions

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

proc execPrint(this: var CPU) =
  this.cursor+=1
  while bufferRead(this.cursor) != char(0):
    write(stdout, bufferRead(this.cursor))
    this.cursor+=1

proc exec(this: var CPU) =
  case uint8(bufferRead(this.cursor)):
    of INSTRUCTION_PRINT:
      this.execPrint()
    else:
      sleep(0)

proc start(this: var CPU) =
  while this.cursor < bufferSize():
    this.exec()
    this.cursor+=1
