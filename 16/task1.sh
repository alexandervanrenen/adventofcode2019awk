awk '

function abs(val) { return val < 0 ? -val : val; }

function ApplyPhase() {
  for(result_digit=1; result_digit<=length(signal); result_digit++) {
    result = 0
    for(digit=1; digit<=length(signal); digit++) {
      base_offset = int((digit) / result_digit) % 4

      if(base_offset == 1) {
        result += signal[digit]
      } else if(base_offset == 3) {
        result -= signal[digit]
      }
    }

    next_signal[result_digit] = abs(result) % 10
  }

  for(i=1; i<=length(next_signal); i++) {
    signal[i] = next_signal[i]
  }
}

{
  base_1 = 0
  base_2 = 1
  base_3 = 0
  base_4 = -1

  split($0, signal, "")
  print length(signal)

# Code to double problem size
#  xxx = length(signal)
#  for(_i=1;_i<=xxx;_i++) {
#    signal[xxx + _i] = signal[_i]
#  }

  for(phase=1; phase<=100; phase++) {
    ApplyPhase()
  }

  for(_i=1;_i<=8;_i++) {
    printf "%i", signal[_i];
  }
  print ""
}
'