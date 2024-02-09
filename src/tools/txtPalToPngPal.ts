import * as path from 'node:path';
import * as fsp from 'node:fs/promises';
import { createCanvas } from 'canvas';

// https://wiki.neogeodev.org/index.php?title=Colors
// [Db | r0 | g0 | b0 | r4 | r3 | r2 | r1 | g4 | g3 | g2 | g1 | b4 | b3 | b2 | b1 ]

// d rgb rrrr gggg bbbb
// 0 010 0101 1001 1001

// first color in palette: 5631
// decoded by mame -- r:67 g:2c b:16
// 0101011000110001
// d rgb rrrr gggg bbbb
// 0 101 0110 0011 0001

// red 0110 1 0

function mapValue(
	inputMin: number,
	inputMax: number,
	outputMin: number,
	outputMax: number,
	val: number
): number {
	return Math.floor(
		outputMin +
			((outputMax - outputMin) / (inputMax - inputMin)) * (val - inputMin)
	);
}

function converTo24BitCss(col16: number) {
	const db = (col16 >> 15) & 0x1;

	const rMSB = (col16 >> 8) & 0xf;
	const r0 = (col16 >> 14) & 0x1;
	const r6 = (rMSB << 2) | (r0 << 1) | db;

	const gMSB = (col16 >> 4) & 0xf;
	const g0 = (col16 >> 13) & 0x1;
	const g6 = (gMSB << 2) | (g0 << 1) | db;

	const bMSB = col16 & 0xf;
	const b0 = (col16 >> 12) & 0x1;
	const b6 = (bMSB << 2) | (b0 << 1) | db;

	const r = mapValue(0, 63, 0, 255, r6);
	const g = mapValue(0, 63, 0, 255, g6);
	const b = mapValue(0, 63, 0, 255, b6);

	if (col16 === 0x5631) {
		console.log(
			`0x5631, r:${r.toString(16)}(${r}), g:${g.toString(16)}, b:${b.toString(
				16
			)}`
		);
	}

	return `rgb(${r}, ${g}, ${b})`;
}

async function main(txtPath: string) {
	const rawPaletteTxt = (await fsp.readFile(txtPath)).toString();
	const pal16 = rawPaletteTxt.split(' ').map((rs) => parseInt(rs, 16));
	console.log(
		'pal16',
		pal16.map((c) => c.toString(16))
	);

	const canvas = createCanvas(16, 1);
	const context = canvas.getContext('2d');

	for (let c = 0; c < pal16.length; ++c) {
		const col16 = pal16[c];
		const cssCol24 = converTo24BitCss(col16);
		context.fillStyle = cssCol24;
		context.fillRect(c, 0, 1, 1);
	}

	const canvasBuffer = canvas.toBuffer();

	const pngPath = txtPath + '.png';
	await fsp.writeFile(pngPath, canvasBuffer);
	console.log('written to', pngPath);
}

const [_tsnode, _txtPalToPngPal, txtFile] = process.argv;

if (!txtFile) {
	console.error('usage: ts-node txtPalToPngPal.ts <txt-pal-file>');
	process.exit(1);
}

const txtFilePath = path.resolve(process.cwd(), txtFile);

main(txtFilePath)
	.then(() => console.log('done'))
	.catch((e) => console.error(e));
