awk -F "," '
function assertZero(arg) {
  if(arg != 0) {
    print "mode needs to be 0"
    exit
  }
}

function GetNextInput(_result) {
    if(next_input == 0) {
      next_input++
      return module_id
    } else {
      return prev_module_output
    }
}

function DoOutput(val) {
  module_output = val
}

function ResetMemory(_i) {
  for(_i = 1; _i<=NF; _i++) {
    mem[_i-1] = original_mem[_i-1]
  }
}

# Global variables used (only the ones read and set for others to use):
# mem == The initial program, modified in-place
# GetNextInput == Function to access the next input
# DoOutput == Function to access the next input
function RunProgram() {

  pc = 0

  while(1) {
    # Decode instruction
    opcode = mem[pc]
    instruction = opcode % 100
    mode1 = int(opcode / 100) % 10
    mode2 = int(opcode / 1000) % 10
    mode3 = int(opcode / 10000) % 10

    # Load parameters
    assertZero(mode3)
    op1 = mode1 == 0 ? mem[mem[pc + 1]] : mem[pc + 1]
    op2 = mode2 == 0 ? mem[mem[pc + 2]] : mem[pc + 2]

    # Execute instruction
    if(instruction == 99) { # exit
      break
    } else if(instruction == 1) { # addition
      mem[mem[pc + 3]] = op1 + op2
      pc = pc + 4
    }
    else if(instruction == 2) { # muliplication
      mem[mem[pc + 3]] = op1 * op2
      pc = pc + 4
    } else if(instruction == 3) { # input
      assertZero(mode1)
      mem[mem[pc + 1]] = GetNextInput()
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
      mem[mem[pc + 3]] = op1 < op2 ? 1 : 0
      pc = pc + 4
    } else if(instruction == 8) { # equals
      mem[mem[pc + 3]] = op1 == op2 ? 1 : 0
      pc = pc + 4
    } else {
      print "ERROR: Reached the end without 99"
      exit
    }
  }
}

{
  for(i = 1; i<=NF; i++) {
    original_mem[i-1] = $i
    mem[i-1] = $i
  }

  best_module_output = 0
  for(amp[0]=0; amp[0]<5; amp[0]++) {
    for(amp[1]=0; amp[1]<5; amp[1]++) {
      if(amp[1] == amp[0]) continue;
      for(amp[2]=0; amp[2]<5; amp[2]++) {
        if(amp[2] == amp[0] || amp[2] == amp[1]) continue;
        for(amp[3]=0; amp[3]<5; amp[3]++) {
          if(amp[3] == amp[0] || amp[3] == amp[1] || amp[3] == amp[2]) continue;
          for(amp[4]=0; amp[4]<5; amp[4]++) {
            if(amp[4] == amp[0] || amp[4] == amp[1] || amp[4] == amp[2] || amp[4] == amp[3]) continue;

            # Run all amplifiers
            module_output = 0
            for(amp_id=0; amp_id<5; amp_id++) {
              ResetMemory()
              module_id = amp[amp_id]
              prev_module_output = module_output
              next_input = 0
              RunProgram()
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

#  # Dump memory
#  for(i = 0; i<NF; i++) {
#    printf "%i ", mem[i]
#  }
#  print ""
}
'
