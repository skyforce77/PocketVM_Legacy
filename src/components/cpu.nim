import os, strutils, memory, cpu.instructions

type CPU = object
  registers: array[16, uint32]
  cursor: int

proc load(this: CPU, filename: string): bool {.discardable.} =
  let file: File = open(filename)
  if file == nil:
    return false
  file.toMemory()
  file.close()
  return true

proc execPrint(this: CPU) =
  this.cursor.inc()
  while bufferRead(this.cursor) != 0:
    write(stdout, bufferRead(this.cursor))
    this.cursor.inc()

proc exec(this: CPU) =
  case bufferRead(this.cursor):
    of INSTRUCTION_PRINT:
      this.execPrint()

proc start(this: CPU) =
  while this.cursor < bufferSize():
    this.exec()
