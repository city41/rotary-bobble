cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]
screen = manager.machine.screens[":screen"]

-- the lower word of the score
-- higher word is at 0x10820a
address = 0x10820c

function on_score_write(offset, data)
	if offset == address then
		-- quadruple the score earned
		return 8000
	end
end

score_handler = mem:install_write_tap(address, address + 1, "score", on_score_write)
