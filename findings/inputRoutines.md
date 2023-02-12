# Input Routines

Applying the `killInputSubroutine_ff2` patch causes input to no longer be read during gameplay in single player mode. Very likely `ff2` is the location of the input routine.

This subroutine is jumped to three times

```
00003bcc : 4eb9 0000 0ff2 JSR $00000ff2
00003cea : 4eb9 0000 0ff2 JSR $00000ff2
00003d5a : 4eb9 0000 0ff2 JSR $00000ff2
```

## killing the JSRs

Killed each JSR individually using `killInputJSR`:

3bcc: seemed to have no affect.
3cea: killed player input for a single player game
3d5a: seemed to have no affect.
