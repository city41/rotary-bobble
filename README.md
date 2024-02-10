# Rotary Bobble

README Last updated: Feb 7, 2024

A ROM hack, and matching controller, to add rotary controls to the Neo Geo game Puzzle Bobble

https://github.com/city41/rotary-bobble/assets/141159/24a6326e-b90c-4391-a242-a1e90e2c0111

## Status

### ROM Hack

The ROM hack is complete. It...

- gives rotary controls to all gameplay
- rotary input on high score name entry screen
- how to play screen has a spinner instead of a joystick
- each player can hold start for about 1.5 seconds to toggle between joystick and rotary controls. Useful if say playing a two player game and only have one rotary controller.

The complete patch is at `src/patches/rotary-bobble.json`

### Controller

I have built a rough, but working, prototype

![controller prototype](https://github.com/city41/rotary-bobble/blob/main/prototypeBoard.png?raw=true)

It uses transistors to control RLDU, B, C and D. It has normal push buttons for A, Select, Start.

In theory the Pico could be powered by the +5v the Neo Geo provides to its controllers, but I've had issues with this. So for now powering the Pico via standard USB.

![controller schematic](https://github.com/city41/rotary-bobble/blob/main/controllerSchematic.svg?raw=true)

#### Controller Issues

I've really struggled to get all the noise out of the potentiometer. This shows up as the shooter in the game slightly vibrating as it moves between two values, and the dino kinda "twitches" as it's told to rotate the crank just for one or two frames. I've removed most of it, but have failed to get it all out so far.

I have so other things I'm going to try, and I'm still confident I can get smooth controls.

Long term I also won't use python, but rather a native binary so people can just drag it on and be good to go.

## Still To Do

Oh lots...

- Controller

  - [x] build a working prototype
  - [ ] circuit can likely be improved, just winged it...
  - [ ] resolve the potentiometer noise issue, possibly with an LM4040?
  - [ ] A switch to disable rotary input
  - [ ] Figure out a good power solution for the Pico
  - [ ] Instructions on how to create a controller

- ROM Hack
  - [x] single player rotary controls during main gameplay
  - [x] High score entry using rotary controls
  - [x] Allow player two to use rotary controls during a single player game (ie start a game with p2 instead of p1)
  - [x] Rotary controls for both players during a two player match (versus)
  - [x] Add a tagline to the title screen to indicate this is the rotary version
  - [x] Allow toggling rotary by holding select for a couple seconds
  - [x] Change the how to play to show rotary controls (big undertaking...)
  - maybe a website that easily allows applying the hack?

## How to hack on this

### clownassembler

The 68k assember, clownassembler, was copied into `clownassembler/` from https://github.com/Clownacy/clownassembler,
it needs to be built with `cd clownassembler && make`. This is needed for creating patches.

## To patch

only tested on x64 Ubuntu 22. You will need a recent version of Node, I am using 18.18.2

- `yarn install`
- copy an untouched `pbobblen.zip`, that is intended for MAME, into the root directory of the repo
  - all zips are in gitignore, so the rom won't end up in the repo
- change the path in `src/patchRom/main.ts` to your MAME rom directory, defaults to `/home/matt/mame/roms/pbobblen.zip`
- run `ts-node src/patchRom/main.ts src/patches/prom/gameplayRotaryControls.json`

Once patched, it will run in MAME if you start it on the command line. You can also run `yarn to-neosd` to create a .neo file. This requires [neosdconv](https://github.com/city41/neosdconv). I would prefer to use TerraOnion's NeoBuilder, but I've not gotten it to work properly. You will need to edit `scripts/toneosd.sh` and change my hardcoded paths.

TODO: make these scripts not assume my machine
