awk -F ",|=|<|>" '

function Signum(val) { return val == 0 ? 0 : (val < 0 ? -1 : +1); }
function Abs(val) { return val < 0 ? -val : val; }

BEGIN {
  planet_count = 0
}

{
  pos_x[planet_count] = $3
  pos_y[planet_count] = $5
  pos_z[planet_count] = $7

  init_pos_x[planet_count] = $3
  init_pos_y[planet_count] = $5
  init_pos_z[planet_count] = $7

  planet_count++
}

function DumpPos() {
  for(i=0; i<planet_count; i++) {
    print pos_x[i] " | " pos_y[i] " | " pos_z[i]
  }
}

function DumpVel() {
  for(i=0; i<planet_count; i++) {
    print vel_x[i] " | " vel_y[i] " | " vel_z[i]
  }
}

function CalculateVelocities() {
  for(i=0; i<planet_count; i++) {
    for(j=0; j<planet_count; j++) {
      vel_x[i] += Signum(pos_x[j] - pos_x[i])
      vel_y[i] += Signum(pos_y[j] - pos_y[i])
      vel_z[i] += Signum(pos_z[j] - pos_z[i])
    }
  }
}

function UpdatePositions() {
  for(i=0; i<planet_count; i++) {
    pos_x[i] += vel_x[i]
    pos_y[i] += vel_y[i]
    pos_z[i] += vel_z[i]
  }
}

function CheckForRepeat() {
  if(pos_x[0] == init_pos_x[0] && pos_x[1] == init_pos_x[1] && pos_x[2] == init_pos_x[2] && pos_x[3] == init_pos_x[3]) {
    if(length(first_repeat_x) == 0) {
      first_repeat_x = step + 2
      found_repeats++
    }
    print "x at " step + 2
  }

  if(pos_y[0] == init_pos_y[0] && pos_y[1] == init_pos_y[1] && pos_y[2] == init_pos_y[2] && pos_y[3] == init_pos_y[3]) {
    if(length(first_repeat_y) == 0) {
      first_repeat_y = step + 2
      found_repeats++
    }
    print "y at " step + 2
  }

  if(pos_z[0] == init_pos_z[0] && pos_z[1] == init_pos_z[1] && pos_z[2] == init_pos_z[2] && pos_z[3] == init_pos_z[3]) {
    if(length(first_repeat_z) == 0) {
      first_repeat_z = step + 2
      found_repeats++
    }
    print "z at " step + 2
  }
}

function GetPrimeFactors(val, _i)
{
  delete prime_factors
  for(_i=2; _i<=val; _i++) {
    while(val % _i == 0) {
      val /= _i
      prime_factors[_i]++
    }
  }
}

function AddPrimeFactorsToSuperPrimes(_a)
{
  for(_a in prime_factors) {
    if(super_primes[_a] < prime_factors[_a]) {
      super_primes[_a] = prime_factors[_a]
    }
  }
}

function LeastCommonMultiple(_a)
{
  delete super_primes

  GetPrimeFactors(first_repeat_x)
  AddPrimeFactorsToSuperPrimes()

  GetPrimeFactors(first_repeat_y)
  AddPrimeFactorsToSuperPrimes()

  GetPrimeFactors(first_repeat_z)
  AddPrimeFactorsToSuperPrimes()

  result = 1
  for(_a in super_primes) {
    print _a " " super_primes[_a]
    result = result * (_a ** super_primes[_a])
  }
  return result
}

END {
  for(step=0; found_repeats != 3; step++) {
    CalculateVelocities()
    UpdatePositions()
    CheckForRepeat()
  }
  print "Found repeats: " found_repeats

  LeastCommonMultiple()

  print "Steps: " result

  while(step < 2772) {
   CalculateVelocities()
    UpdatePositions()
    step++
  }
  print step
  DumpPos()
  DumpVel()
}
'
