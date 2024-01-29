; this subroutine is setting 240 sprites's scaling
; to full size (0xfff for scb2)

; when this is called, VRAMADDR (A1) is 8001
; A0 starts at 104dd2, and it's just 0x0fff the whole time

; I don't think any sprites in puzzle bobble ever scale? maybe they do?
; this feels like "at the beginning of setting vram, we're going to make sure
; sprites are sane"
;
; but why sprites 1-240?


002C9E: 3298      move.w  (A0)+, (A1)
002CA0: 3298      move.w  (A0)+, (A1)
002CA2: 3298      move.w  (A0)+, (A1)
002CA4: 3298      move.w  (A0)+, (A1)
002CA6: 3298      move.w  (A0)+, (A1)
002CA8: 3298      move.w  (A0)+, (A1)
002CAA: 3298      move.w  (A0)+, (A1)
002CAC: 3298      move.w  (A0)+, (A1)
002CAE: 3298      move.w  (A0)+, (A1)
002CB0: 3298      move.w  (A0)+, (A1)
002CB2: 3298      move.w  (A0)+, (A1)
002CB4: 3298      move.w  (A0)+, (A1)
002CB6: 3298      move.w  (A0)+, (A1)
002CB8: 3298      move.w  (A0)+, (A1)
002CBA: 3298      move.w  (A0)+, (A1)
002CBC: 3298      move.w  (A0)+, (A1)
002CBE: 3298      move.w  (A0)+, (A1)
002CC0: 3298      move.w  (A0)+, (A1)
002CC2: 3298      move.w  (A0)+, (A1)
002CC4: 3298      move.w  (A0)+, (A1)
002CC6: 51CF FFD6 dbra    D7, $2c9e
002CCA: 5048      addq.w  #8, A0
002CCC: 4E75      rts
