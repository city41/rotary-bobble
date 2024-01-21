# Gun Angle

The gun can be set to 121 angles, between -60 and 60. This is a 16 bit signed value stored at main RAM address 0x18262.

Setting this value can be arbitrarily done and the gun will jump to the angle set. Since it is a 16 bit value, setting negative values requires the 2's compliment form to carry across two bytes. In Gngeo, this can be done with `mem68k_store_ram_word(0x18262, angle)`

in mame, this seems to be 0x108262. Unsure why different, but possibly each system has different addressing for whatever reason.
