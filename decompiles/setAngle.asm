This subroutine is what sets the angle at 0x108262.


; move the value at *(A4 + 0x10) to register D0
; D0 = *(A4 + 0x10);
02F602: 302C 0010      move.w  ($10,A4), D0

; return if zero was set, ie whatever got loaded into D0 is zero
; if (D0 == 0) return;
02F606: 6736           beq     $2f63e

; *(A4 + 0x64) -= 1;
02F608: 536C 0064      subq.w  #1, ($64,A4)

; branch if *(A4+0x64) is greater than zero (I think)
; if (*(A4+0x64)) return; // I think
02F60C: 6E30           bgt     $2f63e


; add D0 to $(A4 + 0x60)
02F60E: D16C 0060      add.w   D0, ($60,A4)

; compare *(A4 + 0x60) to -0x3c (-60)
02F612: 0C6C FFC4 0060 cmpi.w  #-$3c, ($60,A4)

; go to 0x2f620 (skip next line) if *(A4 + 0x60) is >= -0x3c (-60)
02F618: 6C06           bge     $2f620

; *(A4 + 0x60) = 0xffc4 (65476)
02F61A: 397C FFC4 0060 move.w  #$ffc4, ($60,A4)

; compare *(A4 + 0x60) with 0x3c (60)
02F620: 0C6C 003C 0060 cmpi.w  #$3c, ($60,A4)

; go to 0x2f62e (skip next line) if *(A4 + 0x60) is <= 0x3c (60)
02F626: 6F06           ble     $2f62e

; *(A4 + 0x60) = 0x3c (60)
02F628: 397C 003C 0060 move.w  #$3c, ($60,A4)

; D0 = *(A4 + 0x60)
02F62E: 302C 0060      move.w  ($60,A4), D0

; D0 = D0 << 1
02F632: E348           lsl.w   #1, D0

; A0 = 0x2f6c0
02F634: 41FA 008A      lea     ($8a,PC) ; ($2f6c0), A0

; *(A4 + 0x64) = *(A0 + D0)
02F638: 3970 0000 0064 move.w  (A0,D0.w), ($64,A4)

; return from subroutine
02F63E: 4E75           rts


// angleDelta = 0x10
// coolDown = 0x64
// shooterAngle = 0x60
void setShooterAngle(s16 angleDelta, s16 *coolDown, s16 *shooterAngle) {
    if (angleDelta == 0) {
        return;
    }

    // coolDown is a timer so that the shooter
    // doesn't just shoot to an extreme immediately
    // from reading input at 60fps
    *coolDown -= 1;

    // not ready to change the angle yet, still waiting
    if (*coolDown >= 0) {
        return;
    }

    // change the angle
    *shooterAngle += angleDelta;

    // clamp the angle
    if (*shooterAngle < -60) {
        *shooterAngle = -60;
    }

    if (*shooterAngle > 60) {
        *shooterAngle = 60;
    }

    // not sure what is happening from here on out, but I'm guessing
    // they are resetting the cool down
    angleDelta = shooterAngle;
    angleDelta = angleDelta << 1;
    *coolDown = *(0x2f6c0 + angleDelta);
}