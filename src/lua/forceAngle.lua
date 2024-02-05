require("keyboard_events")

cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]

-- the shooter angle address
address = 0x108262

function on_memory_write(offset, data)
	if offset == address then
		-- force the shooter to always be at 10 degrees
		return 10
	end
end

mem_handler = mem:install_write_tap(address, address + 1, "writes", on_memory_write)
