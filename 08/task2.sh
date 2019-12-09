awk -F "," '
function assertTrue(_arg) {
  if(length(_arg) == 0 || !_arg) {
    print "assert failed"
    exit
  }
}

{
  width = 25
  height = 6

  split($0, digits, "")
  read_pointer = 1
  layer_count = length(digits) / (width * height)
  for(l=0; l<layer_count; l++) {
    for(y=0; y<height; y++) {
      for(x=0; x<width; x++) {
        data[l, y, x] = digits[read_pointer++]
      }
    }
  }
  assertTrue(read_pointer - 1 == length(digits))


  for(y=0; y<height; y++) {
    for(x=0; x<width; x++) {
      final[x, y] = data[0, y, x]
      for(l=1; l<layer_count && final[x, y] == 2; l++) {
        final[x, y] = data[l, y, x]
      }

      printf("%s", (final[x, y] == "1" ? "o" : " "))
    }
    print ""
  }
}
'
