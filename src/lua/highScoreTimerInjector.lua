cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]
screen = manager.machine.screens[":screen"]

-- the timer
-- address = 0x10205e
address = 0x105a8a

function on_timer_write(offset, data)
	if offset == address then
		-- print("data", data)
		return 10
	end
end

timer_handler = mem:install_write_tap(address, address + 1, "timer", on_timer_write)
