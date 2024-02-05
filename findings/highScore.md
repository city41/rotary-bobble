# High Score

Score (single player) is stored at two words

- 10820a: the score's high word
- 10820c: the score's low word

This is because the data bus on the 68k is only 16 bits wide, so each word has to be written separately.

It's easy to blow past the first word in roughly the second level.

## High Score Entry

The default minimum needed to get this screen is >7000 points. This is somewhat easily done with `src/lua/scoreInjector.lua` and force yourself to die on the first level.

### Current Pending Letter

Looks to be set at 105a89. The max value is 0x27, 40 characters

- A-Z: 26 characters
- 0-9: 10 characters
- period, ampersand, space, left arrow: 4 characters

The subroutine that is writing this value starts at 20cce.

### Watchpoint output

vblank ack
105a89 read at 20DB6
vblank ack
105a89 read at 20DB6
vblank ack
105a89 read at 20DB6
vblank ack
105a89 read at 20D60
105a89 set with: 2 at 20D60
105a89 read at 20DB6

### Handling input

It looks for left being pressed at 20d40, `btst #$2, D7` and right being pressed at 20d56, `btest #$3, D7`.

020D3A: 397C 0008 0012 move.w #$8, ($12,A4)

;; check to see if left is pushed
020D40: 0807 0002 btst #$2, D7
;; it's not? jump to test right
020D44: 670E beq $20d54

;; set D6 to -1
020D46: 7CFF moveq #-$1, D6

// it is pushed, move the pending letter down one
020D48: 536C 001A subq.w #1, ($1a,A4)

;; it's still positive? no need to handle wrapping
020D4C: 6A06 bpl $20d54

;; it just wrapped, so set it to 0sx27, the max value
020D4E: 397C 0027 001A move.w #$27, ($1a,A4)

;; check for right input
020D54: 0807 0003 btst #$3, D7

;; no? jump pass input testing
020D58: 6712 beq $20d6c

;; set D6 to -1
020D5A: 7CFF moveq #-$1, D6

;; it is pushed, move the pending letter up one
020D5C: 526C 001A addq.w #1, ($1a,A4)

;; see if it went beyond the max
020D60: 0C6C 0027 001A cmpi.w #$27, ($1a,A4)

;; didn't go beyond max? skip
020D66: 6F04 ble $20d6c

;; went beyond max, set it to zero so it wraps
020D68: 426C 001A clr.w ($1a,A4)

;; is D6 zero? That means no pending input happened
;; in other words, only allow A on a different frame from changing the letter
020D6C: 4A46 tst.w D6

;; hasnt hit zero, skip ahead
020D6E: 6632 bne $20da2

;; Check for A being pressed
020D70: 0807 0004 btst #$4, D7

;; not pressed? jump ahead
020D74: 672A beq $20da0

;; not really sure what is happening here
;; save off the registers into memory
020D76: 48E7 FFF8 movem.l D0-D7/A0-A4, -(A7)
;; is (A5+1c2) zero?
020D7A: 4A6D 01C2 tst.w ($1c2,A5)
020D7E: 660E bne $20d8e

020D80: 3F3C 00C0 move.w #$c0, -(A7)
020D84: 4EB9 0000 1D60 jsr $1d60.l

### Patch approach

set a JSR just before the game checks for left/right at 20d40

in that subroutine, set pending letter based on the rotary angle
if set, decrement D6 by one, or always do this? not sure yet
jump back to 20d6c

First in the subroutine, just set the pending letter to say 'G'
