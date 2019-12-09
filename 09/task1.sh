awk -F "," '
function assertZero(arg) {
  if(arg != 0) {
    print "mode needs to be 0"
    exit
  }
}

function GetNextInput() {
  return input[next_input++]
}

function ReadMemory(idx) {
  if(length(mem[idx]) == 0) return 0
  return mem[idx]
}

function WriteMemory(idx, val) {
  mem[idx] = val
}

function DoOutput(val) {
  print val
}

function DecodeAddress(address, mode) {
   if(mode == 0) {
    return ReadMemory(address)
  } else if(mode == 1) {
    return address
  } else if(mode == 2) {
    return relative_base + ReadMemory(address)
  } else {
    print "unknown mode: " mode
    exit
  }
}

# Global variables used (only the ones read and set for others to use):
# mem == The initial program, modified in-place
# GetNextInput == Function to access the next input
# DoOutput == Function to access the next input
function RunProgram() {
  while(1) {
    # Decode instruction
    opcode = ReadMemory(pc)
    instruction = opcode % 100
    mode1 = int(opcode / 100) % 10
    mode2 = int(opcode / 1000) % 10
    mode3 = int(opcode / 10000) % 10

    # Load parameters
    if(mode3 == 1) { print "ERROR: mode3 can not be 2!"; exit }
    addr1 = DecodeAddress(pc + 1, mode1)
    op1 = ReadMemory(addr1)
    addr2 = DecodeAddress(pc + 2, mode2)
    op2 = ReadMemory(addr2)
    addr3 = DecodeAddress(pc + 3, mode3)
    op3 = ReadMemory(addr3)

    # Execute instruction
    if(instruction == 99) { # exit
      return "HALT"
    } else if(instruction == 1) { # addition
      WriteMemory(addr3, op1 + op2)
      pc = pc + 4
    }
    else if(instruction == 2) { # muliplication
      WriteMemory(addr3, op1 * op2)
      pc = pc + 4
    } else if(instruction == 3) { # input
      if(mode1 == 1) { print "ERROR: Can not write to intermediate!"; exit}
      WriteMemory(addr1, GetNextInput())
      pc = pc + 2
    } else if(instruction == 4) { # output
      DoOutput(op1)
      pc = pc + 2
    } else if(instruction == 5) { # jump-if-true
      if(op1 != 0) {
        pc = op2
      } else {
        pc = pc + 3
      }
    } else if(instruction == 6) { # jump-if-false
      if(op1 == 0) {
        pc = op2
      } else {
        pc = pc + 3
      }
    } else if(instruction == 7) { # less than
      WriteMemory(addr3, op1 < op2 ? 1 : 0)
      pc = pc + 4
    } else if(instruction == 8) { # equals
      WriteMemory(addr3, op1 == op2 ? 1 : 0)
      pc = pc + 4
    } else if(instruction == 9) { # relative_base
      relative_base += op1
      pc = pc + 2
    } else {
      print "ERROR: Reached the end without 99"
      exit
    }
  }
}

{
  for(i = 1; i<=NF; i++) {
    mem[i-1] = $i
  }
  input[0] = 2

  pc = 0
  relative_base = 0
  RunProgram()
}
'
