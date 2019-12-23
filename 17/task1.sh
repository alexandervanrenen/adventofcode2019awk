awk -F "," '
function abs(val) { return val >= 0 ? val : -val; }

function PrintArea() {
  distance_to_oxygen = -1
  for(y=0; y<max_y; y++) {
    for(x=0; x<max_x; x++) {
      if(length(area[y, x]) == 0) {
        printf "."
      } else if(IsCrossing(x, y)) {
        printf "O"
      } else {
        printf area[y, x]
      }
    }
    print "  | " y
  }
}

function IsCrossing(x, y) {
  return area[y, x] == "#" && area[y, x-1] == "#" && area[y, x+1] == "#" && area[y-1, x] == "#" && area[y+1, x] == "#";
}

function GetNextInput() {
  print "Input required"
  exit
}

function DoOutput(val) {
  if(val == SCAFFOLD) {
    printf "#"
    area[cur_y, cur_x] = "#"
    cur_x++
  } else if(val == NOTHING) {
    printf "."
    cur_x++
  } else if(val == NEW_LINE) {
    printf "\n"
    cur_y++
    max_y++
    if(max_x < cur_x) {
      max_x = cur_x
    }
    cur_x = 0
  } else if(val == ROBOT_UP) {
    printf "^"
  } else {
    print "Unexpected output! \"" val "\""
    exit
  }
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
  SCAFFOLD = 35
  NOTHING = 46
  NEW_LINE = 10
  ROBOT_UP = 94
  ROBOT_DOWN = ""
  ROBOT_LEFT = ""
  ROBOT_RIGHT = ""

  max_x = 0
  max_y = 0
  cur_x = 0
  cur_y = 0

  # Setup intcode program
  for(i = 1; i<=NF; i++) {
    mem[i-1] = $i
  }
  pc = 0
  relative_base = 0

  RunProgram()

  print "done"
  PrintArea()

  result = 0
  for(key in area) {
    split(key, sep, SUBSEP);
    y = sep[1]
    x = sep[2]
    if(IsCrossing(x, y)) {
      result += (x * y)
      print x "|" y " -> " x*y
    }
  }
  print result
}
'