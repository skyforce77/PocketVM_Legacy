import iup, events, "../lib/vmevents", math, hashes

const
  SCREEN_SIZE = 288000 # 400*240*3 (colors)
  REFERENCE_BUFFER1: uint64 = 0
  REFERENCE_BUFFER2: uint64 = SCREEN_SIZE
  SCREEN_WIDTH = 400
  SCREEN_HEIGHT = 240

type GPU = object
  buffer: array[SCREEN_SIZE*2, byte]
  reference: uint64
  color: uint64

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

proc write*(this: var GPU, x: uint64, y: uint64) =
  let refer: uint64 = this.reference+x*(240*3)+y*3
  this.buffer[refer] = uint8(this.color shr 16 and 0xFF)
  this.buffer[refer+1] = uint8(this.color shr 8 and 0xFF)
  this.buffer[refer+2] = uint8(this.color and 0xFF)

proc clear*(this: var GPU) =
  for x in 0..SCREEN_WIDTH-1:
    for y in 0..SCREEN_HEIGHT-1:
      this.write(uint64(x), uint64(y), uint64(0x00))

proc color*(this: var GPU, r: uint8, g: uint8, b: uint8) =
  this.color = uint64(((r and 0xFF) shl 16 ) or ((g and 0xFF) shl 8) or ((b and 0xFF) shl 0))

proc color*(this: var GPU, color: uint64) =
  this.color = color

proc drawLine*(this: var GPU, x1: var uint64, y1: var uint64, x2: var uint64, y2: var uint64) =
  var dx: uint64
  var dy: uint64
  var e: uint64

  e = x2 - x1
  dx = e + x2
  dy = (y2 - y1) * 2
  while x1 <= x2:
    this.write(x1, y1)
    x1 = x1 + 1
    e = e - dy
    if (e) <= 0:
        y1 = y1 + 1
        e = e + dx
