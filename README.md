My implementation of the [adventofcode](https://adventofcode.com/2019), arguable the best advent calender on the internet :)

The goal is to use these little exercises to practice my *awk* skills.
I will keep a log of some thoughts on each exercise, about what I did and (mainly) learned.

Day 01
------
Did this one after 03 as I started late only on the second day.
This one was only a warmup, but I love the continous story :)
And awk suits itself very nicely to this task.
Could it be that you have to pick the right hammer for each nail !?

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

Day 03
------
Finished day 3, hurray!
I am growing a less fond of awk for doing these challanges.
What kind of annoys me is that variables are usually global and only local if they are function parameters.
```awk
function foo(_i) {
    for(_i=0; _i<10; _i++) { .. }
}
```
If dont makle `i` a parameter, you end up having your it as a global variable.
When you have a loop that calls a function that uses another loop, it leads to some very un-wanted behavior.
Having learned this lession the hard way, yesterday, today, I ended up using a lot of function parameters to get my variables to be local.
Cause this is what we object oriented programmers like: encapsulation, right.
However, this ended up being kind of messy and feels ocward.
I thing tomorrow, I only do this for the `i` or on-demand ?

Another thing, while talking about object oriented programming: I miss objects.
However, I learned that there are two kinds of variables: arrays and non-arrays.
Arrays are passed by reference and non-arrays are passed by value to functions.
And arrays are not arrays, but maps/dictionaries.
So I guess they could be used to do somehing like objects:
```awk
point["x"] = 5;
point["y"] = 8;
points[5, 8] = "value"; 
points[5, 8] = point; # ERROR, can't put arrays into arrays
```

All this considdered, I am obviously thinking of implementing my own scripting language ;p
No, there is a lot I like about awk, but maybe I will try continue with a something else.
I am thinking java script.

Day 04
------
Brute force for the win !
Rather easy one, I am just wondering what the most efficient way would be to solve this.
Currently (task2.sh), I am converting the input string into a number which I use to iterate over the input range.
Then I extract each digit of the number into an array and do the checks.
We will call this version the *vanilla* version and see what we can do!
First, I guess I should replace the awk array with regular variables, I don't trust awk to optimize them out and these lookup can't be for free.
```
vanilla: 4.43s
no-arrays: 0.78s
```
Yeah, though so, but I had to unroll the loop in HasAdjacentDigitsThatAreEqual, because without an array, I cant use an iterator.
(Unrolling does not significantly help, the vanilla implementation, maybe like 0.2, but idc).
Next I think, we should be smarter when incrementing the password.
Assuming we do an increment from 259999 to 260000, because of the AreDigitsAlwaysIncreasing rule all numbers till 266666 are out, but we still iterate them.
So lets first swap the order in which we check the rules: 
```
checking AreDigitsAlwaysIncreasing first: 0.56s
```
Next, lets fast forward to the next possible number (266666) whenever we detect a vialation of AreDigitsAlwaysIncreasing.
Ok, turns out being smart about the algorithm is very benefitial.
But lets see if the other tricks are still useful:
```
fast-forward: 0.01s
- checking AreDigitsAlwaysIncreasing first: 0.01s
- no-arrays: 0.02s
```
Ok, so arrays are kind of slowing it down, but the smarter algorithm really helps out.
I guess now there is not really a way to continue optimizing, unless I would use another way to measure time.
And I think I am to lazy to look one up.
The final version is in task2_2.sh.

I think one more optimization, that might be benificial would be to stop converting the password from a number to individual digits (and back).
Instead, I could work always on digits and just implement the increment by hand.
That would save a lot of mod and divs.
But its getting late, my time measurement is broken, and the elves are already happy :)

Day 05
------
New day, new luck.
Being more happy with awk again.
Should always remember that gawk != awk and that if(var) does not check if the variable is defined:
```awk
echo "" | awk '{asd = 0; if(asd) {print "defined"} else {print "NOT defined"}}' -> NOT defined

echo "" | awk '{asd = 0; if(length(asd) > 0) {print "defined"} else {print "NOT defined"}}' -> defined
echo "" | awk '{         if(length(asd) > 0) {print "defined"} else {print "NOT defined"}}' -> NOT defined
```

Day 06
------
Super cool, easy, fun, chill task :)))
But no time to write or optimize today.

Day 07
------
Got busy over the weekend.
Trying to catch up.
Having no proper encapsulation makes it a bit harder to extend existing programs, but actually less bad than expected.
Might be because of the small program size.
Had a nasty bug in the intcode program, copy pasted the code for equal from less than and forgot to change the sign.
20 minutes of intcode program reading to figure that out .. of course this case only gets triggered in the 4th amplifier :(

Day 08
------
Maybe in awk I should always thing 1-based, I thought its only the input, but even
```awk
  split("hi", xxx, "")
  print xxx[0] # -> ''
  print xxx[1] # -> 'h'
  print xxx[2] # -> '1'
 
  print substr("asd",1,1) # -> 'a'
```

Day 09
------
This time we apparently completed the incode program, by simply adding relative addressing and thus allowing for a program stack.
I was starting to hate these programs and the world while hand-debugging in Day 07.
But now that they are "completed", I fear this might have been the last intcode program task.
I am gonna miss the intcode program tasks.
I hope they are not completely gone.
I hope I wont regrett saying that.

Day 10
------
Puh, the collision test phase was a lot of fun.
I could trim down the number of tests by two, because I always check if a is visible from b and then later if b is visible from a.
I opted for the naiive way, because it only gives a factor of 2 and I used a neat algorithm for the collision test already.
Hence, no biggy and on the upside: I hade a simple ``NumberOfVisibleAsteroidsFromGivenPosition`` function.
I thought that I might be able to re-use this in the second task.
Sadly, not.
And even more sadly, it was about angles :(
Took me a while to get thing right, the fliped coord system did not make it easier, but I think I understood the atan2 function.
And I realized that I can still have everything in my task.sh files and still use pipes.
So for future tasks I have pipes at my disposal and therefore all the gloy of bash :)
