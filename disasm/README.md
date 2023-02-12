# dis68k

_dis68k_ is a public domain disassembler for the 68000 by W. de Waal, originally developed in 1991 and written in era-appropriate unstandardised C. It was released into the public domain in 1993.

This fork of dis68k seeks to modernise that source code:
* to ensure that it builds with modern compilers;
* to give it normative command-line invocation; and
* where possible, to adapt the code to utilise more modern language constructs.

## Usage

	dis68k < file.rom > disassembly.txt

This disassembler reads from stdin and writes to stdout. You can therefore use the usual means of composition to disassemble directly from compressed files and/or to compress the output: `zcar file.gz | dis68k > disassembly.txt` or similar.

By default the disassembler will assume that the input begins at address 0 and that execution begins at address 0. You can modify that assumption with a map file.

### Map Files

Example map file:

	romstart = FC0000
	FC0000,FC0030,data
	FC0030,FF0000,code
	
This says:

1. the input file data should be located at address `FC0000`;
2. treat the region starting at `FF0000` and ending just before `FC0030` as data;
3. treat the region starting at `FC0030` and ending just before `FF0000` as code.

Map files are specified to the disassembler using the `-m` option, e.g.

	dis68k -m file.map < file.rom > disassembly.txt
