
awk -F '-' '

function HasAdjacentDigitsThatAreEqual() {
  run_length = 1
  last_digit = digit_0

  if(digit_1 == last_digit) {
    run_length++
  } else {
    if(run_length == 2) {
      return 1
    }
    run_length = 1
    last_digit = digit_1
  }

  if(digit_2 == last_digit) {
    run_length++
  } else {
    if(run_length == 2) {
      return 1
    }
    run_length = 1
    last_digit = digit_2
  }

  if(digit_3 == last_digit) {
    run_length++
  } else {
    if(run_length == 2) {
      return 1
    }
    run_length = 1
    last_digit = digit_3
  }

  if(digit_4 == last_digit) {
    run_length++
  } else {
    if(run_length == 2) {
      return 1
    }
    run_length = 1
    last_digit = digit_4
  }

  if(digit_5 == last_digit) {
    run_length++
  } else {
    if(run_length == 2) {
      return 1
    }
    run_length = 1
    last_digit = digit_5
  }

  return run_length == 2;
}

function AreDigitsAlwaysIncreasing() {
  if( digit_0 <= digit_1 \
   && digit_1 <= digit_2 \
   && digit_2 <= digit_3 \
   && digit_3 <= digit_4 \
   && digit_4 <= digit_5) {
    return 1
  }

  if(digit_0 > digit_1) {
    digit_1 = digit_0
    digit_2 = digit_0
    digit_3 = digit_0
    digit_4 = digit_0
    digit_5 = digit_0
  }

  if(digit_1 > digit_2) {
    digit_2 = digit_1
    digit_3 = digit_1
    digit_4 = digit_1
    digit_5 = digit_1
  }

  if(digit_2 > digit_3) {
    digit_3 = digit_2
    digit_4 = digit_2
    digit_5 = digit_2
  }

  if(digit_3 > digit_4) {
    digit_4 = digit_3
    digit_5 = digit_3
  }

  if(digit_4 > digit_5) {
    digit_5 = digit_4
  }

  password = digit_0 * 100000 + digit_1 * 10000 + digit_2 * 1000 + digit_3 * 100 + digit_4 * 10 + digit_5 * 1
  password = password - 1
  return 0
}

function IsValidPassword(_password) {
  digit_5 = int(_password % 10)
  _password /= 10
  digit_4 = int(_password % 10)
  _password /= 10
  digit_3 = int(_password % 10)
  _password /= 10
  digit_2 = int(_password % 10)
  _password /= 10
  digit_1 = int(_password % 10)
  _password /= 10
  digit_0 = int(_password % 10)

  return AreDigitsAlwaysIncreasing() && HasAdjacentDigitsThatAreEqual()
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
  investigated_pw_count = 0
  for(password=first; password<=second; password++) {
    investigated_pw_count++
    if(IsValidPassword(password)) {
      valid_password_count++
    }
  }
  print "Found " valid_password_count " valid passwords"
  print "Investigates " investigated_pw_count " password"
}
'