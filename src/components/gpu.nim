import iup

const
  SCREEN_SIZE = 288000 #400*240*3 (colors)
  REFERENCE_BUFFER1: uint64 = 0
  REFERENCE_BUFFER2: uint64 = SCREEN_SIZE

type GPU = object
  buffer: array[SCREEN_SIZE*2, byte]
  reference: uint64
  threadRefresh: Thread[int]
  threadScreen: Thread[int]

proc threadRefreshScreen(arg: int) {.thread.} =
  while true:
    #SCREEN WRITING
    sleep(33)

proc threadShowScreen(arg: int) {.thread.} =
  discard iup.open(nil, nil)
  var fileItemLoad = iup.item("Load", "")
  var fileItemSave = iup.item("Save", "")
  var fileItemClose = iup.item("Close", "")
  var fileMenu = iup.menu(fileItemLoad, fileItemSave, fileItemClose, nil)
  var mainMenu = iup.menu(iup.subMenu("File", fileMenu), nil)
  discard iup.setHandle("mainMenu", mainMenu)
  var dlg = iup.dialog(nil)
  iup.setAttribute(dlg, "TITLE", "PocketVM")
  iup.setAttribute(dlg, "SIZE", "200x100")
  iup.setAttribute(dlg, "MENU", "mainMenu")
  discard iup.showXY(dlg, IUP_CENTER, IUP_CENTER)
  discard iup.mainLoop()

proc init*(this: var GPU) =
  createThread(this.threadRefresh, threadRefreshScreen, 0)
  createThread(this.threadScreen, threadShowScreen, 0)
  #joinThreads(this.threadScreen)

proc swapBuffers*(this: var GPU) =
  if this.reference == 0:
    this.reference = REFERENCE_BUFFER2
  else:
    this.reference = REFERENCE_BUFFER1

proc write*(this: var GPU, x: uint64, y: uint64, color: uint64) =
  let refer: uint64 = this.reference+x*(240*3)+y*3
  this.buffer[refer] = uint8(color shr 16 and 0xFF)
  this.buffer[refer+1] = uint8(color shr 8 and 0xFF)
  this.buffer[refer+2] = uint8(color and 0xFF)
