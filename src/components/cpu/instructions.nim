const
  #Basic set
  #todo
  INSTRUCTION_BEEP*: uint8 = 0x01 #Need two byte

  #Registers
  INSTRUCTION_MOVE*: uint8 = 0x10 #Need arg1 (byte/int/long/register) and arg2 register
  INSTRUCTION_PUSH*: uint8 = 0x11 #Need arg1 (byte/int/long/register)
  INSTRUCTION_POP*: uint8 = 0x12 #Need arg1 register/void
  INSTRUCTION_STORE*: uint8 = 0x13 #Need arg1 register
  INSTRUCTION_LOAD*: uint8 = 0x14 #Need arg1 register

  #Loops
  INSTRUCTION_JUMP*: uint8 = 0x20 #Need jump value >label
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

  #Debug
  INSTRUCTION_GET_CHAR*: uint8 = 0xfd #Need one register
  INSTRUCTION_PUT_CHAR*: uint8 = 0xfe #Need one byte or register
  INSTRUCTION_PRINT*: uint8 = 0xff #Need one string, byte or register
