require("keyboard_events")

cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]
screen = manager.machine.screens[":screen"]

-- this address is the "shooter delta", whatever gets
-- set here will get added to the shooter's current angle
address = 0x108212

function on_memory_write(offset, data)
	if offset == address then
		-- by multiplying the value, the end result is the shooter travels
		-- much faster
		return data * 4
	end
end

mem_handler = mem:install_write_tap(address, address + 1, "writes", on_memory_write)
