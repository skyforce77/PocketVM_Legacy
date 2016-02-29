import iup, events
include "../lib/vmevents"

const
  SCREEN_SIZE = 288000 # 400*240*3 (colors)
  REFERENCE_BUFFER1: uint64 = 0
  REFERENCE_BUFFER2: uint64 = SCREEN_SIZE

type GPU = object
  buffer: array[SCREEN_SIZE*2, byte]
  reference: uint64

proc swapBuffers*(this: var GPU) =
  if this.reference == 0:
    this.reference = REFERENCE_BUFFER2
  else:
    this.reference = REFERENCE_BUFFER1

  # Emit VM_GPU_SWAP_EVENT
  var args = StatusEventArgs()
  args.status = int(this.reference == 0);
  VmEventEmitter.emit(VM_GPU_SWAP_EVENT, args)

proc write*(this: var GPU, x: uint64, y: uint64, color: uint64) =
  let refer: uint64 = this.reference+x*(240*3)+y*3
  this.buffer[refer] = uint8(color shr 16 and 0xFF)
  this.buffer[refer+1] = uint8(color shr 8 and 0xFF)
  this.buffer[refer+2] = uint8(color and 0xFF)
