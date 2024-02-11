#!/bin/bash

rm -rf ipsBinaries
rm -rf ipsPatches

mkdir ipsPatches
mkdir ipsBinaries
mkdir ipsBinaries/original
mkdir ipsBinaries/hacked

yarn restore;
cp $MAME_ROM_DIR/pbobblen.zip ipsBinaries/original/

yarn ts-node src/patchRom/main.ts src/patches/rotary-bobble.json
cp $MAME_ROM_DIR/pbobblen.zip ipsBinaries/hacked/

(cd ipsBinaries/original/ && unzip pbobblen.zip)
(cd ipsBinaries/hacked/ && unzip pbobblen.zip)

PROM='d96-07.ep1'
CROM5='d96-02.c5'
CROM6='d96-03.c6'

yarn ts-node src/tools/makeIpsPatch.ts ipsBinaries/hacked/$PROM ipsBinaries/original/$PROM ipsPatches/pbobblen.$PROM.ips
yarn ts-node src/tools/makeIpsPatch.ts ipsBinaries/hacked/$CROM5 ipsBinaries/original/$CROM5 ipsPatches/pbobblen.$CROM5.ips
yarn ts-node src/tools/makeIpsPatch.ts ipsBinaries/hacked/$CROM6 ipsBinaries/original/$CROM6 ipsPatches/pbobblen.$CROM6.ips