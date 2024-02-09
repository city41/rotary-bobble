cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]

-- where vram will write to next
next_vram_index = 0
-- how much to move the index based on REG_VRAMMOD
vram_index_mod = 1

-- where the game wants to write in VRAM
REG_VRAMADDR = 0x3c0000
-- how much to move the index after a write
REG_VRAMMOD = 0x3c0004
-- a data write
REG_VRAMRW = 0x3c0002

SCB1 = 0
SCB2 = 0x8000
SCB3 = 0x8200
SCB4 = 0x8400
VRAM_SIZE = 0x8600
FIX_LAYER = 0x7000

target_si_indexes = {
	189,
	307,
}

-- "emulate" vram to grab the data writes and store them in the vram table
function on_vram_write(offset, data)
	if offset == REG_VRAMADDR then
		next_vram_index = data
	end

	if offset == REG_VRAMMOD then
		vram_index_mod = data
	end

	if offset == REG_VRAMRW then
		for _, si in pairs(target_si_indexes) do
			local vri = si * 64 + 1

			if next_vram_index == vri then
				print(string.format("raw data: %x", data))
				print(string.format("si: %d, palette: %x", si, data >> 8))
			end
		end

		next_vram_index = next_vram_index + vram_index_mod
	end
end

vram_handler = mem:install_write_tap(REG_VRAMADDR, REG_VRAMMOD + 1, "vram", on_vram_write)
