import os, strutils

const BUFFER_SIZE = 4096
var buffer: array[BUFFER_SIZE, char]
var size: int = 0

proc bufferSize*(): int = size
proc bufferRead*(index: int): char = buffer[index]

proc toMemory*(file: File) =
  while not endOfFile(file) and size < BUFFER_SIZE:
    buffer[size] = readChar(file)
    size+=1
