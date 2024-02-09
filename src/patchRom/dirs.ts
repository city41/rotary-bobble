import os from 'node:os';
import path from 'node:path';

export const tmpDir = path.resolve(os.tmpdir(), 'rotary-bobble');
export const romTmpDir = path.resolve(tmpDir, 'rom');
export const asmTmpDir = path.resolve(tmpDir, 'asm');
export const PROM_FILE_NAME = 'd96-07.ep1';
