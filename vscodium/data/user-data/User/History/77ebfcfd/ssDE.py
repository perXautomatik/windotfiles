import machine
import time

maxPos = 15
minPos = 8
shiftedPos  = 8
apin = machine.ADC(27)

lowestAverage = 1470
maxc = lowestAverage+1
minc = lowestAverage
timesa = 0
timesi = 0


while True:
    time.sleep(0.4)
    millivolts = apin.read_u16()
    celsius = (millivolts - 500.0) / 10.0

    print(",,")

    maxYes = timesa == 6 | (celsius > maxc)
    minYes = timesi == 6 | (celsius < minc)
    pos = round(((celsius-minc)/(maxc - minc))*7)
    
    print(",,")

    if (maxYes) :
        maxc = celsius
        MappedToPinns = 7
        timesa = 0
    elif (minYes) :
        minc = celsius
        MappedToPinns = 0
        timesi = 0
    else:
        MappedToPinns = pos

    print(",,")

    shiftedPos = ( minPos + MappedToPinns )

    led = machine.Pin(shiftedPos, machine.Pin.OUT)

    
    if bin( machine.Pin(maxPos, machine.Pin.OUT).value() ==  0 ) :
        timesa = timesa + 1
        
    if bin( machine.Pin(minPos, machine.Pin.OUT).value() ==  0 ) :
        timesi = timesi + 1 

    print("....")


