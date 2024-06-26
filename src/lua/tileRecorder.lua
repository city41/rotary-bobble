-- Record which CROMs are used in game

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

-- toggle sprites/fix on/off
SHOW_SPRITES = true
SHOW_FIX_LAYER = true

-- -- "emulate" vram to grab the data writes and store them in the vram table
-- function on_vram_write(offset, data)
-- 	if offset == REG_VRAMADDR then
-- 		next_vram_index = data
-- 	end

-- 	if offset == REG_VRAMMOD then
-- 		vram_index_mod = data
-- 	end

-- 	if offset == REG_VRAMRW then
-- 		local vri = next_vram_index

-- 		if vri < FIX_LAYER and (vri & 1 == 0) then
-- 			tiles[data] = true
-- 		end

-- 		vram[next_vram_index] = data
-- 		next_vram_index = next_vram_index + vram_index_mod
-- 	end
-- end

-- vram_handler = mem:install_write_tap(REG_VRAMADDR, REG_VRAMMOD + 1, "vram", on_vram_write)

vramdevice = emu.item(manager.machine.devices[":spritegen"].items["0/m_videoram"])

function grab_vram()
	local vram = {}
	for i = 0, VRAM_SIZE - 1 do
		vram[i] = vramdevice:read(i)
	end

	return vram
end

function get_crom_tile_is_in(i)
	if i < 16384 then
		return "c1/c2"
	elseif i < 32768 then
		return "c3/c4"
	else
		return "c5/c6"
	end
end

function isSticky(si, vr)
	local scb3Val = vr[SCB3 + si] or 0

	return scb3Val & 0x40 == 0x40
end

function getSpriteHeight(si, vr)
	if isSticky(si, vr) then
		return getSpriteHeight(si - 1, vr)
	end

	local scb3Val = vr[SCB3 + si] or 0
	return scb3Val & 0x3f
end

function getSpriteTileIndexes(si, vr, h)
	local tileIndexes = {}

	local base = SCB1 + si * 64

	for i = 0, h - 1 do
		local evenWord = vr[base + i * 2] or 0
		local oddWord = vr[base + i * 2 + 1] or 0

		local lsb = evenWord
		local msb = (oddWord >> 4) & 0xf

		table.insert(tileIndexes, (msb << 16) | lsb)
	end

	return tileIndexes
end

function on_frame()
	local vram = grab_vram()
	tiles = {}

	for si = 0, 380 do
		local h = getSpriteHeight(si, vram)
		local tileIndexes = getSpriteTileIndexes(si, vram, h)

		for _, v in pairs(tileIndexes) do
			tiles[v] = true
		end
	end
end

function on_pause()
	local croms_in_use = {}

	for i, _ in pairs(tiles) do
		local crom = get_crom_tile_is_in(i)
		croms_in_use[crom] = croms_in_use[crom] or 0
		croms_in_use[crom] = croms_in_use[crom] + 1
	end

	for crom, tile_count in pairs(croms_in_use) do
		print(string.format("crom: %s, tile count: %d", crom, tile_count))
	end
end

emu.register_pause(on_pause, "pause")
emu.register_frame_done(on_frame, "frame")
