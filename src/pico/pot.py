import utime
from machine import Pin

pot = machine.ADC(26)

while True:
    voltage = pot.read_u16() 
    print(voltage)
    utime.sleep(1)