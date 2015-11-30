import strutils

const BUFFER_SIZE = 4096
var buffer: array[BUFFER_SIZE, char]
var size: int64 = 0

proc bufferSize*(): int64 = size
proc bufferRead*(index: int64): char = buffer[index]

#proc toMemory*(file: File) =
#  while not file.endOfFile() and size < BUFFER_SIZE:
#    buffer[size] = file.readChar()
#    size+=1
