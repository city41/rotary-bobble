This subroutine is what sets the angle at 0x108262.

; A4 is 108202

; move the value at *(A4 + 0x10) to register D0
; D0 = *(108212);
02F602: 302C 0010      move.w  $108212, D0                      ;; --- resolved, original: 02F602: 302C 0010      move.w  ($10,A4), D0

; return if zero was set, ie whatever got loaded into D0 is zero
; if (D0 == 0) return;
02F606: 6736           beq     $2f63e

; *(108266) -= 1;
02F608: 536C 0064      subq.w  #1, $108266                      ;; --- resolved, original: 02F608: 536C 0064      subq.w  #1, ($64,A4)

; branch if *(108266) is greater than zero (I think)
; if (*(108266)) return; // I think
02F60C: 6E30           bgt     $2f63e


; add D0 to $(108262)
02F60E: D16C 0060      add.w   D0, $108262                      ;; --- resolved, original: 02F60E: D16C 0060      add.w   D0, ($60,A4)

; compare *(108262) to -60
02F612: 0C6C FFC4 0060 cmpi.w  #-$3c, $108262                   ;; --- resolved, original: 02F612: 0C6C FFC4 0060 cmpi.w  #-$3c, ($60,A4)

; go to 0x2f620 (skip next line) if *(108262) is >= -60
02F618: 6C06           bge     $2f620

; *(108262) = -60
02F61A: 397C FFC4 0060 move.w  #$ffc4, $108262                  ;; --- resolved, original: 02F61A: 397C FFC4 0060 move.w  #$ffc4, ($60,A4)

; compare *(108262) with 60
02F620: 0C6C 003C 0060 cmpi.w  #$3c, $108262                    ;; --- resolved, original: 02F620: 0C6C 003C 0060 cmpi.w  #$3c, ($60,A4)

; go to 0x2f62e (skip next line) if *(108262) is <= 60
02F626: 6F06           ble     $2f62e

; *(108262) = 60-
02F628: 397C 003C 0060 move.w  #$3c, $108262                    ;; --- resolved, original: 02F628: 397C 003C 0060 move.w  #$3c, ($60,A4)

; D0 = *(108262)
02F62E: 302C 0060      move.w  $108262, D0                      ;; --- resolved, original: 02F62E: 302C 0060      move.w  ($60,A4), D0

; D0 = D0 << 1
02F632: E348           lsl.w   #1, D0

; A0 = 0x2f6c0
02F634: 41FA 008A      lea     ($8a,PC) ; ($2f6c0), A0

; *(108266) = *(A0 + D0)
02F638: 3970 0000 0064 move.w  (A0,D0.w), $108266               ;; --- resolved, original: 02F638: 3970 0000 0064 move.w  (A0,D0.w), ($64,A4)

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

void setShooterAngleFromInput(s16* shooterAngle) {
    u8 input = *((u8*)REG_P1CNT);

    // we want to save seven bits, ignoring a which as bit 4
    u8 lrud = input & 0xf;
    u8 bc = (input & 0x7f) >> 5;
    s8 finalPositiveValue = (s8)((bc << 4) | lrud);

    s8 finalValue = finalPositiveValue;
    if (input & 0x80) {
        finalValue = finalValue * -1;
    }

    if (finalValue > 60) {
        finalValue = 60;
    }

    if (finalValue < -60) {
        finalValue = 60;
    }
    
    *shooterAngle = finalValue;
}