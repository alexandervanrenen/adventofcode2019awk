awk -F " => " '
{
  split($2, arr, " ")

  produced_elements[arr[2]] = $1
  produced_quantities[arr[2]] = arr[1]
}

function ceil(x, _y) { _y = int(x); return x>_y ? _y+1 : _y }

function GetMe(needed_quantity, needed_element, str, qty, required_reaction_count, requirements, i, single_requirement) {
#  print "To get " needed_quantity " of " needed_element " we need ..."

  if(needed_element == "ORE") {
    needed_ore += needed_quantity
    return
  }

  if(needed_quantity <= have[needed_element]) {
    have[needed_element] -= needed_quantity
    return
  }

  str = produced_elements[needed_element]
  qty = produced_quantities[needed_element]
  required_reaction_count = ceil((needed_quantity - have[needed_element]) / qty)
  have[needed_element] = required_reaction_count * qty + have[needed_element] - needed_quantity

  split(str, requirements, ", ")
  for(i=1; i<=length(requirements); i++) {
    split(requirements[i], single_requirement, " ")
#    print "   " single_requirement[1] * required_reaction_count " of " single_requirement[2]
    GetMe(single_requirement[1] * required_reaction_count, single_requirement[2])
  }
}

function SaveState() {
  delete prev_have
  for(key in have) {
    prev_have[key] = have[key]
  }
  prev_needed_ore = needed_ore
  prev_fuel = fuel
}

function RestoreState() {
  delete have
  for(key in prev_have) {
    have[key] = prev_have[key]
  }
  needed_ore = prev_needed_ore
  fuel = prev_fuel
}

END {
  TRILLION = 1000000000000

  fuel_to_get = TRILLION / 10

  while(needed_ore <= TRILLION) {
    SaveState()

    GetMe(fuel_to_get, "FUEL")
    fuel += fuel_to_get

    # We got too much -> restore and try with less
    if(needed_ore >= TRILLION) {
      RestoreState()
      if(fuel_to_get <= 1) {
        break
      } else {
        fuel_to_get = int(fuel_to_get / 2)
        continue
      }
    }
  }

  for(key in have) {
    print key ": " have[key]
  }

  print "We get: " fuel " fuel"
}
'