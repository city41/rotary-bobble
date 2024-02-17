# Num player select

In AES mode, after choosing difficulty you then choose 1p or 2p game.

This is set at 1014aa as either

- $0048: 1 player mode
- $0098: 2 player mode

input changes get written to

10225c - FD when down is pressed

num player select handling is here

```
0069FE: 102D A25C      move.b  (-$5da4,A5), D0
006A02: C02D A25D      and.b   (-$5da3,A5), D0
006A06: 0800 0000      btst    #$0, D0
006A0A: 6708           beq     $6a14
006A0C: 0800 0001      btst    #$1, D0
006A10: 6712           beq     $6a24
006A12: 601E           bra     $6a32
006A14: 3A3C 0048      move.w  #$48, D5
006A18: 3C3C 0040      move.w  #$40, D6
006A1C: 3B7C 0001 A26C move.w  #$1, (-$5d94,A5)
006A22: 600E           bra     $6a32
006A24: 3A3C 0098      move.w  #$98, D5
006A28: 3C3C 0090      move.w  #$90, D6
006A2C: 3B7C 0003 A26C move.w  #$3, (-$5d94,A5)


006A32: 0C47 024B      cmpi.w  #$24b, D7
006A36: 6E00 0054      bgt     $6a8c
006A3A: 0C6D 0003 A26C cmpi.w  #$3, (-$5d94,A5)
006A40: 6700 003A      beq     $6a7c
006A44: 41ED 8018      lea     (-$7fe8,A5), A0
006A48: 4A10           tst.b   (A0)
006A4A: 6700 0014      beq     $6a60
006A4E: 3B7C 0001 A26C move.w  #$1, (-$5d94,A5)
006A54: 102D A264      move.b  (-$5d9c,A5), D0
006A58: 0800 0004      btst    #$4, D0
006A5C: 6600 002C      bne     $6a8a
```
