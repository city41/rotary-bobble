# Rotary Bobble

README Last updated: Feb 2, 2024

A ROM hack, and matching controller, to add rotary controls to the Neo Geo game Puzzle Bobble

https://github.com/city41/rotary-bobble/assets/141159/24a6326e-b90c-4391-a242-a1e90e2c0111

## Status

### ROM Hack

The patch `src/patches/singlePlayerRotaryControls.json` cleanly adds in rotary controls for single player play. I have figured out quite well how the game reads its input and my changes work well with the game and alter it minimally. I am pretty sure there are no bugs or any ill effects, rotary controls now just work. The Taito dev even made the "dino turns the crank" animation's speed dependent on how fast the shooter has moved. In normal Puzzle Bobble, you can only really move the shooter at one speed. So seeing the dino just speed up naturally to meet the new demands was awesome! Nice job, Taito!

I am now working on high score entry.

### Controller

I have built a rough, but working, prototype

![controller prototype](https://github.com/city41/rotary-bobble/blob/main/prototypeBoard.png?raw=true)

It uses transistors to control RLDU, B, C and D. It has normal push buttons for A, Select, Start.

In theory the Pico could be powered by the +5v the Neo Geo provides to its controllers, but I've had issues with this. So for now powering the Pico via standard USB.

![controller schematic](https://github.com/city41/rotary-bobble/blob/main/controllerSchematic.svg?raw=true)

## Still To Do

Oh lots...

- Controller

  - circuit can likely be improved, just winged it...
  - Figure out a good power solution for the Pico
  - Instructions on how to create a controller

- ROM Hack
  - Add a tagline to the title screen to indicate this is the rotary version
  - Change the how to play to show rotary controls (big undertaking...)
  - High score entry using rotary controls
  - Allow player two to use rotary controls
  - bug fixes
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
- change the path in `src/patchProm/patchProm.ts` to your MAME rom directory, defaults to `/home/matt/mame/roms/pbobblen.zip`
- run `ts-node src/patchProm/patchProm.ts src/patches/replaceAngleSettingRoutine_regp1cnt_all7bits.json`

Once patched, it will run in MAME if you start it on the command line. You can also run `yarn to-neosd` to create a .neo file. This requires [neosdconv](https://github.com/city41/neosdconv). I would prefer to use TerraOnion's NeoBuilder, but I've not gotten it to work properly. You will need to edit `scripts/toneosd.sh` and change my hardcoded paths.

TODO: make these scripts not assume my machine
