from machine import Pin
import utime

MIN_ANGLE = -60
MAX_ANGLE = 60

SLEEP_DUR_MS = 10

BTN_D = 0 # grey
BTN_C = 1 # orange
BTN_B = 2 # red
DIR_R = 3 # yellow
DIR_L = 4 # green
DIR_D = 6 # blue
DIR_U = 7 # purple

btnDPin = Pin(BTN_D, Pin.OUT)
btnCPin = Pin(BTN_C, Pin.OUT)
btnBPin = Pin(BTN_B, Pin.OUT)
dirRPin = Pin(DIR_R, Pin.OUT)
dirLPin = Pin(DIR_L, Pin.OUT)
dirDPin = Pin(DIR_D, Pin.OUT)
dirUPin = Pin(DIR_U, Pin.OUT)

led = Pin("LED", Pin.OUT)

# this switches the power supply mode, from one that is more efficent but has lots of noise,
# to one that is more power hungry but smoother. This will smooth out the analog voltage readings
# from the pot
# this doesn't seem to make any difference...
# psModePin = Pin(23, Pin.OUT)
#psModePin.on()

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
    
STEP_DOWN_FACTOR = 270
# this gives us roughly a 120 degree sweep on the physical pot
EXTENT = 16250 // STEP_DOWN_FACTOR
MIN_EXTENT = EXTENT
MAX_EXTENT = (65535 // STEP_DOWN_FACTOR) - EXTENT

while True:
    potRawValue = round(potPin.read_u16() / STEP_DOWN_FACTOR)
    
    if potRawValue < MIN_EXTENT:
        potRawValue = MIN_EXTENT
        
    if potRawValue > MAX_EXTENT:
        potRawValue = MAX_EXTENT
    
    angle = int(round(mapValue(MIN_EXTENT, MAX_EXTENT, MIN_ANGLE, MAX_ANGLE, potRawValue)))
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


