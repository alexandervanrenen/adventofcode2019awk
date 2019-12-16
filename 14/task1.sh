awk -F " => " '
{
  split($2, arr, " ")

  produced_elements[arr[2]] = $1
  produced_quantities[arr[2]] = arr[1]
}

function GetNeedOtherThanOre() {
  for(key in needs) {
    if(key != "ORE") {
      return key
    }
  }
  return ""
}

function DumpCurrentNeeds() {
  for(key in needs) {
    print key ": " needs[key]
  }
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

END {
  GetMe(1, "FUEL")
  print "Needed ore: " needed_ore
}
'