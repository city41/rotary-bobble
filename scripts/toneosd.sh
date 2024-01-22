#!/bin/bash

rm -rf toneosd
mkdir toneosd
cd toneosd
cp /home/matt/mame/roms/pbobblen.zip .
unzip pbobblen.zip
mv d96-07.ep1 068-p1.p1
mv d96-01.v3 068-v3.v3
mv d96-02.c5 068-c5.c5
mv d96-03.c6 068-c6.c6
mv d96-04.s1 068-s1.s1
mv d96-05.v4 068-v4.v4
mv d96-06.m1 068-m1.m1
neosdconv -i . -o /home/matt/dev/rotary-bobble/rotarybobble.neo -y 2024 -n rotarybobble -g Puzzle -m Taito_city41