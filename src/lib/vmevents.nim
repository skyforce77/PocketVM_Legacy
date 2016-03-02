import events

const
  VM_INIT_EVENT*: string = "POCKETVM_INIT_EVENT" # Status args (0+ -> 0:Success, +:Something gone wrong)
  VM_GPU_SWAP_EVENT*: string = "POCKETVM_GPU_SWAP_EVENT" # Status args (0|1 -> buffer id)

type
  StatusEventArgs* = object of EventArgs
    status*: int

var VmEventEmitter*: EventEmitter = initEventEmitter()
