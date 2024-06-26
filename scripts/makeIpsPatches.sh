#!/bin/bash

GAME='pbobblen'
HACK='rotary'

rm -rf ipsBinaries
rm -rf ipsPatches

mkdir ipsPatches
mkdir ipsBinaries
mkdir ipsBinaries/original
mkdir ipsBinaries/hacked

yarn restore;
cp ${MAME_ROM_DIR}/${GAME}.zip ipsBinaries/original/

yarn ts-node src/patchRom/main.ts src/patches/rotary-bobble.json
cp ${MAME_ROM_DIR}/${GAME}.zip ipsBinaries/hacked/

(cd ipsBinaries/original/ && unzip ${GAME}.zip)
(cd ipsBinaries/hacked/ && unzip ${GAME}.zip)

for f in `ls ipsBinaries/original/ -I ${GAME}.zip`; do
    bf=`basename ${f}`

    originalFile="ipsBinaries/original/${bf}"
    hackedFile="ipsBinaries/hacked/${bf}"

    originalSha=$(sha256sum "${originalFile}" | awk '{ print $1 }' )
    hackedSha=$(sha256sum "${hackedFile}" | awk '{ print $1 }' )

    echo "${bf} originalSha: ${originalSha}"
    echo "${bf} hackedSha: ${hackedSha}"

    if [ "${originalSha}" != "${hackedSha}" ]; then
        echo "Creating ips for ${bf}"
        yarn ts-node src/tools/makeIpsPatch.ts ipsBinaries/original/${bf} ipsBinaries/hacked/${bf} ipsPatches/${GAME}${HACK}.${bf}.ips
    fi
done

(cd ipsPatches && zip ${GAME}${HACK}IpsPatches.zip *.ips)