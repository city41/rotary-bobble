import fsp from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import { execSync } from 'node:child_process';

const tmpDir = path.resolve(os.tmpdir(), 'rotary-bobble');
const PROM_FILE_NAME = 'd96-07.ep1';

function flipBytes(data: number[]): number[] {
	for (let i = 0; i < data.length; i += 2) {
		const byte = data[i];
		data[i] = data[i + 1];
		data[i + 1] = byte;
	}

	return data;
}

async function getProm(zipPath: string): Promise<Buffer> {
	execSync(`unzip -o ${zipPath} -d ${tmpDir}`);

	return fsp.readFile(path.resolve(tmpDir, PROM_FILE_NAME));
}

function areEqual(
	largeArray: number[],
	index: number,
	compareArray: number[]
): boolean {
	return compareArray.every((a, i) => {
		return largeArray[index + i] === a;
	});
}

function replace(data: number[], from: number[], to: number[]): number[] {
	let i = 0;

	while (i < data.length) {
		if (areEqual(data, i, from)) {
			console.log('match found, splicing...');
			data.splice(i, from.length, ...to);
			i += from.length;
		} else {
			i += 1;
		}
	}

	return data;
}

async function writeZipWithNewProm(
	promData: number[],
	outputPath: string
): Promise<void> {
	await fsp.writeFile(
		path.resolve(tmpDir, PROM_FILE_NAME),
		new Uint8Array(promData)
	);

	const cmd = `zip pbobblen.zip ${tmpDir}/*`;
	console.log('about to execute', cmd);
	const output = execSync(cmd, { cwd: tmpDir });
	console.log(output.toString());

	const cpCmd = `cp pbobblen.zip ${outputPath}`;
	console.log('about to execute', cpCmd);
	const output2 = execSync(cpCmd, { cwd: tmpDir });
	console.log(output2.toString());
}

async function main() {
	const flippedPromBuffer = await getProm(path.resolve('./pbobblen.zip'));
	const flippedPromData = Array.from(flippedPromBuffer);
	const promData = flipBytes(flippedPromData);

	// original
	// 0003132e : 1039 0010 fd83 MOVE.B   $0010fd83,D0
	// patched
	// nop move.b #1,d0 -- 4e71 103c 0001
	let patchedPromData = replace(
		promData,
		[0x10, 0x39, 0x00, 0x10, 0xfd, 0x83],
		[0x4e, 0x71, 0x10, 0x3c, 0x00, 0x01]
	);

	// original
	// 00003dbc : 0c39 0001 0010 fd83 CMPI.B   #$01,$0010fd83
	// patched
	// cmp1.b #$0,$0010fd83 -- 0c39 0000 0010 fd83
	patchedPromData = replace(
		patchedPromData,
		[0x0c, 0x39, 0x00, 0x01, 0x00, 0x10, 0xfd, 0x83],
		[0x0c, 0x39, 0x00, 0x00, 0x00, 0x10, 0xfd, 0x83]
	);

	const flippedBackPatch = flipBytes(patchedPromData);

	console.log('length', flippedBackPatch.length);
	const writePath = '/home/matt/.gngeo/roms/pbobblen.zip';
	await writeZipWithNewProm(flippedPromData, writePath);

	console.log('written patched rom to', writePath);
}

main().catch((e) => {
	console.error(e);
});
