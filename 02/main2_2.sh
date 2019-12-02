
awk -F "," '

function resolve_write_history(address, ts) {
  for(; ts>=0; ts--) {
    if(destination[ts] == address) {
      return "(" resolve_write_history(operands_lhs[ts], ts) operator[ts] resolve_write_history(operands_rhs[ts], ts) ")"
    }
  }
  if(address == 1) {
    return "x"
  }
  if(address == 2) {
    return "y"
  }
  return original[address]
}

{
  for(i = 0; i<NF; i++) {
    mem[i] = $(i+1)
    original[i] = $(i+1)
  }

  mem[1] = 12
  mem[2] = 2

  pc = 0
  my_next = 0

  while(1) {
    if(mem[pc] == 99) {
      break;
    }
    else if(mem[pc] == 1) {
      operator[my_next] = "+"
      operands_lhs[my_next] = mem[pc + 1]
      operands_rhs[my_next] = mem[pc + 2]
      destination[my_next] = mem[pc + 3]
      final[my_next] = mem[mem[pc + 1]] "+" mem[mem[pc + 2]]
      my_next++

      mem[mem[pc + 3]] =  mem[mem[pc + 1]] + mem[mem[pc + 2]]
    }
    else if(mem[pc] == 2) {
      operator[my_next] = "*"
      operands_lhs[my_next] = mem[pc + 1]
      operands_rhs[my_next] = mem[pc + 2]
      destination[my_next] = mem[pc + 3]
      final[my_next] = mem[mem[pc + 1]] "*" mem[mem[pc + 2]]
      my_next++

      mem[mem[pc + 3]] =  mem[mem[pc + 1]] * mem[mem[pc + 2]]
    }
    pc = pc + 4
  }

  for(i=my_next-1; i>=0; i--) {
    if(destination[i] == 0) {
      print resolve_write_history(operands_lhs[i], i) operator[i] resolve_write_history(operands_rhs[i], i)
    }
  }
}
'
