# How To Play

The goal here:

- Swap out the joystick sprites for equivalent rotary dial sprites. The dial will just jump back and forth between two positions, but maybe it can show some rotation using auto animations?

- Replace the joystick specific text with rotary text

- BONUS: switch between the original HTP and the rotary version based on the input toggle.

## The Joystick Sprites

The sprites are 3 tiles high, indexes:

189, 190, 191

and

307, 308, 309

Each frame they alternate, as PB does a primtive kind of "double buffering" with two sprite sets

### The tiles

joystick pushed to the left

| 189  | 190  | 191  |
| ---- | ---- | ---- |
| 8665 | 8666 | 8000 |
| 8667 | 8668 | 8000 |
| 8669 | 866A | 8000 |

joystick in center

| 189  | 190  | 191  |
| ---- | ---- | ---- |
| 865e | 865f | 8660 |
| 8661 | 8662 | 8663 |
| 8000 | 8664 | 8000 |

joystick pushed to the right

| 189  | 190  | 191  |
| ---- | ---- | ---- |
| 8000 | 866b | 866c |
| 8000 | 866d | 866e |
| 8000 | 866f | 8670 |

`8000` is a blank tile

### Runtime writes

Tile index 8665 is being written to REG_VRAMRW at 33a6, and the value is being read from rom at adc4. The rom there exactly matches the joystick tiles

00ADC4: 8665 0000 8666 0000 8000 0000 8667 0000 .e...f.......g..
00ADD4: 8668 0000 8000 0000 8669 0000 866A 0000 .h.......i...j..
00ADE4: 8000

Since it's just rom, changing these should be fairy easy

here is the center frame

00AD9C: 865E 0000 865F 0000 8660 0000 8661 0000 .^...\_...`...a..
00ADAC: 8662 0000 8663 0000 8000 0000 8664 0000 .b...c.......d..
00ADBC: 8000

and to the right

00ADEC: 8000 0000 866B 0000 866C 0000 8000 0000 .....k...l......
00ADFC: 866D 0000 866E 0000 8000 0000 866F 0000 .m...n.......o..
00AE0C: 8670

## The instructions

I thought the instructions were on the fix layer, but they are sprites. Should easily be able to make it say something else by just changing the tiles in the CROM

They start at 4E9 (84e9 global) in the c4/c5 crom. These tiles look to be specified around A540 in ROM

00A540: 84E9 0000 84EA 0000 84EB 0000 84EC 0000 ................
00A550: 84ED 0000 84EE 0000 0002 0007 84EF 0000 ................
00A560: 84F0 0000 84F1 0000 84F2 0000 84F3 0000 ................
00A570: 84F4 0000 84F5 0000 84F6 0000 84F7 0000 ................
00A580: 84F8 0000 84F9 0000 84FA 0000 84FB 0000 ................
00A590: 84FC 0000 84FD 0000 84F6 0000 84FE 0000 ................
00A5A0: 84FF 0000 8500 0000 8501 0000 8502 0000 ................
00A5B0: 8503 0000 8504 0000 84F6 0000 0001 0007 ................
00A5C0: 8505 0000 8506 0000 8507 0000 8508 0000 ................
00A5D0: 8509 0000 850A 0000 850B 0000 84F6 0000 ................
00A5E0: 850C 0000 850D 0000 850E 0000 850F 0000 ................
00A5F0: 8510 ..

### From old to new

-- first row, starting at a564
84f1 -> 9c1b
84f2 -> 9c1c
84f3 -> 9c1d
84f4 -> 9c1e
84f5 -> 9c1f
84f6 -> 9c20

-- second row, starting at a584
84f9 -> 9c21
