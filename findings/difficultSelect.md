# Difficult Select

In AES mode, there is a difficult select screen with easy, normal, hard and mvs. 1014aa holds the current selection:

- 0: easy
- 1: normal
- 2: hard
- 3: mvs

This is a word, but it seems like the game is writing a word despite the low value possibilities

Pushing up or down to change difficult is happening here

```
00686E: 0800 0000 btst    #$0, D0
006872: 660A      bne     $687e
006874: 0800 0001 btst    #$1, D0
006878: 660A      bne     $6884
00687A: 6000 000A bra     $6886
00687E: 5345      subq.w  #1, D5
006880: 6000 0004 bra     $6886
006884: 5245      addq.w  #1, D5
006886: 0245 0003 andi.w  #$3, D5
```

and as long as D5 is 0-3, the game will do the right thing

So a jsr, followed by 9 nops should do it
