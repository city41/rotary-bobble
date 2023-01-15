# Rotary bobble

Add rotary controls to Puzzle Bobble

PB's gun can be put into 26 positions. Hack the game to read a five bit value that is [0, 26], and then set that in memory to force the gun to be at that angle.

## Find the memory value that stores gun angle

Load up PB in an emulator, play around and look at RAM to find which value stores the angle

## Hack the game loop

* while in game, read LRUD,D for the five rotary bits, and Sel,Start,A for everything else
* stick the rotary value into memory as the angle, doing any needed conversions.

## Arduino rotary

Build an arduino board that uses a potentiometer. Have it continuously read the pot's value, and send down 5 pulse outpits to be the matching 5 bit value.

Convert the Neo arcade stick to have a rotary control instead of a joystick

