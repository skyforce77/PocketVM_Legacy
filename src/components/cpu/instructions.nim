const
  #VM
  #todo
  INSTRUCTION_VM_ID*: uint8 = 0x01 #Need arg1 register
  INSTRUCTION_VM_VERSION*: uint8 = 0x02 #Need arg1 register
  INSTRUCTION_VM_CHECK_VERSION*: uint8 = 0x03 #Need arg1 min, arg2 max (0 to bypass check: VM_CHECK_VERSION 0x01 0x00 will check >= 1)

  #Registers
  INSTRUCTION_MOVE*: uint8 = 0x10 #Need arg1 (byte/int/long/register) and arg2 register
  INSTRUCTION_PUSH*: uint8 = 0x11 #Need arg1 (byte/int/long/register)
  INSTRUCTION_POP*: uint8 = 0x12 #Need arg1 register/void
  INSTRUCTION_STORE*: uint8 = 0x13 #Need arg1 register
  INSTRUCTION_LOAD*: uint8 = 0x14 #Need arg1 register

  #Loops
  INSTRUCTION_JUMP*: uint8 = 0x20 #Need arg1 (byte/int/long/register)  jump value >label
  INSTRUCTION_IF_EQ*: uint8 = 0x21 #Need two args (byte/int/long/register) and ELSE >endofblock
  INSTRUCTION_IF_NE*: uint8 = 0x22 #Same
  INSTRUCTION_IF_GT*: uint8 = 0x23 #Same
  INSTRUCTION_IF_LT*: uint8 = 0x24 #Same
  INSTRUCTION_IF_GE*: uint8 = 0x25 #Same
  INSTRUCTION_IF_LE*: uint8 = 0x26 #Same

  #Operations
  INSTRUCTION_ADD*: uint8 = 0x31 #Need two args (byte/int/long/register) and arg3 register
  INSTRUCTION_SUB*: uint8 = 0x32 #Same as above
  INSTRUCTION_MUL*: uint8 = 0x33 #Same too
  INSTRUCTION_DIV*: uint8 = 0x34 #Too
  INSTRUCTION_MOD*: uint8 = 0x35 #Too...

  #Binary operations
  INSTRUCTION_SHIFT_LEFT*: uint8 = 0x40 #Need two args (byte/int/long/register) and arg3 register
  INSTRUCTION_SHIFT_RIGHT*: uint8 = 0x41 #Same as above
  INSTRUCTION_AND*: uint8 = 0x42 #Same too
  INSTRUCTION_OR*: uint8 = 0x43 #Too
  INSTRUCTION_XOR*: uint8 = 0x44 #Too...
  INSTRUCTION_NOT*: uint8 = 0x45 #Need one arg (byte/int/long/register) and arg2 register

  #GPU operations
  INSTRUCTION_GPU_SWAP_BUFFERS*: uint8 = 0x50 #Without argument
  #todo
  INSTRUCTION_GPU_CLEAR*: uint8 = 0x51 #No args
  INSTRUCTION_GPU_COLOR*: uint8 = 0x52 #Arg1 byte red, arg2 byte green, arg3 byte blue OR arg1 int color
  INSTRUCTION_GPU_WRITE*: uint8 = 0x53 #Arg1 pixel x, arg2 y
  INSTRUCTION_GPU_DRAW_LINE*: uint8 = 0x54 #Arg1 ax, arg2 ay, arg3 bx, arg4 by

  #Debug
  INSTRUCTION_GET_CHAR*: uint8 = 0xfd #Need one register
  INSTRUCTION_PUT_CHAR*: uint8 = 0xfe #Need one byte or register
  INSTRUCTION_PRINT*: uint8 = 0xff #Need one arg (string/byte/short/int/long/register)
