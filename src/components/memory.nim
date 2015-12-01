import os, strutils

const BUFFER_SIZE = 4096
type Memory = object
    buffer: array[BUFFER_SIZE, char]
    size: int64
    stack: seq[uint64]

proc bufferSize*(this: var Memory): int64 = this.size
proc bufferRead*(this: var Memory, index: int64): char = this.buffer[index]

proc loadCode*(this: var Memory, file: File) =
  while not file.endOfFile() and this.size < BUFFER_SIZE:
    this.buffer[this.size] = file.readChar()
    this.size+=1

proc push*(this: var Memory, value: uint64) =
    this.stack.add(value)

proc pop*(this: var Memory, value: uint64): uint64 =
    var last = this.stack[this.stack.len()]
    this.stack.delete(this.stack.len())
    return last
