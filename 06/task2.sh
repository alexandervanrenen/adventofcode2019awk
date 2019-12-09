
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
  you_orbit = parent["YOU"]
  san_orbit = parent["SAN"]
  you_count = GetOrbitCount(you_orbit);
  san_count = GetOrbitCount(san_orbit);

  orbit_transfer_count = 0
  while(you_count > san_count) {
    orbit_transfer_count++
    you_orbit = parent[you_orbit]
    you_count--
  }

  while(san_count > you_count) {
    orbit_transfer_count++
    san_orbit = parent[san_orbit]
    you_count++
  }

  while(you_orbit != san_orbit) {
    orbit_transfer_count += 2
    san_orbit = parent[san_orbit]
    you_orbit = parent[you_orbit]
  }

  print orbit_transfer_count
}
'
