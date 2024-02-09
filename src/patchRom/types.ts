export type PatchDescription = {
	patchDescription: string;
};

export type CromPatch = {
	type: 'crom';
	description?: string;
	skip?: boolean;
	imgFile: string;
	paletteFile: string;
	destStartingIndex: string;
};

export type CromBuffer = {
	fileName: string;
	data: number[];
};

export type BasePromPatch = {
	type: 'prom';
	description?: string;
	skip?: boolean;
};

export type PatternPromPatch = BasePromPatch & {
	pattern: string;
	subroutine?: boolean;
	patchAsm: string[];
};

export type AddressPromPatch = BasePromPatch & {
	address?: string;
	subroutine?: boolean;
	patchAsm: string[];
};

export type StringPromPatch = BasePromPatch & {
	string: true;
	value: string;
};

export type Patch =
	| PatternPromPatch
	| AddressPromPatch
	| StringPromPatch
	| CromPatch;

export type PatchJSON = Patch[];
