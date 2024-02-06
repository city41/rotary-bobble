# P2 Single

This is playing a single player game from the p2 side.

## 2f602o

Both sides break at this subroutine

When playing P1 side, registers:
- D0 00020000
- D1 00000004
- D2 0000A400
- D3 0000000C
- D4 0000FFFF
- D5 00000048
- D6 00000040
- D7 0000FFFF
- A0 0002F5C0
- A1 003C0002
- A2 00000012
- A3 0010829E
- A4 00108202
- A5 00108000
- A6 00000016
- A7 00101096

When playing p2 side, registers:
- D0 00020000
- D1 00000004
- D2 0000A700
- D3 0000000C
- D4 0000FFFF
- D5 00000048
- D6 00000040
- D7 0000FFFF
- A0 0002F5C0
- A1 003C0002
- A2 00000012
- A3 0010829E
- A4 0010829E
- A5 00108000
- A6 00000016
- A7 00101096

# the basic input routine at ff2

It reads p1's input at 1016 and p2 at 1032