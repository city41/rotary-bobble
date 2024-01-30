# Rotation Animation

One of the dinos rotates the crank if any of LRUD are pressed

- L or U: rotates the crank counter clockwise
- R or D: rotates the crank clockwise

stops rotating the crank once a max angle has been reached (-60 or 60)

Memory address 108284 is a byte storing the current "delta angle"

- F7 if going right
- FB if going left
- FF if not moving

If the delta value is not FF, then the corresponding rotation animation will get run

If we force this value to be F7, then the game will constanly move the shooter right. But
if we do this and apply the 7bit input patch, the end result is just the rotate right
animation plays. This is because the 7bit routine is not looking at delta at all and sets
the final shooter angle completely differently.

I think the game is doing roughly this:

```c
s8 deltaAngle = readInputToGetDeltaAngle();
...
loadRotationAnimation(deltaAngle);
...
setShooterAngle(deltaAngle);
```

The problem is in rotary controls, delta angle is totally irrelevant. We are just setting the angle directly. So
altering these methods is probably not going to work. So something like this...

```c
// read p1 input, form the angle from it, and diff it from last frame's angle
s8 deltaAngle = getDeltaAngleBasedOnDiffFromeLastFrame();

// read p1 input, from the angle from it, and set the angle
setShooterAngle(deltaAngle);

// unchanged
loadRotationAnimation(deltaAngle);
```

This is a bit wasteful, as we will form the angle from input twice. So this would be a bit better

```c
// read p1 input, form the angle from it, and diff it from last frame's angle
s8 curAngle = figureOutCurAngleFromInput();

// using curAngle and the angle from last frame, figure out what deltaAngle should be
s8 deltaAngle = determineDeltaAngleFromLastFrame(curAngle);

// just take in the angle and set it in memory
setShooterAngle(curAngle);

loadRotationAnimation(deltaAngle);
```

Use global memory to avoid returns and make this all simpler

move curAngle to prevAngle
determine curAngle from input and set it
set deltaAngle based on diff between prevAngle and curAngle

or

allow game to set delta angle
allow game to set animation based on delta angle
do 7bit routine
-- set current angle based on input
-- set current animation based on a calculated delta

# Follow up

None of the above worked. The game seems to actually be doing this

```c
s8 deltaAngle = origGame_readInputToGetDeltaAngle();
...
origGame_setShooterAngle(deltaAngle);
...
origGame_loadRotationAnimation(deltaAngle);
```

Basically the opposite of what I originally thought. Since the hack is replacing `setShooterAngle` with the new rotary routine, setting the rotation animation value there does nothing as the game just immediately clobbers it

BTW: the hack is now saving the previous angle, forming a delta from the angels, and setting the wheel/gears animation accordingly in setShooterAngle. That works fine.

I think what needs to happen is this

```c
s8 deltaAngle = origGame_readInputToGetDeltaAngle();
...
hack_setShooterAngle(deltaAngle);
...
origGame_loadRotationAnimation(deltaAngle);
...
hack_setRotationAnimationAgain();
```

Basically swoop back in again and reclobber the rotation animation. Obviously not the most elegant or efficient, but it should work fine. Possibly just replace `origGame_loadRotationAnimation` with `hack_setRotationAnimationAgain`

set two breakpoints
2f602 -> count how many hits
2e98c -> count how many hits

let run for a bit, break, set a normal 2e98c breakpoint, then compare counters. if 2f602 is one higher, then my suspicion is correct

bpset 2f602,1,{ temp0++; g }
bpset 2e98c,1,{ temp1++; printf "2f602=%d,2e98c=%d",temp0,temp1; g }

# Follow up #2

after setting watchpoints and breakpoints, I get this

wrote, PC=2e98c
read, PC=2eaa6
read, PC=2eafe
read, PC=2eb56
read, PC=2eba4
2f602

repeated many times (once per frame)

I think this is correct. I think each frame what is happening is the value gets written, the people who care about the value read it, then the hack routine comes along and sets it, but no one cares at that point.
