import path from 'node:path';
import fsp from 'node:fs/promises';
import { execSync } from 'node:child_process';
import { Patch } from './types';
import { asmTmpDir } from './dirs';

let subroutineInsertEnd = 0x80000;

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
			`replace: removing ${from.length} bytes but adding ${toBytes.length}, must be same number of bytes`
		);
	}

	let i = 0;
	let matchCount = 0;

	while (i < data.length) {
		if (areEqual(data, i, from)) {
			console.log('replace: match found, splicing...');
			data.splice(i, from.length, ...toBytes);
			i += from.length;
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
	from: number[],
	subroutine: string[]
): Promise<number[]> {
	const subroutineBytes = await assemble(subroutine);

	const subroutineStartAddress = subroutineInsertEnd - subroutineBytes.length;
	const jsrAsm = await formJsrAsm(from.length, subroutineStartAddress);

	const jsrAddedData = await replace(data, from, jsrAsm);

	console.log(
		'replacedWithSubroutine: splicing in subroutine at',
		subroutineStartAddress
	);
	jsrAddedData.splice(
		subroutineStartAddress,
		subroutineBytes.length,
		...subroutineBytes
	);

	return jsrAddedData;
}

function toBytes(b: string): number[] {
	return b.split(' ').map((v) => parseInt(v, 16));
}

async function doPatch(promData: number[], patch: Patch): Promise<number[]> {
	console.log('applying patch');
	console.log(patch.description ?? '(patch has no description)');

	if (patch.subroutine) {
		return replaceWithSubroutine(
			promData,
			toBytes(patch.pattern),
			patch.patchAsm
		);
	} else {
		return replace(promData, toBytes(patch.pattern), patch.patchAsm);
	}
}

export { doPatch };
