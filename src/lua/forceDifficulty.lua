require("keyboard_events")

cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]

-- the difficult address
address = 0x1014ab

function on_memory_write(offset, data)
	print(string.format("offset: %x, data: %x", offset, data))
	if offset == address then
		-- force the difficult to always be "mvs"
		return 3
	end
end

mem_handler = mem:install_write_tap(address - 1, address + 4, "writes", on_memory_write)
