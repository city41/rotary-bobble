require("keyboard_events")

cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]

TRACK_MEM = false
RANGE_START = 0x108020
RANGE_END = 0x108400

writes = {}

function on_memory_write(offset, data)
	if TRACK_MEM then
		writes[offset] = 1
	end
end

mem_handler = mem:install_write_tap(RANGE_START, RANGE_END + 1, "writes", on_memory_write)

function on_pause()
	local c = 0
	for k, _ in pairs(writes) do
		c = c + 1
		print(string.format("%x", k))
	end

	print("address count", c)
end

function tick()
	keyboard_events.poll()
end

function on_y(e)
	if e == "pressed" then
		TRACK_MEM = not TRACK_MEM
	end

	print("tracking mem?", TRACK_MEM)
end

keyboard_events.register_key_event_callback("KEYCODE_Y", on_y)

emu.register_pause(on_pause, "pause")
emu.register_frame(tick, "tick")
