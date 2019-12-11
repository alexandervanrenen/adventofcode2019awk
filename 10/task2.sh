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

function GetAllAsteroidsForVaporization(src_x, src_y, _next, _x, _y) {
  _next = 0
  for(_y=0; _y<height; _y++) {
    for(_x=0; _x<width; _x++) {
      if(asteroids[_y, _x] == "#" && (_x != src_x || _y != src_y)) {
        if(CanSee(src_x, src_y, _x, _y)) {
          vec_x = _x - src_x
          vec_y = _y - src_y
          angle = (atan2(vec_y, vec_x) / pi) * 180
          if(angle >= 0) {
            angle -= 360
          }
          angle += 90
          if(angle >= 0) {
            angle -= 360
          }
          print angle " (" _x "|" _y ")"
        }
      }
    }
  }
}

BEGIN {
  pi = atan2(0, -1)
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

function GetAngle(x, y) {
    angle = (atan2(y, x) / pi) * 180
    if(angle >= 0) {
      angle -= 360
    }
    angle += 90
    if(angle >= 0) {
      angle -= 360
    }
#    angle *= -1
#    angle += 270
#    angle %= 360
    print angle " (" x "|" y ")"
}

END {
  best_x = 26
  best_y = 29

#  GetAngle(10, 1)
#  GetAngle(10, -1)
#  GetAngle(-10, -1)
#  GetAngle(-10, 1)

  GetAllAsteroidsForVaporization(best_x, best_y)
}
' | sort -n | awk 'BEGIN {c=1} {print c++, $0}'
