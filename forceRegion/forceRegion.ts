import fsp from 'node:fs/promises';
import os from 'node:os';
import path from 'node:path';
import mkdirp from 'mkdirp';
import { execSync } from 'node:child_process';

const tmpDir = path.resolve(os.tmpdir(), 'rotary-bobble');
const romTmpDir = path.resolve(tmpDir, 'rom');
const asmTmpDir = path.resolve(tmpDir, 'asm');
const PROM_FILE_NAME = 'd96-07.ep1';

function hexDump(bytes: number[]): string {
	return bytes.map((b) => b.toString(16)).join(' ');
}

function flipBytes(data: number[]): number[] {
	for (let i = 0; i < data.length; i += 2) {
		const byte = data[i];
		data[i] = data[i + 1];
		data[i + 1] = byte;
	}

	return data;
}

async function getProm(zipPath: string): Promise<Buffer> {
	execSync(`unzip -o ${zipPath} -d ${romTmpDir}`);

	return fsp.readFile(path.resolve(romTmpDir, PROM_FILE_NAME));
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

async function assemble(asm: string[]): Promise<number[]> {
	const inputAsmPath = path.resolve(asmTmpDir, 'tmp.asm');
	const outputBinPath = path.resolve(asmTmpDir, 'tmp.bin');

	const asmSrc = asm.map((a) => `\t${a}`).join('\n');
	console.log('asm\n', asmSrc);
	await fsp.writeFile(inputAsmPath, asmSrc);

	execSync(
		`./clownassembler/clownassembler -i ${inputAsmPath} -o ${outputBinPath}`
	);

	const binBuffer = await fsp.readFile(outputBinPath);

	return Array.from(binBuffer);
}

async function replace(
	data: number[],
	from: number[],
	to: string[]
): Promise<number[]> {
	const toBytes = await assemble(to);

	console.log('toBytes', hexDump(toBytes));

	if (toBytes.length !== from.length) {
		throw new Error(
			`replaced: removing ${from.length} bytes but adding ${toBytes.length}, must be same number of bytes`
		);
	}

	let i = 0;

	while (i < data.length) {
		if (areEqual(data, i, from)) {
			console.log('match found, splicing...');
			data.splice(i, from.length, ...toBytes);
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
		path.resolve(romTmpDir, PROM_FILE_NAME),
		new Uint8Array(promData)
	);

	const cmd = 'zip pbobblen.zip *';
	console.log('about to execute', cmd);
	const output = execSync(cmd, { cwd: romTmpDir });
	console.log(output.toString());

	const cpCmd = `cp pbobblen.zip ${outputPath}`;
	console.log('about to execute', cpCmd);
	const output2 = execSync(cpCmd, { cwd: romTmpDir });
	console.log(output2.toString());
}

async function main() {
	await fsp.rm(tmpDir, {
		recursive: true,
		force: true,
		maxRetries: 5,
		retryDelay: 1000,
	});
	await mkdirp(romTmpDir);
	await mkdirp(asmTmpDir);

	const flippedPromBuffer = await getProm(path.resolve('./pbobblen.zip'));
	const flippedPromData = Array.from(flippedPromBuffer);
	const promData = flipBytes(flippedPromData);

	console.log('length before patch', promData.length);

	let patchedPromData = await replace(
		promData,
		[0x10, 0x39, 0x00, 0x10, 0xfd, 0x83],
		['nop', 'move.b #1,d0']
	);

	patchedPromData = await replace(
		patchedPromData,
		[0x0c, 0x39, 0x00, 0x01, 0x00, 0x10, 0xfd, 0x83],
		['cmpi.b #$0,$0010fd83']
	);

	const flippedBackPatch = flipBytes(patchedPromData);

	console.log('length after patch', flippedBackPatch.length);
	const writePath = '/home/matt/.gngeo/roms/pbobblen.zip';
	await writeZipWithNewProm(flippedPromData, writePath);

	console.log('written patched rom to', writePath);
}

main().catch((e) => {
	console.error(e);
});
