import os, strutils, sequtils, tables, hashes

const BUFFER_SIZE = 4096

proc hash*(x: uint64): Hash {.inline.} =
  result = toU32(int64(x))

type Memory = object
  buffer: array[BUFFER_SIZE, char]
  size: int64
  stack: seq[uint64]
  heap: TableRef[uint64, uint64]

proc init*(this: var Memory) =
  this.stack = newSeq[uint64]()
  this.heap = newTable[uint64, uint64]()

proc bufferSize*(this: var Memory): int64 = this.size
proc bufferRead*(this: var Memory, index: int64): char = this.buffer[index]

proc loadCode*(this: var Memory, file: File) =
  while not file.endOfFile() and this.size < BUFFER_SIZE:
    this.buffer[this.size] = file.readChar()
    this.size+=1

proc push*(this: var Memory, value: uint64) =
  this.stack.add(value)

proc pop*(this: var Memory): uint64 =
  if not this.stack.len() == 0:
    var last = this.stack[this.stack.len()-1]
    this.stack.delete(this.stack.len()-1)
    return last
  else:
    return uint64(0)

proc store*(this: var Memory, id: uint64, value: uint64) =
  if this.heap.contains(id):
    this.heap.del(id)
  this.heap.add(key=id, val=value)

proc load*(this: var Memory, id: uint64): uint64 =
  var value: uint64 = 0
  if this.heap.hasKey(id):
    value = this.heap.mgetOrPut(id,0)
  return value
