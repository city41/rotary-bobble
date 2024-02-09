from machine import Pin
import utime


# this requires using the entire pot range
# which is unfortunate, but the trade off is
# much more stable readings
MIN_EXTENT = 0
MAX_EXTENT = 127

MIN_ANGLE = -60
MAX_ANGLE = 60

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

def median(lst, n):
    s = sorted(lst)
    return (s[n//2-1]/2.0+s[n//2]/2.0, s[n//2])[n % 2]

def get_voltage():
    voltages = []
    
    for i in range(10):
        voltages.append(potPin.read_u16())
        utime.sleep_us(500)
    
    min_v = min(voltages)
    max_v = max(voltages)
    trimmed_voltages = [i for i in voltages if i > min_v and i < max_v]
    
    n = len(trimmed_voltages)
    
    if n == 0:
        return int((min_v + max_v) // 1024)
    
    return int(median(trimmed_voltages, n) // 512)



while True:
    potRawValue = get_voltage()
    
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

    #utime.sleep_ms(3)


