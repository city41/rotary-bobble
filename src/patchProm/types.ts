export type PatchDescription = {
	patchDescription: string;
};

export type BasePatch = {
	description?: string;
	skip?: boolean;
};

export type PatternPatch = BasePatch & {
	pattern: string;
	subroutine?: boolean;
	patchAsm: string[];
};

export type AddressPatch = BasePatch & {
	address: string;
	subroutine?: boolean;
	patchAsm: string[];
};

export type StringPatch = BasePatch & {
	string: true;
	value: string;
};

export type Patch = PatternPatch | AddressPatch | StringPatch;

export type PatchJSON = Patch[];
