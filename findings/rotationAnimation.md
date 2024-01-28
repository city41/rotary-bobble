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
