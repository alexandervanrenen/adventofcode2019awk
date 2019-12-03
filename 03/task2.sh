
awk -F ',' '

function set(output, x, y, route, _distance, _this_steps, _other_steps, _total_steps) {
  if(output[x, y, route] == "") {
    output[x, y, route] = step
  }
  step++

  if(output[x, y] != "" && output[x, y] != route && x!=0 && y!=0) {
    _this_steps = output[x, y, route]
    _other_steps = output[x, y, output[x, y]]
    _total_steps = _this_steps + _other_steps
    if(!closest_found || _total_steps < closest_steps) {
      closest_steps = _total_steps
      closest_x = x
      closest_y = y
      closest_found = 1
    }
  }
  output[x, y] = route
}

function draw(_route, _i, _x, _y, _max_x, _max_y, _min_x, _min_y, _output, _direction, _length, _size) {
  closest_found = false

  _max_x = center_x
  _max_y = center_y
  _min_x = center_x
  _min_y = center_y
  delete _output
  for(_route=0; _route<next_route_id; _route++) {
    _x = center_x
    _y = center_y
    step = 0
    _size = routes[_route, "size"]
    for(_i=0; _i<_size; _i++) {
      _direction = substr(routes[_route, _i], 1, 1)
      _length = substr(routes[_route, _i], 2)
      if(_direction == "R") {
        for(; _length>0; _length--) {
          set(_output, _x, _y, _route, step)
          _x++
        }
      } else if(_direction == "L") {
        for(; _length>0; _length--) {
          set(_output, _x, _y, _route, step)
          _x--
        }
      } else if(_direction == "U") {
        for(; _length>0; _length--) {
          set(_output, _x, _y, _route, step)
          _y++
        }
      } else if(_direction == "D") {
        for(; _length>0; _length--) {
          set(_output, _x, _y, _route, step)
          _y--
        }
      }

      _max_x = _x>_max_x ? _x : _max_x
      _max_y = _y>_max_y ? _y : _max_y
      _min_x = _x<_min_x ? _x : _min_x
      _min_y = _y<_min_y ? _y : _min_y
    }
    _output[_x, _y] = _route
  }

#  for(_y=_max_y+2; _y>=_min_y-2; _y--) {
#    for(_x=_min_x-2; _x<=_max_x+2; _x++) {
#      printf "%s", (_output[_x, _y] != "" ? _output[_x, _y] : "-")
#    }
#    print ""
#  }

  print (closest_found ? "yes" : "no")
  print closest_x " | " closest_y
  print closest_steps
}

BEGIN {
  next_route_id = 0
  center_x = 0
  center_y = 0
}

{
  for(i=1; i<=NF; i++) {
    routes[next_route_id, i-1] = $i
  }
  routes[next_route_id, "size"] = NF
  next_route_id++
}

END {
   draw()
}
'