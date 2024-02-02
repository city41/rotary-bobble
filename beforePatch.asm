02EC94: 102C 0083 move.b  ($83,A4), D0
02EC98: 0240 0010 andi.w  #$10, D0
02EC9C: E848      lsr.w   #4, D0
02EC9E: 3940 0012 move.w  D0, ($12,A4)
02ECA2: 4E75      rts
02ECA4: 302C 0018 move.w  ($18,A4), D0
02ECA8: E548      lsl.w   #2, D0
02ECAA: 207B 0006 movea.l ($6,PC,D0.w), A0
02ECAE: 4E90      jsr     (A0)
02ECB0: 4E75      rts
02ECB2: 0002 ECD2 ori.b   #$d2, D2
02ECB6: 0002 ECB0 ori.b   #$b0, D2
02ECBA: 0002 ED46 ori.b   #$46, D2
02ECBE: 0002 EE16 ori.b   #$16, D2
02ECC2: 0002 EE84 ori.b   #$84, D2
