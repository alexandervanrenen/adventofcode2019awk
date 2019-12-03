
awk -F ',' '

function draw(_route, _i, _x, _y, _max_x, _max_y, _output, _direction, _length, _size) {
  _max_x = center_x
  _max_y = center_y
  delete _output
  for(_route=0; _route<next_route_id; _route++) {
    _x = center_x
    _y = center_y
    _size = routes[_route, "size"]
    for(_i=0; _i<_size; _i++) {
      _direction = substr(routes[_route, _i], 1, 1)
      _length = substr(routes[_route, _i], 2)
      if(_direction == "R") {
        for(; _length>0; _length--) {
          _output[_x, _y] = _route ""
          _x++
        }
      } else if(_direction == "L") {
        for(; _length>0; _length--) {
          _output[_x, _y] = _route ""
          _x--
        }
      } else if(_direction == "U") {
        for(; _length>0; _length--) {
          _output[_x, _y] = _route ""
          _y++
        }
      } else if(_direction == "D") {
        for(; _length>0; _length--) {
          _output[_x, _y] = _route ""
          _y--
        }
      }
      _output[_x, _y] = _route ""

      _max_x = _x>_max_x ? _x : _max_x
      _max_y = _y>_max_y ? _y : _max_y
    }
  }

  for(_y=_max_y+2; _y>=0; _y--) {
    for(_x=0; _x<=_max_x+2; _x++) {
      printf "%s", (_output[_x, _y] ? _output[_x, _y] : "-")
    }
    print ""
  }
}

BEGIN {
  next_route_id = 0
  center_x = 2
  center_y = 2
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