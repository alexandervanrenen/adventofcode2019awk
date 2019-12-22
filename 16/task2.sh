awk '

function abs(val) { return val < 0 ? -val : val; }

function ApplyPhaseSecondHalf(signal)
{
   result = 0;
   size = length(signal)
   for (result_digit = size; result_digit>pos_in_result; result_digit--) {
      result += signal[result_digit];
      signal[result_digit] = abs(result) % 10;
   }
}

function DuplicateInput(how_often_to_use_input_pattern) {
  original_length = length(signal)
  for(a=1; a<how_often_to_use_input_pattern; a++) {
    for(b=1; b<=original_length; b++) {
      signal[a * original_length + b] = signal[b]
    }
  }
  print "Created input: " length(signal)
}

{
  split($0, signal, "")
  DuplicateInput(10000)
  print "Using input of length: " length(signal)
  pos_in_result = substr($0, 1, 7)

  for(phase=1; phase<=100; phase++) {
    ApplyPhaseSecondHalf(signal)
    print "Phase: " phase
  }

  print "Looking at " pos_in_result
  for(i=pos_in_result; i<pos_in_result+8; i++) {
    printf "%i", signal[i + 1];
  }
  print ""
}
'