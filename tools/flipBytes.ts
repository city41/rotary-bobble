import path from 'node:path';
import fsp from 'node:fs/promises';

async function main() {
	const inputArg = process.argv[2];
	const outputArg = process.argv[3];

	if (!inputArg || !outputArg) {
		console.error(
			'usage: ts-node flipBytes.ts <input rom path> <output rom path>'
		);
		process.exit(1);
	}

	const inputPath = path.resolve(process.cwd(), inputArg);
	const outputPath = path.resolve(process.cwd(), outputArg);

	const data = Array.from(await fsp.readFile(inputPath));

	for (let i = 0; i < data.length; i += 2) {
		const byte = data[i];
		data[i] = data[i + 1];
		data[i + 1] = byte;
	}

	fsp.writeFile(outputPath, Buffer.from(data));

	console.log(`${inputPath} flipped to ${outputPath}`);
}

main();
