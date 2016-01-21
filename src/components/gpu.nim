const SCREEN_SIZE = 288000 #400*240*3 (colors)

const
  REFERENCE_BUFFER1: int = 0
  REFERENCE_BUFFER2: int = SCREEN_SIZE

type GPU = object
  buffer: array[SCREEN_SIZE*2, char]
  reference: int

proc swapBuffers(this: var GPU) =
  if this.reference == 0:
    this.reference = REFERENCE_BUFFER2
  else:
    this.reference = REFERENCE_BUFFER1

