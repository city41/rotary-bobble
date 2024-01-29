# Dino Rotation

This is the dino on the right side that rotates the handle as the shooter angle changles.

The sprite indexes are

- 365: the rotation handle
- 366: left side of dino
- 367: right side of dino

as the rotation animation happens, these sprites constantly change their tiles.

## Rotation handle tiles

- 8a8e: default, shooter at 0
- 8a90: rotated right as minimally as possible
- 8a95: rotated left as minimally as possible

## Left side of dino

### while idle

- 8a26
- 8a5d

### while rotating

- 8000
- 8a45

- 8000
- 8a48

- 8000
- 8a4b

- 8000
- 8a4e

- 8a50
- 8a51

- 8a53
- 8a54

- 8a56
- 8a57

- 8a59
- 8a5a

# Setting the tiles

The subroutine at 3398 runs a loop that sets tiles
