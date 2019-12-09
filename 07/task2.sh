awk -F "," '
function assertZero(arg) {
  if(arg != 0) {
    print "mode needs to be 0"
    exit
  }
}

function CopyArray(to, from, _k) {
  delete to
  for(_k in from) {
    to[_k] = from[_k]
  }
}

function GetNextInput(_result) {
  if(amp_next_input[amp_id] == 0) {
    amp_next_input[amp_id]++
    return module_id
  } else {
    return prev_module_output
  }
}

function ReadMemory(idx) {
  return amp_mem[amp_id , idx]
}

function WriteMemory(idx, val) {
  amp_mem[amp_id , idx] = val
}

function DoOutput(val) {
  module_output = val
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
    assertZero(mode3)
    op1 = mode1 == 0 ? ReadMemory(ReadMemory(pc + 1)) : ReadMemory(pc + 1)
    op2 = mode2 == 0 ? ReadMemory(ReadMemory(pc + 2)) : ReadMemory(pc + 2)

    # Execute instruction
    if(instruction == 99) { # exit
      return "HALT"
    } else if(instruction == 1) { # addition
#      print "add @" pc " (op1=" op1 ", op2=" op2 ")"
      WriteMemory(ReadMemory(pc + 3), op1 + op2)
      pc = pc + 4
    }
    else if(instruction == 2) { # muliplication
#      print "mul @" pc " (op1=" op1 ", op2=" op2 ")"
      WriteMemory(ReadMemory(pc + 3), op1 * op2)
      pc = pc + 4
    } else if(instruction == 3) { # input
#      print "input @" pc " (op1=" op1 ", op2=" op2 ")"
      assertZero(mode1)
      WriteMemory(ReadMemory(pc + 1), GetNextInput())
      pc = pc + 2
    } else if(instruction == 4) { # output
#      print "output @" pc " (op1=" op1 ", op2=" op2 ")"
      DoOutput(op1)
      pc = pc + 2
      return "OUTPUT"
    } else if(instruction == 5) { # jump-if-true
#      print "jmp-if-true @" pc " (op1=" op1 ", op2=" op2 ")"
      if(op1 != 0) {
        pc = op2
      } else {
        pc = pc + 3
      }
    } else if(instruction == 6) { # jump-if-false
#      print "jmp-if-false @" pc " (op1=" op1 ", op2=" op2 ")"
      if(op1 == 0) {
        pc = op2
      } else {
        pc = pc + 3
      }
    } else if(instruction == 7) { # less than
#      print "lt @" pc " (op1=" op1 ", op2=" op2 ")"
      WriteMemory(ReadMemory(pc + 3), op1 < op2 ? 1 : 0)
      pc = pc + 4
    } else if(instruction == 8) { # equals
#      print "eq @" pc " (op1=" op1 ", op2=" op2 ")"
      WriteMemory(ReadMemory(pc + 3), op1 == op2 ? 1 : 0)
      pc = pc + 4
    } else {
      print "ERROR: Reached the end without 99"
      exit
    }
  }
}

function ResetMemory() {
  for(i = 1; i<=NF; i++) {
    amp_mem[0, i-1] = original_mem[i-1]
    amp_mem[1, i-1] = original_mem[i-1]
    amp_mem[2, i-1] = original_mem[i-1]
    amp_mem[3, i-1] = original_mem[i-1]
    amp_mem[4, i-1] = original_mem[i-1]
  }

  amp_next_input[0] = 0;
  amp_next_input[1] = 0;
  amp_next_input[2] = 0;
  amp_next_input[3] = 0;
  amp_next_input[4] = 0;

  amp_pc[0] = 0;
  amp_pc[1] = 0;
  amp_pc[2] = 0;
  amp_pc[3] = 0;
  amp_pc[4] = 0;
}

{
  for(i = 1; i<=NF; i++) {
    original_mem[i-1] = $i
  }

  best_module_output = 0
  for(amp[0]=5; amp[0]<10; amp[0]++) {
    for(amp[1]=5; amp[1]<10; amp[1]++) {
      if(amp[1] == amp[0]) continue;
      for(amp[2]=5; amp[2]<10; amp[2]++) {
        if(amp[2] == amp[0] || amp[2] == amp[1]) continue;
        for(amp[3]=5; amp[3]<10; amp[3]++) {
          if(amp[3] == amp[0] || amp[3] == amp[1] || amp[3] == amp[2]) continue;
          for(amp[4]=5; amp[4]<10; amp[4]++) {
            if(amp[4] == amp[0] || amp[4] == amp[1] || amp[4] == amp[2] || amp[4] == amp[3]) continue;

            # Run all amplifiers
            ResetMemory()
            module_output = 0
            return_code = ""

            # Run until terminates
            while(return_code != "HALT") {
              for(amp_id=0; amp_id<5; amp_id++) {
                module_id = amp[amp_id]
                pc = amp_pc[amp_id]
                prev_module_output = module_output
                return_code = RunProgram()
                amp_pc[amp_id] = pc
              }
            }

            # Report:
            if(module_output > best_module_output) {
              best_module_output = module_output
              best_sequence = sprintf("%i,%i,%i,%i,%i", amp[0], amp[1], amp[2], amp[3], amp[4])
            }
          }
        }
      }
    }
  }

  print "Found best sequence: " best_module_output " (" best_sequence ")"
}
'
