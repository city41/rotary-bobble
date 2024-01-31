# Rotary Bobble

README Last updated: Jan 31, 2024

A ROM hack, and matching controller, to add rotary controls to the Neo Geo game Puzzle Bobble

https://github.com/city41/rotary-bobble/assets/141159/24a6326e-b90c-4391-a242-a1e90e2c0111

## Status

### ROM Hack

I have hacked in a routine that reads the rotary input, translates it into the shooter's angle, and sets that angle. The hack also does things like ensure the dinos and gears animate correctly, stuff like that. As I learn more about the game I'm realizing my hack could be a lot better, but this is a WIP.

#### The lastest ROM patch

As of this writing, the latest and greatest is

```
ts-node src/patchProm/patchProm.ts src/patches/replaceAngleSettingRoutine_regp1cnt_all7bits_wgears_animation.json src/patches/setRotationSubroutine.json
```

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
  - Change the name of the game from "Puzzle Bobble" to "Rotary Bobble" by changing graphics in the C ROM
  - Force the region to Europe or also change "Bust A Move" to ummmm "Spin a Move"?
  - Change the how to play to show rotary controls (big undertaking...)
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
