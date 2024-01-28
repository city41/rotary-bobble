
from machine import Pin
import time

p = Pin(22, Pin.OUT)

while True:
    print("press select...")
    p.high()
    time.sleep(.1)
    p.low()
    time.sleep(10)