# Rotary Bobble

README Last updated: Jan 28, 2024

A ROM hack to add rotary controls to the Neo Geo game Puzzle Bobble

![video demo screenshot](https://github.com/city41/rotary-bobble/blob/main/videoScreenshot.png?raw=true)

[Video demonstration](https://www.youtube.com/shorts/RZggReSwxVM)

## Status

### ROM Hack

`src/patches/replaceAngleSettingRoutine_regp2cnt_all7bits.json` successfully patches in a routine where it reads player two's input, and sets the angle of the player one shooter to (-60,60), depending on the values of CB and RLDU. CBRLDU's bits form a six bit value maxing out at 63, which is then clamped to 60 if needed. If D is pressed, the value is made negative.

This is reading on player two and impacting player one. This is because getting the ROM working on say a NeoSD with the rotary controls taking over player one is difficult. This also means that to shoot the bubble, you need to press A on player one's controller. This is obviously not ideal, but this is where it's at right now. Much more work is needed (see below).

#### The lastest ROM patch

As of this writing, the latest and greatest is

```
ts-node src/patchProm/patchProm.ts src/patches/replaceAngleSettingRoutine_regp1cnt_all7bits_wgears_animation.json src/patches/setRotationSubroutine.json
```

### Controller

I have built a very rough controller prototype out of a breadboard and a Pico W.

![controller prototype](https://github.com/city41/rotary-bobble/blob/main/controllerPrototype.jpg?raw=true)

It uses transistors to control RLDU, B, C and D. It has normal push buttons for A, Select, Start.

In theory the Pico could be powered by the +5v the Neo Geo provides to its controllers, but I've had issues with this. So for now powering the Pico via standard USB.

## Still To Do

Oh lots...

- Controller

  - Add a toggle button to the controller to allow toggling between rotary and joystick controls
  - once toggle is in place, change ROM hack to only work with player one inputs
  - Build the controller into a case and switch from a breadboard to a solder prototype board
  - Figure out a good power solution for the Pico
  - Get real PCBs made
  - Instructions on how to create a controller

- ROM Hack
  - Set the rotation animation (the dinosaur turning the crank) whenever the shooter rotates
  - Change the name of the game from "Puzzle Bobble" to "Rotary Bobble" by changing graphics in the C ROM
  - Force the region to Japan or also change "Bust A Move" to ummmm "Spin a Move"?
  - Change the how to play to show rotary controls (big undertaking...)
  - Allow player two to use rotary controls

## How to hack on this

### clownassembler

The 68k assember, clownassembler, was copied into `clownassembler/` from https://github.com/Clownacy/clownassembler,
it needs to be built with `cd clownassembler && make`. This is needed for creating patches.

## To patch

only tested on x64 Ubuntu 22. You will need a recent version of Node, I am using 18.18.2

- `yarn install`
- copy an untouched `pbobblen.zip`, that is intended for MAME, into the root directory of the repo
  - all zips are in gitignore, so the rom won't end up in the repo
- change the path in `src/patchProm/patchProm.ts` to your MAME rom directory, defaults to `/home/matt/mame/roms/pbobblen.zip`
- run `ts-node src/patchProm/patchProm.ts src/patches/replaceAngleSettingRoutine_regp1cnt_all7bits.json`

Once patched, it will run in MAME if you start it on the command line. You can also run `yarn to-neosd` to create a .neo file. This requires [neosdconv](https://github.com/city41/neosdconv). I would prefer to use TerraOnion's NeoBuilder, but I've not gotten it to work properly. You will need to edit `scripts/toneosd.sh` and change my hardcoded paths.

TODO: make these scripts not assume my machine
