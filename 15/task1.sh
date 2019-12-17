awk -F "," '
function assertZero(arg) {
  if(arg != 0) {
    print "mode needs to be 0"
    exit
  }
}

function abs(val) { return val >= 0 ? val : -val; }

function CommandToString(cmd) {
  if(cmd == NORTH) return "NORTH"
  if( cmd == SOUTH) return "SOUTH"
  if( cmd == WEST) return "WEST"
  if( cmd == EAST) return "EAST"
  if( cmd == RET_NORTH) return "RET_NORTH"
  if( cmd == RET_SOUTH) return "RET_SOUTH"
  if( cmd == RET_WEST) return "RET_WEST"
  if( cmd == RET_EAST) return "RET_EAST"
  print "unkown command: " cmd
  exit
}

function RobotReturnToStirng(ret) {
  if(ret == HIT_WALL) return "HIT_WALL"
  if(ret == HAS_MOVED) return "HAS_MOVED"
  if(ret == FOUND_OXYGEN_SYSTEM) return "FOUND_OXYGEN_SYSTEM"
  print "unkown robot return code: " ret
  exit
}

function PrintArea() {
  distance_to_oxygen = -1
  for(y=max_y + 1; y>=min_y - 1; y--) {
    for(x=min_x - 1; x<=max_x + 1; x++) {
      if(length(area[x, y]) == 0) {
        printf " "
      } else {
        printf area[x, y]
      }
      if(area[x, y] == "O") {
        distance_to_oxygen = distance_from_start[x, y]
      }
    }
    print "  | " y
  }
  print "Oxygen distance: " distance_to_oxygen
}

function InverseDirection(dir) {
  if(dir == NORTH) return SOUTH
  if(dir == SOUTH) return NORTH
  if(dir == WEST) return EAST
  if(dir == EAST) return WEST
  print "unknown direction"
  exit
}

function PrintCommandQueue() {
  for(i=1; i<=length(command_queue); i++) {
    printf "%s,", CommandToString(command_queue[i])
  }
}

function GetNextInput() {
  if(length(command_queue) == 0) {
    PrintArea()
    print "done !?"
    exit
  }

  next_command = command_queue[length(command_queue)]
  delete command_queue[length(command_queue)]
  print "Command: " CommandToString(next_command) " " pos_x " " pos_y
  return abs(next_command)
}

function DoOutput(val) {
  steps++
  print steps " -> " RobotReturnToStirng(val)
  distance_to_prev_location = distance_from_start[pos_x, pos_y]

  # Hit a wall -> pos does not changed and no new options to explore
  if(val == HIT_WALL) {
    if(next_command <= 0) { print "error"; exit; }
    if(next_command == NORTH) area[pos_x, pos_y+1] = "#"
    if(next_command == SOUTH) area[pos_x, pos_y-1] = "#"
    if(next_command == WEST) area[pos_x+1, pos_y] = "#"
    if(next_command == EAST) area[pos_x-1, pos_y] = "#"
    return;
  }

  # Otherwise, the field was walkable
  # Update position
  if(abs(next_command) == NORTH) pos_y += 1
  if(abs(next_command) == SOUTH) pos_y -= 1
  if(abs(next_command) == WEST) pos_x += 1
  if(abs(next_command) == EAST) pos_x -= 1
  min_x = pos_x < min_x ? pos_x : min_x
  max_x = pos_x > max_x ? pos_x : max_x
  min_y = pos_y < min_y ? pos_y : min_y
  max_y = pos_y > max_y ? pos_y : max_y

  # We walked back -> no new info
  if(next_command <= 0) {
    return
  }

  # Was here already ? -> just go back
  if(length(area[pos_x, pos_y]) > 0) {
    if(distance_to_prev_location + 1 < distance_from_start[pos_x, pos_y]) {
      distance_from_start[pos_x, pos_y] = distance_to_prev_location + 1
    }
    command_queue[length(command_queue) + 1] = -InverseDirection(next_command)
    return
  } else {
    distance_from_start[pos_x, pos_y] = distance_to_prev_location + 1
  }

  # Mark area
  if(val == HAS_MOVED) {
    area[pos_x, pos_y] = "."
  } else if(val == FOUND_OXYGEN_SYSTEM) {
    area[pos_x, pos_y] = "O"
  } else {
    print "unknown return"
    exit
  }

  # Add new commands
  command_queue[length(command_queue) + 1] = -InverseDirection(next_command)
  if(next_command != NORTH) command_queue[length(command_queue) + 1] = SOUTH
  if(next_command != SOUTH) command_queue[length(command_queue) + 1] = NORTH
  if(next_command != WEST) command_queue[length(command_queue) + 1] = EAST
  if(next_command != EAST) command_queue[length(command_queue) + 1] = WEST
}

function ReadMemory(idx) {
  if(length(mem[idx]) == 0) return 0
  return mem[idx]
}

function WriteMemory(idx, val) {
  mem[idx] = val
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
  pos_x = 0
  pos_y = 0

  min_x = 0
  max_x = 0
  min_y = 0
  max_y = 0

  NORTH = 1
  SOUTH = 2
  WEST = 3
  EAST = 4

  RET_NORTH = -1
  RET_SOUTH = -2
  RET_WEST = -3
  RET_EAST = -4

  command_queue[1] = NORTH
  command_queue[2] = SOUTH
  command_queue[3] = EAST
  command_queue[4] = WEST

  distance_from_start[0, 0] = 0
  area[0, 0] = "."

  HIT_WALL = 0 # The repair droid hit a wall. Its position has not changed.
  HAS_MOVED = 1 # The repair droid has moved one step in the requested direction.
  FOUND_OXYGEN_SYSTEM = 2 # The repair droid has moved one step in the requested direction; its new position is the location of the oxygen system.

  # Setup intcode program
  for(i = 1; i<=NF; i++) {
    mem[i-1] = $i
  }
  pc = 0
  relative_base = 0

  RunProgram()

  print "done"
}
'