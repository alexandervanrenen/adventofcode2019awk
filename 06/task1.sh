
awk -F ")" '
function GetOrbitCount(planet) {
  if(planet == "COM") {
    return 0;
  }
  return 1 + GetOrbitCount(parent[planet])
}

BEGIN {
  delete parent["COM"]
}

{
  master = $1
  planet = $2
  parent[planet] = master
}

END {
  sum = 0
  for (planet in parent) { # iterates over keys
    sum += GetOrbitCount(planet);
  }
  print sum
}
'
