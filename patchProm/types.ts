export type PatchDescription = {
	patchDescription: string;
};

export type Patch = {
	description?: string;
	pattern: string;
	subroutine?: boolean;
	patchAsm: string[];
};

export type PatchJSON = Patch[];
