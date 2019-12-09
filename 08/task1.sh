awk -F "," '
function assertTrue(_arg) {
  if(length(_arg) == 0 || !_arg) {
    print "assert failed"
    exit
  }
}

function DumpLayers(_l, _y, _x) {
  for(_l=0; _l<layer_count; _l++) {
    print "Layer " _l ": " GetNumberOfDigitsInLayer(_l, "0")
    for(_y=0; _y<height; _y++) {
      for(_x=0; _x<width; _x++) {
        printf("%i", data[_l, _y, _x])
      }
      print ""
    }
  }
}

function GetNumberOfDigitsInLayer(layer, digit, _sum, _x, _y) {
  _sum = 0
  for(_y=0; _y<height; _y++) {
    for(_x=0; _x<width; _x++) {
      if(data[layer, _y, _x] == digit) {
        _sum++
      }
    }
  }
  return _sum
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

  min_zero_count = GetNumberOfDigitsInLayer(0, "0")
  min_zero_layer = 0
  for(l=1; l<layer_count; l++) {
    zero_count = GetNumberOfDigitsInLayer(l, "0")
    if(zero_count < min_zero_count) {
      min_zero_count = zero_count
      min_zero_layer = l
    }
  }

  one_count = GetNumberOfDigitsInLayer(min_zero_layer, "1")
  two_count = GetNumberOfDigitsInLayer(min_zero_layer, "2")
  print("Checksum: ", one_count * two_count)
}
'
