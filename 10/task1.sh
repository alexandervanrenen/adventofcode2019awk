awk -F "," '

function abs(val) { return val >= 0 ? val : -val; }
function sigma(val) { return val == 0 ? 0 : val > 0 ? 1 : -1; }
function is_int(val) { return val == int(val); }

function CanSee(src_x, src_y, dest_x, dest_y) {
#  print "CanSee ("src_x "|" src_y ") -> (" dest_x "|" dest_y ")"
  diff_x = dest_x - src_x
  diff_y = dest_y - src_y
  if(abs(diff_x) > abs(diff_y)) {
    step_x = sigma(diff_x)
    step_y = diff_y / abs(diff_x)
    step_count = 1
    cur_x = src_x + step_x
    cur_y = src_y + (step_count * step_y)
    while(cur_x != dest_x) {
      if(is_int(cur_y) && asteroids[cur_y, cur_x] == "#") {
        return 0;
      }
      step_count++
      cur_x += step_x
      cur_y = src_y + (step_count * step_y)
    }
  } else {
    step_x = diff_x / abs(diff_y)
    step_y = sigma(diff_y)
    step_count = 1
    cur_x = src_x + (step_count * step_x)
    cur_y = src_y + step_y
    while(cur_y != dest_y) {
      if(is_int(cur_x) && asteroids[cur_y, cur_x] == "#") {
        return 0;
      }
      step_count++
      cur_y += step_y
      cur_x = src_x + (step_count * step_x)
    }
  }
  return 1
}

function NumberOfVisibleAsteroidsFromGivenPosition(src_x, src_y, _x, _y, _sum) {
  _sum = 0
  for(_y=0; _y<height; _y++) {
    for(_x=0; _x<width; _x++) {
      if(asteroids[_y, _x] == "#" && (_x != src_x || _y != src_y)) {
        if(CanSee(src_x, src_y, _x, _y)) {
#          print "yes"
          _sum++
        } else {
#          print "no"
        }
      }
    }
  }
  return _sum
}

BEGIN {
  height = 0
  delete asteroids
}

{
  split($0, chars, "")
  width = length(chars)
  for(i=1; i<=width; i++) {
    asteroids[height, i-1] = chars[i]
  }
  height++
}

END {
  best = 0
  best_x = 0
  best_y = 0

  for(y=0; y<height; y++) {
    for(x=0; x<width; x++) {
      if(asteroids[y, x] == "#") {
        seen_asteroid_count = NumberOfVisibleAsteroidsFromGivenPosition(x, y)
        printf "%i", seen_asteroid_count
        if(seen_asteroid_count > best) {
          best = seen_asteroid_count
          best_x = x
          best_y = y
        }
      } else {
        printf "."
      }
    }
    print ""
  }

  print "Best: " best " @(" best_x "|" best_y ")"
}
'
