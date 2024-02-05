020CCE: 536C 001C      subq.w  #1, ($1c,A4)
020CD2: 6B00 0188      bmi     $20e5c
020CD6: 7C00           moveq   #$0, D6
020CD8: 43FA F986      lea     (-$67a,PC) ; ($20660), A1
020CDC: 4A6D 01C2      tst.w   ($1c2,A5)
020CE0: 6704           beq     $20ce6
020CE2: 43FA FA18      lea     (-$5e8,PC) ; ($206fc), A1
020CE6: 1E2C 0011      move.b  ($11,A4), D7
020CEA: 664E           bne     $20d3a
020CEC: 1A2C 000E      move.b  ($e,A4), D5
020CF0: 536C 0012      subq.w  #1, ($12,A4)
020CF4: BA2C 0010      cmp.b   ($10,A4), D5
020CF8: 6706           beq     $20d00
020CFA: 397C 0008 0012 move.w  #$8, ($12,A4)
020D00: 4A6C 0012      tst.w   ($12,A4)
020D04: 6A66           bpl     $20d6c
020D06: 397C 0002 0012 move.w  #$2, ($12,A4)
020D0C: 0805 0002      btst    #$2, D5
020D10: 670E           beq     $20d20
020D12: 7CFF           moveq   #-$1, D6
020D14: 536C 001A      subq.w  #1, ($1a,A4)
020D18: 6A06           bpl     $20d20
020D1A: 397C 0027 001A move.w  #$27, ($1a,A4)
020D20: 0805 0003      btst    #$3, D5
020D24: 6712           beq     $20d38
020D26: 7CFF           moveq   #-$1, D6
020D28: 526C 001A      addq.w  #1, ($1a,A4)
020D2C: 0C6C 0027 001A cmpi.w  #$27, ($1a,A4)
020D32: 6F04           ble     $20d38
020D34: 426C 001A      clr.w   ($1a,A4)
020D38: 6032           bra     $20d6c
020D3A: 397C 0008 0012 move.w  #$8, ($12,A4)
020D40: 0807 0002      btst    #$2, D7
020D44: 670E           beq     $20d54
020D46: 7CFF           moveq   #-$1, D6
020D48: 536C 001A      subq.w  #1, ($1a,A4)
020D4C: 6A06           bpl     $20d54
020D4E: 397C 0027 001A move.w  #$27, ($1a,A4)
020D54: 0807 0003      btst    #$3, D7
020D58: 6712           beq     $20d6c
020D5A: 7CFF           moveq   #-$1, D6
020D5C: 526C 001A      addq.w  #1, ($1a,A4)
020D60: 0C6C 0027 001A cmpi.w  #$27, ($1a,A4)
020D66: 6F04           ble     $20d6c
020D68: 426C 001A      clr.w   ($1a,A4)
020D6C: 4A46           tst.w   D6
020D6E: 6632           bne     $20da2
020D70: 0807 0004      btst    #$4, D7
020D74: 672A           beq     $20da0
020D76: 48E7 FFF8      movem.l D0-D7/A0-A4, -(A7)
020D7A: 4A6D 01C2      tst.w   ($1c2,A5)
020D7E: 660E           bne     $20d8e
020D80: 3F3C 00C0      move.w  #$c0, -(A7)
020D84: 4EB9 0000 1D60 jsr     $1d60.l
020D8A: 548F           addq.l  #2, A7
020D8C: 600C           bra     $20d9a
020D8E: 3F3C 00E0      move.w  #$e0, -(A7)
020D92: 4EB9 0000 1D60 jsr     $1d60.l
020D98: 548F           addq.l  #2, A7
020D9A: 4CDF 1FFF      movem.l (A7)+, D0-D7/A0-A4
020D9E: 6002           bra     $20da2
020DA0: 7C01           moveq   #$1, D6
020DA2: 322C 0018      move.w  ($18,A4), D1
020DA6: D241           add.w   D1, D1
020DA8: D241           add.w   D1, D1
020DAA: 2474 101E      movea.l ($1e,A4,D1.w), A2
020DAE: 426A 0004      clr.w   ($4,A2)
020DB2: 342C 001A      move.w  ($1a,A4), D2
020DB6: 41FA 00A8      lea     ($a8,PC) ; ($20e60), A0
020DBA: 7000           moveq   #$0, D0
020DBC: 1030 2000      move.b  (A0,D2.w), D0
020DC0: 3540 0006      move.w  D0, ($6,A2)
020DC4: 4EBA F5AC      jsr     (-$a54,PC) ; ($20372)
020DC8: 6B0C           bmi     $20dd6
020DCA: D040           add.w   D0, D0
020DCC: D040           add.w   D0, D0
020DCE: 2571 0000 0000 move.l  (A1,D0.w), ($0,A2)
020DD4: 6006           bra     $20ddc
020DD6: 357C FFFF 0004 move.w  #$ffff, ($4,A2)
020DDC: 72F8           moveq   #-$8, D1
020DDE: C36A 0008      and.w   D1, ($8,A2)
020DE2: C36A 000A      and.w   D1, ($a,A2)
020DE6: 302C 001C      move.w  ($1c,A4), D0
020DEA: E248           lsr.w   #1, D0
020DEC: 0240 0001      andi.w  #$1, D0
020DF0: D16A 0008      add.w   D0, ($8,A2)
020DF4: D16A 000A      add.w   D0, ($a,A2)
020DF8: EB48           lsl.w   #5, D0
020DFA: 1540 000E      move.b  D0, ($e,A2)
020DFE: 1540 000F      move.b  D0, ($f,A2)
020E02: 4A46           tst.w   D6
020E04: 6652           bne     $20e58
020E06: 72F8           moveq   #-$8, D1
020E08: C36A 0008      and.w   D1, ($8,A2)
020E0C: C36A 000A      and.w   D1, ($a,A2)
020E10: 426A 000E      clr.w   ($e,A2)
020E14: 0C6C 0027 001A cmpi.w  #$27, ($1a,A4)
020E1A: 670E           beq     $20e2a
020E1C: 526C 0018      addq.w  #1, ($18,A4)
020E20: 0C6C 0003 0018 cmpi.w  #$3, ($18,A4)
020E26: 6C34           bge     $20e5c
020E28: 602E           bra     $20e58
020E2A: 357C FFFF 0004 move.w  #$ffff, ($4,A2)
020E30: 157C 0020 0007 move.b  #$20, ($7,A2)
020E36: 536C 0018      subq.w  #1, ($18,A4)
020E3A: 6A04           bpl     $20e40
020E3C: 426C 0018      clr.w   ($18,A4)
020E40: 302C 0018      move.w  ($18,A4), D0
020E44: D040           add.w   D0, D0
020E46: D040           add.w   D0, D0
020E48: 2474 001E      movea.l ($1e,A4,D0.w), A2
020E4C: 357C FFFF 0004 move.w  #$ffff, ($4,A2)
020E52: 157C 0020 0007 move.b  #$20, ($7,A2)
020E58: 7000           moveq   #$0, D0
020E5A: 4E75           rts
