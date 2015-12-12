import os, strutils, sequtils, tables

const BUFFER_SIZE = 4096

type Memory = object
  buffer: array[BUFFER_SIZE, char]
  size: int64
  stack: seq[uint64]
  heap: TableRef[int64, int64]

proc init*(this: var Memory) =
  this.stack = newSeq[uint64]()
  this.heap = newTable[int64, int64]()

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
  this.heap.add(key=int64(id), val=int64(value))

proc load*(this: var Memory, id: uint64): uint64 =
  var value: uint64 = 0
  if this.heap.hasKey(int64(id)):
    value = uint64(this.heap.mgetOrPut(int64(id),0))
  return value
