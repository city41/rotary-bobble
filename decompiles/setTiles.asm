; This subroutine is jumped to when setting tiles in vram

; A1 is 3c0002, aka REG_VRAMRW
; (-$2,A1) = REG_VRAMADDR
; ($2,A1) = REG_VRAMMOD

; *REG_VRAMADDR = D1
003398: 3341 FFFE      move.w  D1, (-$2,A1)
; D3 = D5
00339C: 3605           move.w  D5, D3
; *REG_VRAMMOD = 1
00339E: 337C 0001 0002 move.w  #$1, ($2,A1)

; *REG_VRAMRW = *(A0++)
0033A4: 3298           move.w  (A0)+, (A1)
; D0 = *(A0++)
0033A6: 3018           move.w  (A0)+, D0
; *REG_VRAMMOD = 0x3f (63)
0033A8: 337C 003F 0002 move.w  #$3f, ($2,A1)
; D0 = D0 ^ D2
0033AE: B540           eor.w   D2, D0
; *REG_VRAMRW = D0
0033B0: 3280           move.w  D0, (A1)
; if (--D3 >= 0) goto 0x339e
0033B2: 51CB FFEA      dbra    D3, $339e
; D1 = 2
0033B6: 5441           addq.w  #2, D1
; if (--D4 >= 0) goto 3398
0033B8: 51CC FFDE      dbra    D4, $3398
; return
0033BC: 4E75           rts
