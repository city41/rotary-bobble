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

INPUT_TILE = 0x865e
OUTPUT_TILE = 0x866f

-- "emulate" vram to grab the data writes and store them in the vram table
function on_vram_write(offset, data)
	if offset == REG_VRAMADDR then
		next_vram_index = data
	end

	if offset == REG_VRAMMOD then
		vram_index_mod = data
	end

	if offset == REG_VRAMRW then
		local vri = next_vram_index
		next_vram_index = next_vram_index + vram_index_mod

		if vri >= 0 and vri <= FIX_LAYER and (vri & 1 == 0) then
			-- this is an even write into SCB1, the LSBs of the tile
			if data == INPUT_TILE then
				local si = math.floor(vri / 64)
				print(string.format("tile injected, sprite index: %d", si))
				return OUTPUT_TILE
			end
		end
	end
end

vram_handler = mem:install_write_tap(REG_VRAMADDR, REG_VRAMMOD + 1, "vram", on_vram_write)
