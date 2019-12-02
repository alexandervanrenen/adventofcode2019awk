My implementation of the [adventofcode](https://adventofcode.com/2019), arguable the best advent calender on the internet :)

The goal is to use these little exercises to practice my *awk* skills.
I will keep a log of some thoughts on each exercise, about what I did and (mainly) learned.

Day 01
------
I started one day late .. I might catch up on this one later. 

Day 02
------
Fun scenario!
I think you can not implement these intcode programs with a single pass:
A statement can access memory anywhere and in order to read from an address you need to parse the intcode program up until this address.
The awk implementation was fun and semi-easy.
A bit anoying was the fact that the addressing in the intcode program is 0-based, while the fields ($1, $2, ..) in awk are 1-based ($0 is the entire line).
So probably it would have been better to 'parse' the entire program into an array first and work on that:
```awk
    $($(pc + 3) + 1) =  $($(pc + 1) + 1) + $($(pc + 2) + 1)
``` 
And instead have:
```awk
    mem[mem[pc + 3]] =  mem[mem[pc + 1]] + mem[mem[pc + 2]]
```
Yeah, a bit easier and avoids confusion while testing.

The second task can very easily be solved using bruteforce (only 100^2 options, with awk that runs in ~2s).
However, thats a bit boring and I was thinking of using an analytical solution.
First, I checked that (1) no instruction codes are checked and (2) no pointers are modified before being used.
Both conditions hold, meaning it is a monoton (?) problem (i.e., no op codes or addresses are changed).
Thus, I can write a program that tracks all performed operations and then, given an address, prints out a forumla to calculate the value for this address.
```awk
function resolve_write_history(address, ts) {
  for(; ts>=0; ts--) {
    if(destination[ts] == address) {
      return "(" resolve_write_history(operands_lhs[ts], ts) operator[ts] resolve_write_history(operands_rhs[ts], ts) ")"
    }
  }
  if(address == 1) {
    return "(@1)"
  }
  if(address == 2) {
    return "(@2)"
  }
  return original[address]
}

i = last_write_to_address_we_are_interested_in
print resolve_write_history(operands_lhs[i], i) operator[i] resolve_write_history(operands_rhs[i], i)
```

This gives me the handy formula:
```bash
3+((1+(3*(1+((3+(3+(5*(2*(4+((5*(1+((5*(1+(2*((4*((((2+(5+(2+(x*4))))+4)+2)+5))+2))))*3)))+1))))))*3))))+y)
```
Using an online equation solver ([wolframalpha](https://www.wolframalpha.com/input/?i=3%2B%28%281%2B%283*%281%2B%28%283%2B%283%2B%285*%282*%284%2B%28%285*%281%2B%28%285*%281%2B%282*%28%284*%28%28%28%282%2B%285%2B%282%2B%28x*4%29%29%29%29%2B4%29%2B2%29%2B5%29%29%2B2%29%29%29%29*3%29%29%29%2B1%29%29%29%29%29%29*3%29%29%29%29%2By%29+%3D+19690720+and+x%3E0+and+x%3C100+and+y%3E0+and+y%3C100)) you get the correct results.

Also interestingly, awk does not support local variables.
Unless they are function parameters.
This is important when writing recursive functions like this.
Initially I used a (unintensionally) local iterator variable i, which was then shared over all recursive calls.
