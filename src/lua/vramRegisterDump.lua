cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]

prev_vram_index = 0
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
FIX_LAYER = 0x7000
SCB2 = 0x8000
SCB3 = 0x8200
SCB4 = 0x8400
VRAM_SIZE = 0x8600

function on_vram_write(offset, data)
	prev_vram_index = next_vram_index

	if offset == REG_VRAMADDR then
		next_vram_index = data
	end

	if offset == REG_VRAMMOD then
		vram_index_mod = data
	end

	if offset == REG_VRAMRW then
		next_vram_index = next_vram_index + vram_index_mod
	end

	if math.abs(prev_vram_index - next_vram_index) > 1 then
		if next_vram_index < FIX_LAYER then
			print(string.format("VRAMADDR in SCB1: %x", next_vram_index))
		elseif next_vram_index < SCB2 then
			print(string.format("VRAMADDR in FIX LAYER %x", next_vram_index))
		elseif next_vram_index < SCB3 then
			print(string.format("VRAMADDR in SCB2 %x", next_vram_index))
		elseif next_vram_index < SCB4 then
			print(string.format("VRAMADDR in SCB3 %x", next_vram_index))
		elseif next_vram_index < VRAM_SIZE then
			print(string.format("VRAMADDR in SCB4 %x", next_vram_index))
		else
			print("unexpected....")
		end
	end
end

vram_handler = mem:install_write_tap(REG_VRAMADDR, REG_VRAMMOD + 1, "vram", on_vram_write)
