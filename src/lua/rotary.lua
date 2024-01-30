require("keyboard_events")
cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]
screen = manager.machine.screens[":screen"]
input = manager.machine.input

SEND_ANGLES = false

-- | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
-- | D | C | B | A | R | L | D | U |
REG_P1CNT = 0x300000

function angle_to_input(ang)
	if ang < -60 then
		ang = -60
	end
	if ang > 60 then
		ang = 60
	end

	local absAng = math.abs(ang)

	-- the angle needs to be mapped into a seven bit number
	-- populated in a byte where bit 4 is skipped, and but 7 is sign

	local d = ang < 0 and (1 << 7) or (0 << 7)
	local cb = (absAng >> 4) << 5
	local a = FIRE_BALL and (1 << 4) or (0 << 4)
	local rldu = absAng & 0xf

	local regp1cnt = d | cb | a | rldu

	-- on the neo, low means active for regp1cnt,
	-- so negate all the bits
	-- shifting up by 8 because 68k always deals in words
	return (~regp1cnt & 0xff) << 8
end

angle = 61
delta = 1

function next_angle()
	if angle > 60 then
		angle = 59
		delta = -1
	elseif angle < -60 then
		angle = -59
		delta = 1
	else
		angle = angle + delta
	end

	return angle
end

function on_p1cnt_read(offset)
	if offset == REG_P1CNT and SEND_ANGLES then
		next_angle()

		return angle_to_input(angle)
	end
end

function tick()
	keyboard_events.poll()
end

function on_y(e)
	if e == "pressed" then
		SEND_ANGLES = not SEND_ANGLES
	end
end

keyboard_events.register_key_event_callback("KEYCODE_Y", on_y)

emu.register_frame(tick, "tick")

p1cnt_handler = mem:install_read_tap(REG_P1CNT, REG_P1CNT + 1, "p1cnt", on_p1cnt_read)

function on_frame()
	if SEND_ANGLES then
		screen:draw_text(0, 0, string.format("sending: %d", angle), 0xffffffff, 0xff000000)
	else
		screen:draw_text(0, 0, "not sending", 0xffffffff, 0xff000000)
	end
	screen:draw_text(0, 8, string.format("regp1cnt: %x", angle_to_input(angle, false)), 0xffffffff, 0xff000000)
end

emu.register_frame_done(on_frame, "frame")
