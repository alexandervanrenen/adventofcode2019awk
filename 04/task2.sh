
awk -F '-' '

function HasAdjacentDigitsThatAreEqual() {
  run_length = 1
  last_digit = digit[0]
  for(i=1; i<=5; i++) {
    if(digit[i] == last_digit) {
      run_length++
    } else {
      if(run_length == 2) {
        return 1
      }
      run_length = 1
      last_digit = digit[i]
    }
  }
  return run_length == 2;
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
    if(IsValidPassword(password)) {
      valid_password_count++
    }
  }
  print "Found " valid_password_count " valid passwords"
}
'