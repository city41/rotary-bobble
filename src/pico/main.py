from machine import Pin
import utime

MIN_ANGLE = -60
MAX_ANGLE = 60

SLEEP_DUR_MS = 10

# these values follow REG_P1CNT/REG_P2CNT
BTN_D = 7
BTN_C = 6
BTN_B = 5
DIR_R = 3
DIR_L = 2
DIR_D = 1
DIR_U = 0

btnDPin = Pin(BTN_D, Pin.OUT)
btnCPin = Pin(BTN_C, Pin.OUT)
btnBPin = Pin(BTN_B, Pin.OUT)
dirRPin = Pin(DIR_R, Pin.OUT)
dirLPin = Pin(DIR_L, Pin.OUT)
dirDPin = Pin(DIR_D, Pin.OUT)
dirUPin = Pin(DIR_U, Pin.OUT)

led = Pin("LED", Pin.OUT)

# on the Neo we will take REG_P1CNT [DCBARLDU] and massage it into [CBRLDU]
# and D is the sign bit
# so the pins here need to match, but flipped as least sig bit is on left here -> [UDLRBCD]
pins = [dirUPin, dirDPin, dirLPin, dirRPin, btnBPin, btnCPin, btnDPin]
BUT_D_INDEX = 6

potPin = machine.ADC(26)

def mapValue(inputMin, inputMax, outputMin, outputMax, val):
    return outputMin + ((outputMax - outputMin) / (inputMax - inputMin)) * (val - inputMin)

def toBitplane(val):
    assert val <= MAX_ANGLE, "angle out of range"
    assert val >= 0, "angle should only be positive at this point"

    bitplane = []
    for i in range(7):
        bitplane.append(val & 1)
        val = val >> 1

    return bitplane


# pinResult = ['0', '0', '0', '0', '0', '0', '0']
def setPin(i, bit):
    assert bit == 0 or bit == 1, "bit value is invalid"
    assert i >= 0 and i <= 7, "index out of range"

    # pinResult[i] = str(bit)
    pins[i].value(bit)

while True:
    potRawValue = potPin.read_u16()
    angle = int(mapValue(192, 65200, MIN_ANGLE, MAX_ANGLE, potRawValue))
    angleBitplane = toBitplane(abs(angle))

    if angle < 0:
        angleBitplane[BUT_D_INDEX] = 1
    else:
        angleBitplane[BUT_D_INDEX] = 0


    led.on()
    for i in range(7):
        pin = pins[i]
        setPin(i, angleBitplane[i])
    led.off()

    # print("raw", potRawValue, "angle", angle, "pins", "".join(pinResult))

    utime.sleep_ms(SLEEP_DUR_MS)


