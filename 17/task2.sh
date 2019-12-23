awk -F "," '
function abs(val) { return val >= 0 ? val : -val; }

function PrintArea() {
  distance_to_oxygen = -1
  for(y=0; y<max_y; y++) {
    for(x=0; x<max_x; x++) {
      if(x == robo_start_x && y == robo_start_y) {
        printf robo_start_direction
      } else {
        printf area[y, x]
      }
    }
    print "  | " y
  }
}

function TurnLeft(dir) {
  if(dir == "^") return "<"
  if(dir == "<") return "v"
  if(dir == "v") return ">"
  if(dir == ">") return "^"
}

function TurnRight(dir) {
  if(dir == "^") return ">"
  if(dir == "<") return "^"
  if(dir == "v") return "<"
  if(dir == ">") return "v"
}

function MoveXY(dir) {
  x = robo_x
  y = robo_y
  if(dir == "^") y--
  if(dir == "<") x--
  if(dir == "v") y++
  if(dir == ">") x++
}

function CalculatePath() {
  # Start
  robo_x = robo_start_x
  robo_y = robo_start_y
  if(robo_start_direction != "^") {
    print "no no no, this only works for robots looking up"; exit;
  }
  if(area[robo_y + 1, robo_x] == "#") { # Make robo look down
    path = "R,R"
    robo_direction = "v"
  } else if(area[robo_y - 1, robo_x] == "#") { # Make robo look down
    path = ""
    robo_direction = "^"
  } else if(area[robo_y, robo_x + 1] == "#") { # Make robo look down
    path = "R"
    robo_direction = ">"
  } else if(area[robo_y, robo_x - 1] == "#") { # Make robo look down
    path = "L"
    robo_direction = "<"
  } else {
    print "no starting path"; exit;
  }

  while(1){
    # Walk forward until end of world or end of scafoling
    walked = 0
    MoveXY(robo_direction)
    while(area[y, x] == "#") {
      walked++
      robo_x = x
      robo_y = y
      MoveXY(robo_direction)
    }
    path = path "," walked

    # Either need to turn left or right
    MoveXY(TurnLeft(robo_direction))
    if(area[y, x] == "#") {
      robo_direction = TurnLeft(robo_direction)
      path = path ",L"
    } else {
      MoveXY(TurnRight(robo_direction))
      if(area[y, x] == "#") {
        robo_direction = TurnRight(robo_direction)
        path = path ",R"
      } else {
        # Done
        break;
      }
    }
  }
}

function ReplaceFirstMaxFit(function_name) {
  split(path, commands, ",")
  start = 1
  while(commands[start] == "A" || commands[start] == "B" || commands[start] == "C") {
    start++
  }
  best_len = length(path)
  best_key = ""
  sub_path = commands[start]
  for(i=start+1; i<=length(commands); i++) {
    sub_path = sub_path "," commands[i]
    if(length(sub_path) > 20) {
      break;
    }
    path_tmp = path
    gsub(sub_path, function_name, path_tmp)
    if(best_len >= length(path_tmp)) {
      best_len = length(path_tmp)
      best_key = sub_path
    }
  }
  gsub(best_key, function_name, path)
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
    area[cur_y, cur_x] = "."
    cur_x++
  } else if(val == NEW_LINE) {
    if(cur_x > 0) { # For some reason there are two new lines next to the end
      printf "  | " max_y "\n"
      cur_y++
      max_y++
    }
    if(max_x < cur_x) {
      max_x = cur_x
    }
    cur_x = 0
  } else if(val == ROBOT_UP) {
    area[cur_y, cur_x] = "#"
    printf "^"
    robo_start_direction = "^"
    robo_start_x = cur_x
    robo_start_y = cur_y
    cur_x++
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
  print "program done"

  CalculatePath()
  print "new path: " path

  ReplaceFirstMaxFit("A")
  print "rep key: " best_key
  print "new path: " path
  function_a = best_key
  ReplaceFirstMaxFit("B")
  print "rep key: " best_key
  print "new path: " path
  function_b = best_key
  ReplaceFirstMaxFit("C")
  print "rep key: " best_key
  print "new path: " path
  function_c = best_key
  function_main = path

  print "Main: " function_main
  print "A: " function_a
  print "B: " function_b
  print "C: " function_c
}
'
