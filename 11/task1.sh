awk -F "," '
function assertZero(arg) {
  if(arg != 0) {
    print "mode needs to be 0"
    exit
  }
}

function GetNextInput() {
  next_input++
  if(next_input != 1) { print "ERROR: 2 input requests"; exit; }
  return current_color
}

function ReadMemory(idx) {
  if(length(mem[idx]) == 0) return 0
  return mem[idx]
}

function WriteMemory(idx, val) {
  mem[idx] = val
}

function DoOutput(val) {
  # Color was outputted
  if(next_output == 0) {
    print "paint: " val " at (" robo_pos_x "|" robo_pos_y ")"
    if(length(painting[robo_pos_x, robo_pos_y]) == 0) {
      painting_count++
    }
    painting[robo_pos_x, robo_pos_y] = val
    next_output = 1
    return
  }

  # Turn and move
  if(next_output == 1) {
    print "turn: " val " at (" robo_pos_x "|" robo_pos_y ")"
    # Turn
    if(val == TURN_LEFT) {
      robo_dir += 3
    } else {
      robo_dir += 1
    }
    robo_dir %= 4

    # Move
    if(robo_dir == UP) {
      robo_pos_y++
    } else if (robo_dir == DOWN) {
      robo_pos_y--
    } else if (robo_dir == LEFT) {
      robo_pos_x--
    } else if (robo_dir == RIGHT) {
      robo_pos_x++
    }

    # Read color
    next_input = 0
    if(length(painting[robo_pos_x, robo_pos_y]) == 0) {
      current_color = BLACK
    } else {
      current_color = painting[robo_pos_x, robo_pos_y]
    }

    next_output = 0
    return
  }
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
      outout_result = DoOutput(op1)
      pc = pc + 2
      if(outout_result == "PAUSE") {
        return "PAUSE"
      }
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
  BLACK = 0
  WHITE = 1

  TURN_LEFT = 0
  TURN_RIGHT = 1

  UP = 0
  LEFT = 1
  DOWN = 2
  RIGHT = 3

  # Setup intcode program
  for(i = 1; i<=NF; i++) {
    mem[i-1] = $i
  }
  pc = 0
  relative_base = 0

  # Run once for the robot
  painting_count = 0
  next_input = 0
  current_color = BLACK
  next_output = 0
  robo_pos_x = 0
  robo_pos_y = 0
  robo_dir = UP
  RunProgram()

  print painting_count
}
'
