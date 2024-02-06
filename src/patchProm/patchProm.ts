import path from 'node:path';
import fsp from 'node:fs/promises';
import mkdirp from 'mkdirp';
import { execSync } from 'node:child_process';
import {
	AddressPatch,
	Patch,
	PatchDescription,
	PatchJSON,
	PatternPatch,
	StringPatch,
} from './types';
import { doPatch } from './doPatch';
import { asmTmpDir, PROM_FILE_NAME, romTmpDir, tmpDir } from './dirs';

// Place subroutines starting at the very end of the prom and working
// backwards from there
const SUBROUTINE_STARTING_INSERT_END = 0x80000;

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

function isStringPatch(obj: unknown): obj is StringPatch {
	if (!obj) {
		return false;
	}

	if (typeof obj !== 'object') {
		return false;
	}

	const p = obj as StringPatch;

	return p.string === true && typeof p.value === 'string';
}

function isPatternPatch(obj: unknown): obj is PatternPatch {
	if (!obj) {
		return false;
	}

	if (typeof obj !== 'object') {
		return false;
	}

	const p = obj as PatternPatch;

	return typeof p.pattern === 'string' && Array.isArray(p.patchAsm);
}

function isAddressPatch(obj: unknown): obj is PatternPatch {
	if (!obj) {
		return false;
	}

	if (typeof obj !== 'object') {
		return false;
	}

	const p = obj as AddressPatch;

	return typeof p.address === 'string' && Array.isArray(p.patchAsm);
}

function isPatch(obj: unknown): obj is Patch {
	if (!obj) {
		return false;
	}

	if (typeof obj !== 'object') {
		return false;
	}

	const p = obj as Patch;

	return isStringPatch(p) || isPatternPatch(p) || isAddressPatch(p);
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

async function main(patchJsonPaths: string[]) {
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

	let subroutineInsertEnd = SUBROUTINE_STARTING_INSERT_END;

	for (const patchJsonPath of patchJsonPaths) {
		console.log('Starting patch', patchJsonPath);

		let patchJson;
		try {
			patchJson = require(patchJsonPath);
		} catch (e) {
			console.error('Error occured loading the patch', e);
		}

		if (!isPatchJSON(patchJson)) {
			console.error('The JSON at', patchJsonPath, ', is not a valid patch');
			usage();
		}

		console.log(patchJson.shift().patchDescription);

		for (const patch of patchJson) {
			if (patch.skip) {
				console.log('SKIPPING!', patch.description);
				continue;
			}

			const result = await doPatch(patchedPromData, subroutineInsertEnd, patch);
			patchedPromData = result.patchedPromData;
			subroutineInsertEnd = result.subroutineInsertEnd;

			console.log('\n\n');
		}
	}

	const flippedBackPatch = flipBytes(patchedPromData);

	console.log('length after patch', flippedBackPatch.length);
	const writePath = '/home/matt/mame/roms/pbobblen.zip';
	await writeZipWithNewProm(flippedBackPatch, writePath);

	console.log('written patched rom to', writePath);
}

const patchJsonInputPaths = process.argv.slice(2);

if (!patchJsonInputPaths?.length) {
	usage();
}

const finalPatchJsonPaths = patchJsonInputPaths.map((pjip) =>
	path.resolve(process.cwd(), pjip)
);

main(finalPatchJsonPaths).catch((e) => console.error);

export { isStringPatch };
