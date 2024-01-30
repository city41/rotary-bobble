# Memory Denies

When the main game is running, it writes a bunch of stuff around 0x108170 to 0x108320

The memoryWriteDenier.lua script denies writing to one of these addresses. The idea is run the game,
deny the write, see what happened. Hoping to find a memory address that leads to the rotation animation

## Findings

NDC = "no discernable change", ie nothing seems to happen

    0x108170 - NDC
    0x108172 - NDC
    0x108192 - NDC
    0x108194 - causes the background tiles to jump up 16px (the first write that is denied is 16)
    0x108196 - NDC
    0x1081fa - causes the shooter guidance dots to not alternate
    0x10820e - NDC
    0x108210 - NDC
    0x108212 - not allowing input. once deny starts, the shooter locks into whatever position it is in,
               the rotation animation does its first frame
    0x108214 - NDC
    0x10821c - causes bubbles to shoot as rapidly as possible, basically this is the auto shoot countdown timer
    0x108232 - NDC
    0x108234 - NDC
    0x108236 - NDC
    0x108244 - NDC
    0x108246 - NDC
    0x108248 - NDC
    0x10824a - NDC
    0x10824c - NDC
    0x10824e - NDC
    0x108254 - NDC
    0x108256 - When shooter travels left, the rotation animation plays very fast
    0x108258 - when shooter travels, only the very first frame of rotate animation plays and stays on screen during travel
    0x10825a - right hand dino plays all of his animations (even idle) extremely fast
    0x10825e - the crank does not crank, just stays at its first frame. dino rotate animation plays normally
    0x108260 - NDC
    0x108262 - shooter stays at zero (this is known, the shooter angle)
    0x108266 - NDC
    0x108268 - shooter locks in place, only first (maybe two?) frames of dino rotate animation happens
    0x10826a - NDC
    0x10826c - NDC
    0x10826e - NDC
    0x108284 - forces the shooter to go all the way left and ignores any input, isn't this delta angle?
    0x1082ae - NDC
    0x1082b0 - NDC
    0x108320 - NDC

## 108212 During normal play

1: when traveling right
-1 (ffff): when traveling left

This seems to control the gears animation (behind the dino/crank). If it is set to 1, the gears rotate
in one direction, and -1, the other. They rotate as long as this is set

### 108256 During normal play

0 - right dino is currently not animating
1 - right dino is currently rotating (either direction)
3 - right dino is performing an idle flavor animation

So I suspect this value is in a sense "how long a frame should be on screen"

### 10825a During normal play

It changes as right dino animates, but so far can't makle heads or tails out of it

### 10825e During normal play

I suspect this is the crank's current frame. It goes from 0 up to about 6, and changes as cranking happens

### 108268 During normal play

hmmmm, it stays at zero indefinitely. Once any lrud input has happened, it goes to 1 and stays there. it seems to be a "yup, input has happened" flag?

Its behavior during memory deny is odd though. More digging needed.
