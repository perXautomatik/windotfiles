import machine
import time

apin = machine.ADC(27)

lowestAverage = 1470
timesa = 0
timesi = 0


while True:
    time.sleep(0.4)
    millivolts = apin.read_u16()
    celsius = (millivolts - 500.0) / 10.0

    print(",,")

    if bin(timesa == 6 | celsius > maxc ) :
        maxc = celsius
        MappedToPinns = 7
        timesa = 0
    elif bin(timesi == 6 | celsius < min ) :
        minc = celsius
        MappedToPinns = 0
        timesi = 0
    else:
        MappedToPinns = round(((celsius-min)/(maxc - minc))*7)

    print(",,")

    led = machine.Pin(MappedToPinns, machine.Pin.OUT)

    if bin( machine.Pin(15, machine.Pin.OUT).value() ==  0 ) :
        timesa = timesa + 1; 
        

    if bin( machine.Pin(7, machine.Pin.OUT).value() ==  0 ) :
        timesi = timesi + 1; 

    print("....")


