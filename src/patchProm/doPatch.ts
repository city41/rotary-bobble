import path from 'node:path';
import fsp from 'node:fs/promises';
import mkdirp from 'mkdirp';
import { execSync } from 'node:child_process';
import { Patch } from './types';
import { asmTmpDir } from './dirs';

function hexDump(bytes: number[]): string {
	return bytes.map((b) => b.toString(16)).join(' ');
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
	await mkdirp(asmTmpDir);
	const inputAsmPath = path.resolve(asmTmpDir, 'tmp.asm');
	const outputBinPath = path.resolve(asmTmpDir, 'tmp.bin');

	const asmSrc = asm.map((a) => `\t${a}`).join('\n');
	console.log('asm\n', asmSrc);

	console.log('writing asm to', inputAsmPath);
	await fsp.writeFile(inputAsmPath, asmSrc);

	const assembleCommand = `./clownassembler/clownassembler -i ${inputAsmPath} -o ${outputBinPath}`;
	console.log('about to assemble', assembleCommand);
	execSync(assembleCommand);

	const binBuffer = await fsp.readFile(outputBinPath);

	console.log('binary length', binBuffer.length);

	return Array.from(binBuffer);
}

async function replaceAt(
	data: number[],
	address: string,
	asm: string[]
): Promise<number[]> {
	const asmBytes = await assemble(asm);

	console.log('replaceAt: asmBytes', hexDump(asmBytes));

	const index = parseInt(address, 16);
	data.splice(index, asmBytes.length, ...asmBytes);

	return data;
}

async function replaceWithPattern(
	data: number[],
	pattern: number[],
	asm: string[]
): Promise<number[]> {
	const toBytes = await assemble(asm);

	console.log('toBytes', hexDump(toBytes));

	if (toBytes.length !== pattern.length) {
		throw new Error(
			`replace: removing ${pattern.length} bytes but adding ${toBytes.length}, must be same number of bytes`
		);
	}

	let i = 0;
	let matchCount = 0;

	while (i < data.length) {
		if (areEqual(data, i, pattern)) {
			console.log('replace: match found, splicing...');
			data.splice(i, pattern.length, ...toBytes);
			i += pattern.length;
			matchCount += 1;
		} else {
			i += 1;
		}
	}

	console.log('replace: matched', matchCount, 'times');
	return data;
}

function formJsrAsm(numBytesToReplace: number, jsrAddress: number): string[] {
	if (numBytesToReplace < 6) {
		throw new Error(
			`formJsr: not enough room. Need 6 bytes, only have ${numBytesToReplace}`
		);
	}

	if (numBytesToReplace % 1 !== 0) {
		throw new Error(
			`formJsr: bytes to replace must be an even count, got ${numBytesToReplace}`
		);
	}

	const numNops = (numBytesToReplace - 6) / 2;

	const asmNops = new Array(numNops).fill(0).map(() => 'nop');
	return asmNops.concat(`jsr $${jsrAddress.toString(16)}`);
}

async function replaceWithSubroutine(
	data: number[],
	subroutineInsertEnd: number,
	patch: Patch
): Promise<{ patchedPromData: number[]; subroutineInsertEnd: number }> {
	const subroutineBytes = await assemble(patch.patchAsm);
	console.log(
		'replaceWithSubroutine: subroutinebytes',
		hexDump(subroutineBytes)
	);

	const subroutineStartAddress = subroutineInsertEnd - subroutineBytes.length;

	let jsrAsm;
	let jsrAddedData: number[];

	if ('address' in patch) {
		jsrAsm = await formJsrAsm(6, subroutineStartAddress);
		jsrAddedData = await replaceAt(data, patch.address, jsrAsm);
	} else {
		const patternBytes = toBytes(patch.pattern);
		jsrAsm = await formJsrAsm(patternBytes.length, subroutineStartAddress);
		jsrAddedData = await replaceWithPattern(data, patternBytes, jsrAsm);
	}

	console.log(
		`replacedWithSubroutine: splicing in subroutine at 0x${subroutineStartAddress.toString(
			16
		)}`
	);
	jsrAddedData.splice(
		subroutineStartAddress,
		subroutineBytes.length,
		...subroutineBytes
	);

	return {
		patchedPromData: jsrAddedData,
		subroutineInsertEnd: subroutineStartAddress,
	};
}

async function replace(data: number[], patch: Patch): Promise<number[]> {
	if ('address' in patch) {
		return replaceAt(data, patch.address, patch.patchAsm);
	} else {
		return replaceWithPattern(data, toBytes(patch.pattern), patch.patchAsm);
	}
}

function toBytes(b: string): number[] {
	return b.split(' ').map((v) => parseInt(v, 16));
}

async function doPatch(
	promData: number[],
	subroutineInsertEnd: number,
	patch: Patch
): Promise<{ patchedPromData: number[]; subroutineInsertEnd: number }> {
	console.log('applying patch');
	console.log(patch.description ?? '(patch has no description)');

	if (patch.subroutine) {
		return replaceWithSubroutine(promData, subroutineInsertEnd, patch);
	} else {
		return {
			patchedPromData: await replace(promData, patch),
			subroutineInsertEnd,
		};
	}
}

export { doPatch };
