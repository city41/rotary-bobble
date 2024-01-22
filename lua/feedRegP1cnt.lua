require "keyboard_events"

cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]
screen = manager.machine.screens[":screen"]

REG_P1CNT = 0x300000

RETURN_INPUT = false

function on_reg_read(offset, data) 
  if (offset == REG_P1CNT) then
    if RETURN_INPUT then
        -- 00010000
        -- 11110000
        return 0xf000 -- press a
    else
        return data
    end
  end
end

ANGLE_ADDR = 0x108262
angle = nil

function on_angle_write(offset, data)
    if offset == ANGLE_ADDR then
        angle = data
    end
end

reg_handler = mem:install_read_tap(REG_P1CNT, REG_P1CNT + 1, "reg", on_reg_read)
angle_hanlder = mem:install_write_tap(ANGLE_ADDR, ANGLE_ADDR + 1, "angle", on_angle_write)

function tick()
  keyboard_events.poll()
end

function on_frame()
    local str = RETURN_INPUT and "returning input" or "not returning input"
    screen:draw_text(0, 0, str, 0xffffffff, 0xff000000)

    if angle ~= nil then
        screen:draw_text(0, 10, string.format("angle: %x", angle), 0xffffffff, 0xff000000)
    end
end

emu.register_frame(tick, "tick")
emu.register_frame_done(on_frame, "frame")

function on_t(e)
  if e == "pressed" then
    RETURN_INPUT = not RETURN_INPUT
  end
end

keyboard_events.register_key_event_callback("KEYCODE_T", on_t)