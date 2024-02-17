# Memory Addresses the patches use

## The Version string, displayed at start up for x seconds

- 108dd2:2 -- the fix write location
- 108dd4:4 -- a pointer to the string
- 108dd8:2 -- the display duration countdown

## The Player 1 input toggle string, either "rotary" or "joystk"

- 108dda:2 -- the fix write location
- 108ddc:4 -- a pointer to the string
- 108de0:2 -- the display duration countdown

## The Player 2 input toggle string, either "rotary" or "joystk"

- 108eda:2 -- the fix write location
- 108edc:4 -- a pointer to the string
- 108ee0:2 -- the display duration countdown

## Toggling input related

108e00:2 -- p1 toggle counter, if hold p1 start for x frames, input will toggle
108e02:1 -- p1's toggle. 0 = rotary, 1 = joystick
108f00:2 -- p2 toggle counter, if hold p2 start for x frames, input will toggle
108f02:1 -- p2's toggle. 0 = rotary, 1 = joystick

## Fake inputs

We need to fake the input a little bit to get the dino crank animation to work correctly.
When figuring out the rotary angle delta, we also write this fake input to these places in memory.

### Possible values

- 4: pretend right on the joystick was pushed
- 8: pretend left on the joystick was pushed
- 0: the joystick is neutral

108c28:b -- p1's fake input
108cc4:b -- p2's fake input

## high score input related

108fa0:1 -- the throttle value for when in joystick mode

## difficulty select related

108fc0:8 -- storage for D1
108fc8:8 -- storage for D2
108fd0:8 -- storage for D3
108fca:1 -- the real input that we mangle, so need to restore
