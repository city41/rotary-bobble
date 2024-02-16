# Rotary Bobble

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

I have built a rough, but working, prototype using an Arduino Nano.

![controller prototype](https://github.com/city41/rotary-bobble/blob/main/arduinoPrototype.jpg?raw=true)

It uses transistors to control RLDU, B, C and D. It has normal push buttons for A, Select, Start.

I also had a prototype using a Raspberry Pi Pico, but always had a little bit of noise in the Pico's analog readings, causing a bit of jitter during gameplay. The Nano has no jitter and provides perfect controls.

For more info, check the `src/pico` and `src/arduino` folders.

## IPS Patches

IPS patches are available in the `ipsPatches` directory. To patch a ROM

1. unzip pbobblen.zip
2. patch `d96-02.c5` with `pbobblen.d96-02.c5.ips` using an IPS patcher
3. patch `d96-03.c6` with `pbobblen.d96-03.c6.ips` using an IPS patcher
4. patch `d96-07.ep1` with `pbobblen.d96-07.ep1.ips` using an IPS patcher
5. Make sure the three patched files keep the original name of the file they patched (overwrite it)
6. zip the files back up into pbobblen.zip

NOTE: MAME will notice the ROM is different and not launch it from the UI. You must launch it from the command line if using MAME

## Still To Do

- Controller

  - [x] build a working prototype
  - [x] circuit can likely be improved, just winged it...
  - [x] resolve the potentiometer noise issue, possibly with an LM4040?
  - [ ] Simple input mode to handle things like NeoSD's menu
  - [x] Figure out a good power solution for the Arduino
  - [ ] Instructions on how to create a controller

- ROM Hack
  - [x] single player rotary controls during main gameplay
  - [x] High score entry using rotary controls
  - [x] Allow player two to use rotary controls during a single player game (ie start a game with p2 instead of p1)
  - [x] Rotary controls for both players during a two player match (versus)
  - [x] Add a tagline to the title screen to indicate this is the rotary version
  - [x] Allow toggling rotary by holding start for a couple seconds
  - [x] Change the how to play to show rotary controls (big undertaking...)
  - maybe a website that easily allows applying the hack?

## How to hack on this

### clownassembler

The 68k assember, clownassembler, was copied into `clownassembler/` from https://github.com/Clownacy/clownassembler,
it needs to be built with `cd clownassembler && make`. This is needed for creating patches.

## To patch

only tested on x64 Ubuntu 22. You will need a recent version of Node, I am using 18.18.2

Set the env variable `MAME_ROM_DIR` to where you store your roms for MAME.

- `yarn install`
- copy an untouched `pbobblen.zip`, that is intended for MAME, into the root directory of the repo
  - all zips are in gitignore, so the rom won't end up in the repo
- run `ts-node src/patchRom/main.ts src/patches/rotary-bobble.json`

`rotary-bobble.json` is the main patch, and applies all changes. The patches in `patches/individual` can be applied instead to just do parts. They should be self explanatory from the file name and the description at the top of each patch.

Once patched, it will run in MAME if you start it on the command line. You can also run `yarn to-neosd` to create a .neo file. This requires [neosdconv](https://github.com/city41/neosdconv). I would prefer to use TerraOnion's NeoBuilder, but I've not gotten it to work properly.
