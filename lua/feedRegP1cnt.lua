require "keyboard_events"

cpu = manager.machine.devices[":maincpu"]
mem = cpu.spaces["program"]
screen = manager.machine.screens[":screen"]

REG_P1CNT = 0x300000

SETTING = 0

function on_reg_read(offset, data) 
  if (offset == REG_P1CNT) then
    if (SETTING % 3) == 1 then
        -- 01101111, negate since low is active -> 10010000
        return 0x9000 -- lrud and bc, causing a value of 63, clamped to 60
    end

    if (SETTING % 3) == 2 then
        -- 11101111, negate since low is active -> 00010000
        return 0x1000 -- lrud and bcd, causing a value of -63, clamped to -60
    end

    return data
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
angle_handler = mem:install_write_tap(ANGLE_ADDR, ANGLE_ADDR + 1, "angle", on_angle_write)

function tick()
  keyboard_events.poll()
end

function on_frame()
    str = "no forced input"
    if SETTING == 1 then
        str = "max positive"
    end
    if SETTING == 2 then
        str = "max negative"
    end

    screen:draw_text(0, 0, str, 0xffffffff, 0xff000000)

    if angle ~= nil then
        screen:draw_text(0, 10, string.format("angle: %x", angle), 0xffffffff, 0xff000000)
    end
end

emu.register_frame(tick, "tick")
emu.register_frame_done(on_frame, "frame")

function on_t(e)
  if e == "pressed" then
    SETTING = (SETTING + 1) % 3
  end
end

keyboard_events.register_key_event_callback("KEYCODE_T", on_t)