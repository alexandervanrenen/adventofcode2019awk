
awk -F "," '
{
  for(i = 0; i<=NF; i++) {
    initial_memory[i] = $i
  }

  for(noun=0; noun<=99; noun++) {
    print "noun=" noun
    for(verb=0; verb<=99; verb++) {
      for(i = 0; i<=NF; i++) {
        $i = initial_memory[i]
      }

      $2 = noun
      $3 = verb

      pc = 1

      while(1) {
        if($pc == 99) {
          break;
        }
        else if($pc == 1) {
#          print $(pc + 0) ", " $(pc + 1) ", " $(pc + 2) ", " $(pc + 3)
#          print $($(pc + 3) + 1), " = ", $($(pc + 1) + 1), " + ", $($(pc + 2) + 1)
          $($(pc + 3) + 1) =  $($(pc + 1) + 1) + $($(pc + 2) + 1)
        }
        else if($pc == 2) {
#          print $(pc + 0) ", " $(pc + 1) ", " $(pc + 2) ", " $(pc + 3)
#          print $($(pc + 3) + 1), " = ", $($(pc + 1) + 1), " * ", $($(pc + 2) + 1)
          $($(pc + 3) + 1) =  $($(pc + 1) + 1) * $($(pc + 2) + 1)
        }
        pc = pc + 4
      }

      if($1 == 19690720) {
        print noun
        print verb
        print $0
      }
    }
  }
}
'
