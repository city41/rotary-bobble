require("keyboard_events")
cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]
screen = manager.machine.screens[":screen"]
input = manager.machine.input

SEND_ANGLES = false

-- | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
-- | D | C | B | A | R | L | D | U |
REG_P1CNT = 0x300000

function angle_to_input(ang, aIsPressed)
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
	local a = aIsPressed and (1 << 4) or (0 << 4)
	local rldu = absAng & 0xf

	local regp1cnt = d | cb | a | rldu

	-- on the neo, low means active for regp1cnt,
	-- so negate all the bits
	-- shifting up by 8 because 68k always deals in words
	return (~regp1cnt & 0xff) << 8
end

angle = -60

jump_angles = { -40, 50, -10, 60, 0, 1, 2, 3, 4, -58, 60 }
jump_index = 1

function next_angle_jump()
	local jump_angle = jump_angles[jump_index]
	jump_index = jump_index + 1

	if jump_index > #jump_angles then
		jump_index = 1
	end

	angle = jump_angle
end

delta = 1

function next_angle_sweep()
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

counter = 0

function on_p1cnt_read(offset, data)
	if offset == REG_P1CNT and SEND_ANGLES then
		counter = counter + 1

		if counter % 30 == 0 then
			next_angle_sweep()
		end

		local aIsPressed = ((data >> 12) & 1) == 0

		return angle_to_input(angle, aIsPressed)
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
end

emu.register_frame_done(on_frame, "frame")
