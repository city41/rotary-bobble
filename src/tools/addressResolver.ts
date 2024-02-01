import path from 'node:path';
import fsp from 'node:fs/promises';

async function main() {
	const inputArg = process.argv[2];
	const registerArg = process.argv[3];
	const baseAddrArg = process.argv[4];

	if (!inputArg || !registerArg || !baseAddrArg) {
		console.error(
			'usage: ts-node addressResolver.ts <input asm file path> <address registers> <base addresses>'
		);
		console.error(
			'example: ts-node addressResolved.ts myAssembly.asm A4,A5, 108202,108500'
		);
		process.exit(1);
	}

	const registers = registerArg.split(',');
	const baseAddresses = baseAddrArg
		.split(',')
		.map((ba) => parseInt(baseAddrArg, 16));

	const inputPath = path.resolve(process.cwd(), inputArg);
	const asm = (await fsp.readFile(inputPath)).toString();

	const asmLines = asm.split('\n');

	const resolvedLines = asmLines.map((l) => {
		// (<optional negative>$<number in hex>,A<register-index>)
		const replaced = l.replace(
			/\((-?)\$([0-9a-f]+),A(\d)\)/,
			(match, group1OptionalNegative, group2Hex, group3RegistedIndex) => {
				for (let i = 0; i < registers.length; ++i) {
					const register = registers[i];
					const baseAddress = baseAddresses[i];

					if ('A' + group3RegistedIndex == register) {
						let hex = parseInt(group2Hex, 16);

						if (group1OptionalNegative) {
							hex = -hex;
						}

						const fullAddress = baseAddress + hex;

						return `$${fullAddress.toString(16)}`;
					}
				}

				return match;
			}
		);

		if (replaced != l) {
			const spacerLength = 65 - replaced.length;
			const spacer = new Array(spacerLength).join(' ');
			return `${replaced}${spacer};; --- resolved, original: ${l}`;
		}

		return replaced;
	});

	console.log(resolvedLines.join('\n'));
}

main();
