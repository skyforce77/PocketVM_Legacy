import os, strutils

const BUFFER_SIZE = 4096
var buffer: array[BUFFER_SIZE, uint8]
var size: int = 0

proc bufferSize*(): int = size
proc bufferRead*(index: int): uint8 = buffer[index]

proc toMemory*(file: File) =
  while not endOfFile(file) and size < BUFFER_SIZE:
    buffer[size] = (uint8)readChar(file)
    size+=1
