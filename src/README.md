# Src directories

## lua

These are MAME Lua scripts. For more info, check out [ngDebugScripts repo](https://github.com/city41/ngDebugScripts)

## patches

These are the actual patches that change Puzzle Bobble's PROM. They are JSON files and should be pretty self explanatory.

## patchRom

A TypeScript app that can take in the patch json files and do the actual patching of the p and c roms

`ts-node src/patchRom/main.ts <patch-1.json> <patch2-json> ...`

## pico

A python program that is ran on a Pico W with the controller prototype. This program translates the current value of the potentiometer and feeds that into the ROM hack via the Neo's controller port
