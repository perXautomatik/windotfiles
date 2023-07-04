import machine
import time

maxPos = 14
minPos = 7
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

    led = machine.Pin((minPos+MappedToPinns), machine.Pin.OUT)

    
    if bin( machine.Pin(maxPos, machine.Pin.OUT).value() ==  0 ) :
        timesa = timesa + 1
        
    if bin( machine.Pin(minPos, machine.Pin.OUT).value() ==  0 ) :
        timesi = timesi + 1 

    print("....")


