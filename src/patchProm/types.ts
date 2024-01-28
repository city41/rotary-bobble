export type PatchDescription = {
	patchDescription: string;
};

export type PatternPatch = {
	description?: string;
	pattern: string;
	subroutine?: boolean;
	patchAsm: string[];
};

export type AddressPatch = {
	description?: string;
	address: string;
	subroutine?: boolean;
	patchAsm: string[];
};

export type Patch = PatternPatch | AddressPatch;

export type PatchJSON = Patch[];
