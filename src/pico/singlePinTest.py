from machine import Pin
import utime

BTN_D = 0 # grey
BTN_C = 1 # orange
BTN_B = 2 # red
DIR_R = 3 # yellow
DIR_L = 4 # green
DIR_D = 6 # blue
DIR_U = 7 # purple

btnPin = Pin(BTN_D, Pin.OUT)

led = Pin("LED", Pin.OUT)
led.off()

def setPin(i, bit):
    assert bit == 0 or bit == 1, "bit value is invalid"
    assert i >= 0 and i <= 7, "index out of range"

    # pinResult[i] = str(bit)
    pins[i].value(bit)

while True:
    btnPin.on()
    utime.sleep_ms(10)
    btnPin.off()
    utime.sleep(2)


