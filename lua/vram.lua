cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]
screen = manager.machine.screens[":screen"]

-- what vram looked like last frame
prev_vram = {}
-- what vram looks like this frame
vram = {}
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

-- "emulate" vram to grab the data writes and store them in the vram table
function on_vram_write(offset, data) 
  if (offset == REG_VRAMADDR) then
    next_vram_index = data
  end

  if (offset == REG_VRAMMOD) then
    vram_index_mod = data
  end

  if (offset == REG_VRAMRW) then
    vram[next_vram_index] = data
    next_vram_index = next_vram_index + vram_index_mod

    if (not SHOW_FIX_LAYER) and next_vram_index >= FIX_LAYER and next_vram_index <= SCB2 then
      return 0xff
    end

    if (not SHOW_SPRITES) and next_vram_index >= SCB4 and next_vram_index <= VRAM_SIZE then
      -- this moves the sprites off the screen, 320 is to account for stickied sprites
      -- who might be only moving their control sprite
      return -320
    end
  end
end

-- given a sprite index and an array of vram, returns how tall this sprite is
function getSpriteHeight(si, vr) 
  local scb3Val = vr[SCB3 + si] or 0
  return scb3Val & 0x3f
end

-- given a sprite index and an array of vram, returns all the tiles currently used by the sprite
function getSpriteTiles(si, h, vr)
  local tiles = {}

  local base = SCB1 + si * 64

  for i=0,h-1 do
    tiles[i] = (vr[base + i * 2] or 0) << 16 | (vr[base + i * 2 + 1] or 0)
  end

  return tiles
end

function areTablesEqual(a, b)
  if #a ~= #b then
    return false
  end

  for k, v in pairs(a) do
    if b[k] ~= v then
      return false
    end
  end

  return true
end

-- given a sprite index, looks at prev_vram and vram to see if it has changed
-- this frame. If so, it will show up green on screen, otherwise red
-- changes considered: height and tile indexes
function spriteJustChanged(si)
  height = getSpriteHeight(si, vram)
  if height ~= getSpriteHeight(si, prev_vram) then
    return true
  end

  local tiles = getSpriteTiles(si, height, vram)
  local prevTiles = getSpriteTiles(si, height, prev_vram)

  if not areTablesEqual(tiles, prevTiles) then
    return true
  end

  return false
end

function visualize_sprites()
  for i=0,380 do
    local height = getSpriteHeight(i, vram)
    local x = getSpriteX(i, vram)
    local y = getSpriteY(i, vram)


  end

end

function visualize_vram()
  visualize_sprites()

  for i=0,VRAM_SIZE-1 do
    prev_vram[i] = vram[i]
  end
end

function on_pause() 
  visualize_vram()
end

emu.register_pause(on_pause, "pause")

vram_handler = mem:install_write_tap(REG_VRAMADDR, REG_VRAMMOD + 1, "vram", on_vram_write)