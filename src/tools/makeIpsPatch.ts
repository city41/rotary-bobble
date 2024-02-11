import path from 'node:path';
import fsp from 'node:fs/promises';

type Diff = {
	offset: number;
	length: number;
	diffBytes: number[];
};

const IPS_HEADER = 'PATCH'.split('').map((c) => c.charCodeAt(0));
const IPS_EOF = 'EOF'.split('').map((c) => c.charCodeAt(0));

function usage() {
	console.error(
		'ts-node makeIpsPatch.ts <hacked-binary-path> <original-binary-path> <ips-dest-path>'
	);
}

function toBytes(num: number, byteCount: number): number[] {
	const bytes: number[] = [];

	for (let i = 0; i < byteCount; ++i) {
		const byte = num & 0xff;
		bytes.push(byte);
		num = num >> 8;
	}

	return bytes.reverse();
}

function getDiffs(originalBinary: number[], hackedBinary: number[]): Diff[] {
	const diffs: Diff[] = [];
	let currentDiff: Diff | null = null;

	for (
		let i = 0;
		i < Math.max(originalBinary.length, hackedBinary.length);
		i++
	) {
		if (originalBinary[i] !== hackedBinary[i]) {
			if (currentDiff === null) {
				currentDiff = { offset: i, length: 1, diffBytes: [hackedBinary[i]] };
			} else {
				currentDiff.length++;
				currentDiff.diffBytes.push(hackedBinary[i]);
			}
		} else {
			if (currentDiff !== null) {
				diffs.push(currentDiff);
				currentDiff = null;
			}
		}
	}

	if (currentDiff !== null) {
		diffs.push(currentDiff);
	}

	return diffs;
}

function createIpsPatch(
	hackedBinary: number[],
	originalBinary: number[]
): number[] {
	const diffs = getDiffs(hackedBinary, originalBinary);

	const ipsDiffData = diffs.flatMap((d) => {
		return [...toBytes(d.offset, 3), ...toBytes(d.length, 2), ...d.diffBytes];
	});

	const ipsData = [...IPS_HEADER, ...ipsDiffData, ...IPS_EOF];

	return ipsData;
}

async function main(
	hackedPath: string,
	originalPath: string,
	destPath: string
): Promise<void> {
	const hackedBinary = Array.from(
		new Uint8Array(await fsp.readFile(hackedPath))
	);
	const originalBinary = Array.from(
		new Uint8Array(await fsp.readFile(originalPath))
	);

	const ipsPatchData = createIpsPatch(hackedBinary, originalBinary);

	return fsp.writeFile(destPath, Uint8Array.from(ipsPatchData));
}

const [_tsnode, _makeIpsPatch, hackedBinaryPath, originalBinaryPath, destPath] =
	process.argv;

if (!hackedBinaryPath || !originalBinaryPath) {
	usage();
	process.exit(1);
}

main(
	path.resolve(process.cwd(), hackedBinaryPath),
	path.resolve(process.cwd(), originalBinaryPath),
	path.resolve(process.cwd(), destPath)
)
	.then(() => console.log('done'))
	.catch((e) => console.error(e));
