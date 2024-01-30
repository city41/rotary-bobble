import utime
from machine import Pin

potentiometer = machine.ADC(26) # Physical Pin 31 or GP26
conversion_factor = 3.3 / (65535) #3.3 is the volts we have avaliable 

while True:
    voltage = potentiometer.read_u16() * conversion_factor # 0 - 3.3 volts
    print(voltage) # Prints value in the shell
    utime.sleep(1) # refresh every second