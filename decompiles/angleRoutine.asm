; this massive routine is called before setAngle.asm
; it references the delta angle address (($82,A4)),
; and -$3c is -60, and $3c is 60

; truncating this routing causes the game to ignore LRUD inputs


; start of routine
; A4 is 108202
; ($82,A4) = 108284, delta angle
; ($60,A4) = 108262, shooter angle

; look at bit 2 of 108285
02EA8E: 082C 0002 0083      btst    #$2, ($83,A4)

; if bit 2 is unset, jump to 2eaa0
02EA94: 670A                beq     $2eaa0


; set the value at 108268 to zero
02EA96: 42AC 0066           clr.l   ($66,A4)

; load 1 into D0
02EA9A: 303C 0001           move.w  #$1, D0

; jump to 2eaca
02EA9E: 602A                bra     $2eaca


; test bit 2 of delta angle (108284)
02EAA0: 082C 0002 0082      btst    #$2, ($82,A4)

; if it is not zero, go to 2eae6
02EAA6: 663E                bne     $2eae6

; add $10000 to 108268
02EAA8: 06AC 0001 0000 0066 addi.l  #$10000, ($66,A4)

; see if 108268 is $10000 (ie, did we just add $10000 to zero?)
02EAB0: 0CAC 0001 0000 0066 cmpi.l  #$10000, ($66,A4)

; branch if lower than or same (<=) to 2eac2
02EAB8: 6308                bls     $2eac2

; set 108268 to $10000
02EABA: 297C 0001 0000 0066 move.l  #$10000, ($66,A4)

; load 208268 into D0
02EAC2: 302C 0066           move.w  ($66,A4), D0

; D0 = 1 & D0
02EAC6: 0240 0001           andi.w  #$1, D0

; compare 
02EACA: 0C6C FFC4 0060      cmpi.w  #-$3c, ($60,A4)
02EAD0: 6700 000A           beq     $2eadc
02EAD4: 916C 0010           sub.w   D0, ($10,A4)
02EAD8: 6000 0168           bra     $2ec42
02EADC: 082C 0000 0082      btst    #$0, ($82,A4)
02EAE2: 6700 0102           beq     $2ebe6
02EAE6: 082C 0003 0083      btst    #$3, ($83,A4)
02EAEC: 670A                beq     $2eaf8
02EAEE: 42AC 0066           clr.l   ($66,A4)
02EAF2: 303C 0001           move.w  #$1, D0
02EAF6: 602A                bra     $2eb22
02EAF8: 082C 0003 0082      btst    #$3, ($82,A4)
02EAFE: 663E                bne     $2eb3e
02EB00: 06AC 0001 0000 0066 addi.l  #$10000, ($66,A4)
02EB08: 0CAC 0001 0000 0066 cmpi.l  #$10000, ($66,A4)
02EB10: 6308                bls     $2eb1a
02EB12: 297C 0001 0000 0066 move.l  #$10000, ($66,A4)
02EB1A: 302C 0066           move.w  ($66,A4), D0
02EB1E: 0240 0001           andi.w  #$1, D0
02EB22: 0C6C 003C 0060      cmpi.w  #$3c, ($60,A4)
02EB28: 6700 000A           beq     $2eb34
02EB2C: D16C 0010           add.w   D0, ($10,A4)
02EB30: 6000 0110           bra     $2ec42
02EB34: 082C 0000 0082      btst    #$0, ($82,A4)
02EB3A: 6700 00AA           beq     $2ebe6
02EB3E: 082C 0000 0083      btst    #$0, ($83,A4)
02EB44: 670A                beq     $2eb50
02EB46: 42AC 0066           clr.l   ($66,A4)
02EB4A: 303C 0001           move.w  #$1, D0
02EB4E: 602A                bra     $2eb7a
02EB50: 082C 0000 0082      btst    #$0, ($82,A4)
02EB56: 6634                bne     $2eb8c
02EB58: 06AC 0001 0000 0066 addi.l  #$10000, ($66,A4)
02EB60: 0CAC 0001 0000 0066 cmpi.l  #$10000, ($66,A4)
02EB68: 6308                bls     $2eb72
02EB6A: 297C 0001 0000 0066 move.l  #$10000, ($66,A4)
02EB72: 302C 0066           move.w  ($66,A4), D0
02EB76: 0240 0001           andi.w  #$1, D0
02EB7A: 4A6C 0060           tst.w   ($60,A4)
02EB7E: 670C                beq     $2eb8c
02EB80: 6B02                bmi     $2eb84
02EB82: 4440                neg.w   D0
02EB84: D16C 0010           add.w   D0, ($10,A4)
02EB88: 6000 00B8           bra     $2ec42
02EB8C: 082C 0001 0083      btst    #$1, ($83,A4)
02EB92: 670A                beq     $2eb9e
02EB94: 42AC 0066           clr.l   ($66,A4)
02EB98: 303C 0001           move.w  #$1, D0
02EB9C: 602A                bra     $2ebc8
02EB9E: 082C 0001 0082      btst    #$1, ($82,A4)
02EBA4: 6640                bne     $2ebe6
02EBA6: 06AC 0001 0000 0066 addi.l  #$10000, ($66,A4)
02EBAE: 0CAC 0001 0000 0066 cmpi.l  #$10000, ($66,A4)
02EBB6: 6308                bls     $2ebc0
02EBB8: 297C 0001 0000 0066 move.l  #$10000, ($66,A4)
02EBC0: 302C 0066           move.w  ($66,A4), D0
02EBC4: 0240 0001           andi.w  #$1, D0
02EBC8: 323C 003C           move.w  #$3c, D1
02EBCC: 4A6C 0060           tst.w   ($60,A4)
02EBD0: 6714                beq     $2ebe6
02EBD2: 6A04                bpl     $2ebd8
02EBD4: 4440                neg.w   D0
02EBD6: 4441                neg.w   D1
02EBD8: B26C 0060           cmp.w   ($60,A4), D1
02EBDC: 6708                beq     $2ebe6
02EBDE: D16C 0010           add.w   D0, ($10,A4)
02EBE2: 6000 005E           bra     $2ec42
02EBE6: 0C6C 0001 0054      cmpi.w  #$1, ($54,A4)
02EBEC: 6600 00A4           bne     $2ec92
02EBF0: 397C 0000 0054      move.w  #$0, ($54,A4)
02EBF6: 426C 0056           clr.w   ($56,A4)
02EBFA: 6100 0904           bsr     $2f500
02EBFE: 4A2D 800C           tst.b   (-$7ff4,A5)
02EC02: 673C                beq     $2ec40
02EC04: 4A6D 0200           tst.w   ($200,A5)
02EC08: 6700 0008           beq     $2ec12
02EC0C: 4A6C 0000           tst.w   ($0,A4)
02EC10: 660E                bne     $2ec20
02EC12: 3F3C 0081           move.w  #$81, -(A7)
02EC16: 4EB9 0000 1D60      jsr     $1d60.l
02EC1C: 548F                addq.l  #2, A7
02EC1E: 6020                bra     $2ec40
02EC20: 3F3C 148D           move.w  #$148d, -(A7)
02EC24: 4EB9 0000 1D60      jsr     $1d60.l
02EC2A: 548F                addq.l  #2, A7
02EC2C: 0C6D 0006 A1D2      cmpi.w  #$6, (-$5e2e,A5)
02EC32: 6C0C                bge     $2ec40
02EC34: 3F3C 00EA           move.w  #$ea, -(A7)
02EC38: 4EB9 0000 1D60      jsr     $1d60.l
02EC3E: 548F                addq.l  #2, A7
02EC40: 6050                bra     $2ec92
02EC42: 0C6C 0001 0054      cmpi.w  #$1, ($54,A4)
02EC48: 6748                beq     $2ec92
02EC4A: 397C 0001 0054      move.w  #$1, ($54,A4)
02EC50: 396C 005C 0056      move.w  ($5c,A4), ($56,A4)
02EC56: 396C 005E 0058      move.w  ($5e,A4), ($58,A4)
02EC5C: 4A2D 800C           tst.b   (-$7ff4,A5)
02EC60: 6730                beq     $2ec92
02EC62: 4A6D 0200           tst.w   ($200,A5)
02EC66: 6700 0010           beq     $2ec78
02EC6A: 0C6D 0006 A1D2      cmpi.w  #$6, (-$5e2e,A5)
02EC70: 6C20                bge     $2ec92
02EC72: 4A6C 0000           tst.w   ($0,A4)
02EC76: 660E                bne     $2ec86
02EC78: 3F3C 0080           move.w  #$80, -(A7)
02EC7C: 4EB9 0000 1D60      jsr     $1d60.l
02EC82: 548F                addq.l  #2, A7
02EC84: 600C                bra     $2ec92
02EC86: 3F3C 00E9           move.w  #$e9, -(A7)
02EC8A: 4EB9 0000 1D60      jsr     $1d60.l
02EC90: 548F                addq.l  #2, A7
02EC92: 4E75                rts
