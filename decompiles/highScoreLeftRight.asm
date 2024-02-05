;; registers
;; PC 020CCE
;; A0 00105AAC
;; A1 00020660
;; A2 00000012
;; A3 00107042
;; A4 00105A6E
;; A5 00108000
;; A6 00000016
;; A7 001014CE

;; start of subroutine

;; subtract 1 from 105ac8
020CCE: 536C 001C      subq.w  #1, $105ac8                      ;; --- resolved, original: 020CCE: 536C 001C      subq.w  #1, ($1c,A4)

;; did it just go negative? jump
020CD2: 6B00 0188      bmi     $20e5c

;; still positive? D6 = 0
020CD6: 7C00           moveq   #$0, D6

;; load 20660 into A1
020CD8: 43FA F986      lea     (-$67a,PC) ; ($20660), A1

;; test 105c6e
020CDC: 4A6D 01C2      tst.w   $105c6e                          ;; --- resolved, original: 020CDC: 4A6D 01C2      tst.w   ($1c2,A5)

;; is it zero? jump
020CE0: 6704           beq     $20ce6

;; load 206fc into A1
020CE2: 43FA FA18      lea     (-$5e8,PC) ; ($206fc), A1

;; D7 = *(105abd), this is used to check for input below
020CE6: 1E2C 0011      move.b  $105abd, D7                      ;; --- resolved, original: 020CE6: 1E2C 0011      move.b  ($11,A4), D7

;; is D7 not zero? jump
020CEA: 664E           bne     $20d3a

;; D5 = *(105aba)
020CEC: 1A2C 000E      move.b  $105aba, D5                      ;; --- resolved, original: 020CEC: 1A2C 000E      move.b  ($e,A4), D5

;; *(105abe) -= 1
020CF0: 536C 0012      subq.w  #1, $105abe                      ;; --- resolved, original: 020CF0: 536C 0012      subq.w  #1, ($12,A4)

;; does *(105abc) == D5? in other words, does *(105aba) == *(105abc)
020CF4: BA2C 0010      cmp.b   $105abc, D5                      ;; --- resolved, original: 020CF4: BA2C 0010      cmp.b   ($10,A4), D5

;; if so, jump
020CF8: 6706           beq     $20d00


;; *(105abe) = 8
020CFA: 397C 0008 0012 move.w  #$8, $105abe                     ;; --- resolved, original: 020CFA: 397C 0008 0012 move.w  #$8, ($12,A4)

;; get a read on *(105abe)
020D00: 4A6C 0012      tst.w   $105abe                          ;; --- resolved, original: 020D00: 4A6C 0012      tst.w   ($12,A4)
;; if it is positive, jump
020D04: 6A66           bpl     $20d6c
;; else *(105abe) = 2
020D06: 397C 0002 0012 move.w  #$2, $105abe                     ;; --- resolved, original: 020D06: 397C 0002 0012 move.w  #$2, ($12,A4)

;; is bit 3 of D5 set?
020D0C: 0805 0002      btst    #$2, D5
;; if not, jump
020D10: 670E           beq     $20d20
;; D6 = -1
020D12: 7CFF           moveq   #-$1, D6
;; Move pending letter down one
020D14: 536C 001A      subq.w  #1, $105ac6                      ;; --- resolved, original: 020D14: 536C 001A      subq.w  #1, ($1a,A4)
;; is it positive? jump
020D18: 6A06           bpl     $20d20

;; otherwise wrap it to 0x27, the max value
020D1A: 397C 0027 001A move.w  #$27, $105ac6                    ;; --- resolved, original: 020D1A: 397C 0027 001A move.w  #$27, ($1a,A4)

;; is bit 4 of D5 set?
020D20: 0805 0003      btst    #$3, D5
;; if not, jump
020D24: 6712           beq     $20d38
;; D6 = -1
020D26: 7CFF           moveq   #-$1, D6

;; move the pending letter up one
020D28: 526C 001A      addq.w  #1, $105ac6                      ;; --- resolved, original: 020D28: 526C 001A      addq.w  #1, ($1a,A4)
;; did it go above 0x27?
020D2C: 0C6C 0027 001A cmpi.w  #$27, $105ac6                    ;; --- resolved, original: 020D2C: 0C6C 0027 001A cmpi.w  #$27, ($1a,A4)
020D32: 6F04           ble     $20d38
;; if so, wrap it to zero
020D34: 426C 001A      clr.w   $105ac6                          ;; --- resolved, original: 020D34: 426C 001A      clr.w   ($1a,A4)
;; jump ahead
020D38: 6032           bra     $20d6c
;;; *(105abe) = 8
020D3A: 397C 0008 0012 move.w  #$8, $105abe                     ;; --- resolved, original: 020D3A: 397C 0008 0012 move.w  #$8, ($12,A4)

;; check to see if left is pushed
020D40: 0807 0002      btst    #$2, D7

;; it's not? jump to test right
020D44: 670E           beq     $20d54

;; D6 = -1
020D46: 7CFF           moveq   #-$1, D6

;; it is pushed, move the pending letter down one
020D48: 536C 001A      subq.w  #1, $105ac6                      ;; --- resolved, original: 020D48: 536C 001A      subq.w  #1, ($1a,A4)

;; it's still positive? no need to handle wrapping
020D4C: 6A06           bpl     $20d54

;; it just wrapped, so set to 0x27, the max value
020D4E: 397C 0027 001A move.w  #$27, $105ac6                    ;; --- resolved, original: 020D4E: 397C 0027 001A move.w  #$27, ($1a,A4)

;; check for right input
020D54: 0807 0003      btst    #$3, D7

;; no? jump pass input testing
020D58: 6712           beq     $20d6c

;; D6 = -1
020D5A: 7CFF           moveq   #-$1, D6

;; move the pending letter up one
020D5C: 526C 001A      addq.w  #1, $105ac6                      ;; --- resolved, original: 020D5C: 526C 001A      addq.w  #1, ($1a,A4)

;; see if it went beyond the max
020D60: 0C6C 0027 001A cmpi.w  #$27, $105ac6                    ;; --- resolved, original: 020D60: 0C6C 0027 001A cmpi.w  #$27, ($1a,A4)
 
;; didn't go beyond max? skip
020D66: 6F04           ble     $20d6c

;; it did go beyond max, set it to zero to wrap around
020D68: 426C 001A      clr.w   $105ac6                          ;; --- resolved, original: 020D68: 426C 001A      clr.w   ($1a,A4)

;; is D6 zero? if it is, it's because the pending letter did not change
020D6C: 4A46           tst.w   D6

;; it is not zero? a pending letter change, don't allow A input this frame
020D6E: 6632           bne     $20da2

;; check for A pressed
020D70: 0807 0004      btst    #$4, D7

;; not pressed? jump ahead
020D74: 672A           beq     $20da0

;; save registers to memory
020D76: 48E7 FFF8      movem.l D0-D7/A0-A4, -(A7)
;; is 105c6e zero? maybe that's the countdown timer?
020D7A: 4A6D 01C2      tst.w   $105c6e                          ;; --- resolved, original: 020D7A: 4A6D 01C2      tst.w   ($1c2,A5)

;; not zero? skip ahead
020D7E: 660E           bne     $20d8e

;; decrement A7, then move 192d into whatever it is pointing to
020D80: 3F3C 00C0      move.w  #$c0, -(A7)

;; head to another subroutine
020D84: 4EB9 0000 1D60 jsr $1d60.l

;; ORIGINAL DISASSEMBLY
;; registers
;; PC 020CCE
;; A0 00105AAC
;; A1 00020660
;; A2 00000012
;; A3 00107042
;; A4 00105A6E
;; A5 00108000
;; A6 00000016
;; A7 001014CE

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