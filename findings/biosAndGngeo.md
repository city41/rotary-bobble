# the BIOS and GnGeo

neogeo.zip is the bios dump, but it can contain numerous different files and there's not much rhyme or reason.

Gngeo will use its config to decide what type of bios to try and load. Then from there look in neogeo.zip for specific files

## The sfix file

The sfix.sfx or sfix.sfix file is the built in fix rom on MVS systems. Gngeo will always try to load this, even in AES mode, so it must always be present. It will try both names.

## MVS

No setting needed for `system` as mvs/arcade is the default. But can add `system mvs` or `system arcade` for clarity.

### Europe

Europe is the default region. But can add `country europe` for clarity.

neogeo.zip must have `sp-s2.sp1`

### Japan

```
country japan
```

neogeo.zip must have `vs-bios.rom`

### USA

```
country usa
```

neogeo.zip must have `usa_2slt.bin`

Archive.org has this file here: https://ia802900.us.archive.org/view_archive.php?archive=/8/items/MAME_2003-Plus_Reference_Set_2018/roms/bakatono.zip

### Asia

```
country asia
```

neogeo.zip must have `asia-s3.rom`

## AES

set `system home`

neogeo.zip must have `aes-bios.bin`

I've not found an aes bios anywhere

Unsure what is needed for regions

## Uni-Bios

set `system unibios`

neogeo.zip must have `uni-bios.rom`, easily obtained here: http://unibios.free.fr/download.html

NOTE: the download only has `uni-bios.rom` in it, you must also make sure `sfix.sfx` is present. Easiest to just add `uni-bios.rom` to an existing neogeo.zip
