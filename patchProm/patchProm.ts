import path from 'node:path';
import fsp from 'node:fs/promises';
import mkdirp from 'mkdirp';
import { execSync } from 'node:child_process';
import { Patch, PatchDescription, PatchJSON } from './types';
import { doPatch } from './doPatch';
import { asmTmpDir, PROM_FILE_NAME, romTmpDir, tmpDir } from './dirs';

function usage() {
	console.error('usage: ts-node patchProm <patch-json>');
	process.exit(1);
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

function isPatchDescription(obj: unknown): obj is PatchDescription {
	if (!obj) {
		return false;
	}

	if (typeof obj !== 'object') {
		return false;
	}

	const p = obj as PatchDescription;

	return typeof p.patchDescription === 'string';
}

function isPatch(obj: unknown): obj is Patch {
	if (!obj) {
		return false;
	}

	if (typeof obj !== 'object') {
		return false;
	}

	const p = obj as Patch;

	return Array.isArray(p.patchAsm);
}

function isPatchJSON(obj: unknown): obj is PatchJSON {
	if (!obj) {
		return false;
	}

	if (!Array.isArray(obj)) {
		return false;
	}

	if (obj.length < 2) {
		return false;
	}

	return obj.every((e, i) => {
		if (i === 0) {
			return isPatchDescription(e);
		} else {
			return isPatch(e);
		}
	});
}

async function dumpProms(
	unpatchedProm: number[],
	patchedProm: number[],
	dir: string
): Promise<void> {
	const unpatchedPath = path.resolve(dir, 'unpatched.p1.bin');
	const patchedPath = path.resolve(dir, 'patched.p1.bin');

	await mkdirp(path.resolve(dir));
	await fsp.writeFile(unpatchedPath, new Uint8Array(unpatchedProm));
	await fsp.writeFile(patchedPath, new Uint8Array(patchedProm));

	try {
		execSync(
			`./disasm/dis68k < ${unpatchedPath} > ${path.resolve(
				dir,
				'unpatched.p1.txt'
			)}`
		);
	} catch {}

	try {
		execSync(
			`./disasm/dis68k < ${patchedPath} > ${path.resolve(
				dir,
				'patched.p1.txt'
			)}`
		);
	} catch {}
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

async function main(patchJsonPath: string) {
	const patchJson = require(patchJsonPath);

	if (!isPatchJSON(patchJson)) {
		usage();
	}

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

	let patchedPromData = [...promData];

	console.log('Starting patch');
	console.log(patchJson.shift().patchDescription);

	for (const patch of patchJson) {
		patchedPromData = await doPatch(patchedPromData, patch);
		console.log('\n\n');
	}

	await dumpProms(promData, patchedPromData, './proms');

	const flippedBackPatch = flipBytes(patchedPromData);

	console.log('length after patch', flippedBackPatch.length);
	const writePath = '/home/matt/.gngeo/roms/pbobblen.zip';
	await writeZipWithNewProm(flippedBackPatch, writePath);

	console.log('written patched rom to', writePath);
}

const patchJsonInputPath = process.argv[2];

if (!patchJsonInputPath) {
	usage();
}

main(path.resolve(process.cwd(), patchJsonInputPath)).catch(
	(e) => console.error
);
