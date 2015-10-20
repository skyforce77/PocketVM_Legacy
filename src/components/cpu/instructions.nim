const
  #Basic set
  INSTRUCTION_BEEP*: uint8 = 0x01 #Need two byte

  #Registers
  INSTRUCTION_MOVE*: uint8 = 0x10 #Need arg1 (byte/int/long/register) and arg2 register

  #Loops
  INSTRUCTION_GOTO*: uint8 = 0x22
  INSTRUCTION_IF_EQ*: uint8 = 0x23
  INSTRUCTION_IF_NE*: uint8 = 0x24
  INSTRUCTION_IF_GT*: uint8 = 0x25
  INSTRUCTION_IF_LW*: uint8 = 0x26
  INSTRUCTION_IF_GE*: uint8 = 0x27
  INSTRUCTION_IF_LE*: uint8 = 0x28

  #Operations
  INSTRUCTION_ADD*: uint8 = 0x31 #Need two args (byte/int/long/register) and arg3 register
  INSTRUCTION_SUB*: uint8 = 0x32
  INSTRUCTION_DIV*: uint8 = 0x33

  #Binary operations
  INSTRUCTION_SHIFT_LEFT*: uint8 = 0x40
  INSTRUCTION_SHIFT_RIGHT*: uint8 = 0x41
  INSTRUCTION_AND*: uint8 = 0x42
  INSTRUCTION_OR*: uint8 = 0x43
  INSTRUCTION_XOR*: uint8 = 0x44

  #Debug
  INSTRUCTION_PRINT*: uint8 = 0xff #Need one string,byte or register
