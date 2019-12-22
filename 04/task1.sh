
awk -F '-' '

function HasAdjacentDigitsThatAreEqual() {
  return digit[0] == digit[1] \
      || digit[1] == digit[2] \
      || digit[2] == digit[3] \
      || digit[3] == digit[4] \
      || digit[4] == digit[5]
}

function AreDigitsAlwaysIncreasing() {
  return digit[0] <= digit[1] \
      && digit[1] <= digit[2] \
      && digit[2] <= digit[3] \
      && digit[3] <= digit[4] \
      && digit[4] <= digit[5]
}

function IsValidPassword(password) {
  digit[5] = int(password % 10)
  password /= 10
  digit[4] = int(password % 10)
  password /= 10
  digit[3] = int(password % 10)
  password /= 10
  digit[2] = int(password % 10)
  password /= 10
  digit[1] = int(password % 10)
  password /= 10
  digit[0] = int(password % 10)

#  print digit[0]
#  print digit[1]
#  print digit[2]
#  print digit[3]
#  print digit[4]
#  print digit[5]

  return HasAdjacentDigitsThatAreEqual() && AreDigitsAlwaysIncreasing()
}

BEGIN {
  next_route_id = 0
  center_x = 0
  center_y = 0
}

{
  first = $1
  second = $2
  valid_password_count = 0
  for(password=first; password<=second; password++) {
    if(password % 10000 == 0)
      print password
    if(IsValidPassword(password)) {
      valid_password_count++
    }
  }
  print "Found " valid_password_count " valid passwords"
}
'