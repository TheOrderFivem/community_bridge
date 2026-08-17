
Overall Community Bridge has been a blessing to fivem and a lot of creators, but i know people are becoming more and more wary to actually utilizing this because the scope has 
since lost its way. over complicated library modules have led to bloatware where we dont need bloat. since ox_lib is required to run the bridge, why try to re-invent the wheel
of a great library already and include it in a "bridge"

Since I personally believe that we should have a much more narrow scope I decided to do some leg work and reduce the lib modules to things that are **needed** and **not already handled by ox_lib**

# Completely Removed | Lib

1) lib/anim module
  - this already exists inside of ox_lib. there is no use for it. 
  - its only called in entities/client/client_entity so if that module stays it will be replaced with ox's call
2) callback
  - while I do enjoy these callbacks, theres no specific reason to keep these involved as ox already exists in this repo by requiring it 
  - all modules that used callbacks are easily switched to ox callbacks 
3) markers
  - while a neat module, ox does this
4) points as well as you can really just use ox zones. may not be a 1 for 1, but ox zones can accomplish the same things
5) raycast is already handled with ox lib
6) scaleform already handled with ox_lib
7) shells is pointless, if anything the script should be doing the spawning and handling and not a bridge. as many different shells from different creators exits
8) sql is a wrapper of a wrapper for mysql, every framework starts with oxmysql, while an ORM would be nice, this isnt ORM level yet
9) vehicles is not needed as ox handles this
10) cutscenes
   - like why? its used in so little of resources, no sense of keep loading this everywhere

# Completely Removed | modules
1) zones
  - lets face it, polyzone is fucking trash and hasnt been given a semi decent update in 5 years. ox_lib is required for this bridge so we should enforce higher code quality
    and there isnt a need for a wrapper when its a single resource being used, i can see this coming back in the future if someone makes a better or comparable zone

