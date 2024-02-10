import path from 'node:path';
import fsp from 'node:fs/promises';
import mkdirp from 'mkdirp';
import { execSync } from 'node:child_process';
import { PROM_FILE_NAME, asmTmpDir, romTmpDir, tmpDir } from './dirs';
import {
	AddressPromPatch,
	CromBuffer,
	CromPatch,
	Patch,
	PatchDescription,
	PatchJSON,
	PatternPromPatch,
	StringPromPatch,
} from './types';
import { doPromPatch } from './doPromPatch';
import { createCromBytes } from './createCromBytes';
import { insertIntoCrom } from './insertIntoCrom';

// Place subroutines starting at the very end of the prom and working
// backwards from there
const SUBROUTINE_STARTING_INSERT_END = 0x80000;

function usage() {
	console.error('usage: ts-node src/patchRom/main.ts <patch-json>');
	process.exit(1);
}

async function getProm(zipPath: string): Promise<Buffer> {
	execSync(`unzip -o ${zipPath} -d ${romTmpDir}`);

	return fsp.readFile(path.resolve(romTmpDir, PROM_FILE_NAME));
}

async function getCrom(zipPath: string, cromFile: string): Promise<CromBuffer> {
	execSync(`unzip -o ${zipPath} -d ${romTmpDir}`);

	return {
		fileName: cromFile,
		data: Array.from(await fsp.readFile(path.resolve(romTmpDir, cromFile))),
	};
}

function flipBytes(data: number[]): number[] {
	for (let i = 0; i < data.length; i += 2) {
		const byte = data[i];
		data[i] = data[i + 1];
		data[i + 1] = byte;
	}

	return data;
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

function isStringPatch(obj: unknown): obj is StringPromPatch {
	if (!obj) {
		return false;
	}

	if (typeof obj !== 'object') {
		return false;
	}

	const p = obj as StringPromPatch;

	return p.string === true && typeof p.value === 'string';
}

function isPatternPatch(obj: unknown): obj is PatternPromPatch {
	if (!obj) {
		return false;
	}

	if (typeof obj !== 'object') {
		return false;
	}

	const p = obj as PatternPromPatch;

	return typeof p.pattern === 'string' && Array.isArray(p.patchAsm);
}

function isAddressPatch(obj: unknown): obj is AddressPromPatch {
	if (!obj) {
		return false;
	}

	if (typeof obj !== 'object') {
		return false;
	}

	const p = obj as AddressPromPatch;

	return Array.isArray(p.patchAsm) && !isPatternPatch(obj);
}

function isCromPatch(obj: unknown): obj is CromPatch {
	if (!obj) {
		return false;
	}

	if (typeof obj !== 'object') {
		return false;
	}

	const p = obj as CromPatch;

	return (
		typeof p.destStartingIndex === 'string' &&
		typeof p.imgFile === 'string' &&
		typeof p.paletteFile === 'string'
	);
}

function isPatch(obj: unknown): obj is Patch {
	if (!obj) {
		return false;
	}

	if (typeof obj !== 'object') {
		return false;
	}

	const p = obj as Patch;

	return (
		isStringPatch(p) || isPatternPatch(p) || isAddressPatch(p) || isCromPatch(p)
	);
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

async function writePatchedZip(
	promData: number[],
	cromBuffers: CromBuffer[],
	outputPath: string
): Promise<void> {
	await fsp.writeFile(
		path.resolve(romTmpDir, PROM_FILE_NAME),
		new Uint8Array(promData)
	);

	for (const cromBuffer of cromBuffers) {
		await fsp.writeFile(
			path.resolve(romTmpDir, cromBuffer.fileName),
			new Uint8Array(cromBuffer.data)
		);
	}

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

	let patchedPromData = [...promData];

	let cromBuffers = [
		await getCrom(path.resolve('./pbobblen.zip'), '068-c1.c1'),
		await getCrom(path.resolve('./pbobblen.zip'), '068-c2.c2'),
		await getCrom(path.resolve('./pbobblen.zip'), '068-c3.c3'),
		await getCrom(path.resolve('./pbobblen.zip'), '068-c4.c4'),
		await getCrom(path.resolve('./pbobblen.zip'), 'd96-02.c5'),
		await getCrom(path.resolve('./pbobblen.zip'), 'd96-03.c6'),
	];

	let subroutineInsertEnd = SUBROUTINE_STARTING_INSERT_END;

	for (const patchJsonPath of patchJsonPaths) {
		const jsonDir = path.dirname(patchJsonPath);
		console.log('Starting patch', patchJsonPath);

		let patchJson;
		try {
			patchJson = require(patchJsonPath);
		} catch (e) {
			console.error('Error occured loading the patch', e);
		}

		if (!isPatchJSON(patchJson)) {
			console.error(
				'The JSON at',
				patchJsonPath,
				', is not a valid patch file'
			);
			usage();
		}

		console.log(patchJson.shift().patchDescription);

		for (const patch of patchJson) {
			if (patch.skip) {
				console.log('SKIPPING!', patch.description);
				continue;
			}

			if (patch.type === 'prom') {
				const result = await doPromPatch(
					patchedPromData,
					subroutineInsertEnd,
					patch
				);
				patchedPromData = result.patchedPromData;
				subroutineInsertEnd = result.subroutineInsertEnd;
			} else if (patch.type === 'crom') {
				try {
					console.log(patch.description);
					console.log('creating crom bytes for', patch.imgFile);
					const { oddCromBytes, evenCromBytes } = createCromBytes(
						path.resolve(jsonDir, patch.imgFile),
						path.resolve(jsonDir, patch.paletteFile)
					);

					const startingCromTileIndex = parseInt(patch.destStartingIndex, 16);
					const tileIndexes: number[] = [];
					const tileCount = oddCromBytes.length / 64;
					for (let t = 0; t < tileCount; ++t) {
						tileIndexes.push(startingCromTileIndex + t);
					}

					console.log(
						'inserting crom data into croms at tile indexes:',
						tileIndexes.map((ti) => ti.toString(16)).join(',')
					);
					cromBuffers = await insertIntoCrom(
						oddCromBytes,
						evenCromBytes,
						parseInt(patch.destStartingIndex, 16),
						cromBuffers
					);

					console.log('\n\n');
				} catch (e) {
					console.error(e);
				}
			} else {
				throw new Error('unknown patch type: ' + patch.type);
			}

			console.log('\n\n');
		}
	}

	const flippedBackPatch = flipBytes(patchedPromData);

	const mameDir = process.env.MAME_ROM_DIR;

	if (!mameDir?.trim()) {
		throw new Error('MAME_ROM_DIR env variable is not set');
	}

	const writePath = path.resolve(mameDir, 'pbobblen.zip');
	await writePatchedZip(flippedBackPatch, cromBuffers, writePath);

	console.log('wrote patched rom to', writePath);
}

const patchJsonInputPaths = process.argv.slice(2);

if (!patchJsonInputPaths?.length) {
	usage();
}

const finalPatchJsonPaths = patchJsonInputPaths.map((pjip) =>
	path.resolve(process.cwd(), pjip)
);

main(finalPatchJsonPaths).catch((e) => console.error);

export { isStringPatch, isCromPatch };
