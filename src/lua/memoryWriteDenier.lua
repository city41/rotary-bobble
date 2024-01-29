require("keyboard_events")

cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]
screen = manager.machine.screens[":screen"]

index = 36

addresses = {
	0x108170,
	0x108172,
	0x108192,
	0x108194,
	0x108196,
	0x1081fa,
	0x10820e,
	0x108210,
	0x108212,
	0x108214,
	0x10821c,
	0x108232,
	0x108234,
	0x108236,
	0x108244,
	0x108246,
	0x108248,
	0x10824a,
	0x10824c,
	0x10824e,
	0x108254,
	0x108256,
	0x108258,
	0x10825a,
	0x10825e,
	0x108260,
	0x108262,
	0x108266,
	0x108268,
	0x10826a,
	0x10826c,
	0x10826e,
	0x108284,
	0x1082ae,
	0x1082b0,
	0x108320,
}

DENY_MEM = false
RANGE_START = 0x108020
RANGE_END = 0x108400

writes = {}

function on_memory_write(offset, data)
	if DENY_MEM and offset == addresses[index] then
		print("received", data)
		return 0
	end
end

mem_handler = mem:install_write_tap(RANGE_START, RANGE_END + 1, "writes", on_memory_write)

function tick()
	keyboard_events.poll()
end

function on_y(e)
	if e == "pressed" then
		DENY_MEM = not DENY_MEM
	end
end

keyboard_events.register_key_event_callback("KEYCODE_Y", on_y)

emu.register_frame(tick, "tick")

function on_frame()
	if DENY_MEM then
		screen:draw_text(0, 0, string.format("denying: %x", addresses[index]), 0xffffffff, 0xff000000)
	else
		screen:draw_text(0, 0, string.format("not denying: %x", addresses[index]), 0xffffffff, 0xff000000)
	end

	screen:draw_text(0, 8, string.format("%d/%d", index, #addresses), 0xffffffff, 0xff000000)
end

emu.register_frame_done(on_frame, "frame")
