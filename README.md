# Rotary Bobble

a rom hack to add rotary controls to the Neo Geo game Puzzle Bobble

## clownassembler

The 68k assember, clownassembler, was copied into `clownassembler/` from https://github.com/Clownacy/clownassembler

## dis68k

The 68k disassembler, dis68k, was copied into `disasm/` from https://github.com/TomHarte/dis68k

## status

`patches/replaceAngleSettingRoutine_regp1cnt_all7bits.json` successfully patches in a routine where it reads player one's input,
and sets the angle of the shooter to (-60,60), depending on the values of LRUD and BCD. LRUDBC's bits form a six bit value maxing
out at 63, which is then clamped to 60 if needed. If D is pressed, the value is made negative

## To patch

only tested on x64 Ubuntu 22

- `yarn install`
- copy an untouched `pbobblen.zip` into the root directory of the repo
  - all zips are in gitignore, so the rom won't end up in the repo
- change the path in `patchProm.ts` to your mame rom directory, defaults to `/home/matt/mame/roms/pbobblen.zip`
- run `ts-node patchProm/patchProm.ts patches/replaceAngleSettingRoutine_regp1cnt_all7bits.json`
