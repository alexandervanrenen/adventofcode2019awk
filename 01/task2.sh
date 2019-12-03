
awk '
// {
  fuel_required = int($1 / 3) - 2
  while(fuel_required > 0) {
    sum += fuel_required
    fuel_required = int(fuel_required / 3) - 2
  }
}
END {
  print sum
}
'