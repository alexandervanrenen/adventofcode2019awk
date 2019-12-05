
awk -F "," '
function assertZero(arg) {
  if(arg != 0) {
    print "mode needs to be 0"
    exit
  }
}

{
  # awk cant really do interactive input, so we just read it from this array
  next_input = 0
  input[0] = 5

  pc = 0

  for(i = 1; i<=NF; i++) {
    mem[i-1] = $i
  }

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
      if(input[next_input] == "") {print "ERROR: no more input pc=" pc; exit}
      mem[mem[pc + 1]] = input[next_input]
      next_input++
      pc = pc + 2
    } else if(instruction == 4) { # output
      print op1
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

#  # Dump memory
#  for(i = 0; i<NF; i++) {
#    printf "%i ", mem[i]
#  }
#  print ""
}
'
