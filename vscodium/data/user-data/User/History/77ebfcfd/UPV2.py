import machine
import time

from boot import http_get
http_get()


def clearPins():
    for i in range(1,27):
        pin = machine.Pin(i, machine.Pin.OUT)
        pin.off()    
    
    return void

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

    maxYes = timesa == 6 | (celsius > maxc)
    minYes = timesi == 6 | (celsius < minc)
    
    pool = maxc - minc
    qpool = celsius-minc
    if (pool < 0) | (pool == 0) :
      pool = 1
    
    if (qpool > pool) :
        qpool = pool -0.5
    
    pos = round(((celsius-minc)/pool)*7)%7

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

    shiftedPos = ( minPos + MappedToPinns )

    led = machine.Pin(shiftedPos, machine.Pin.OUT)
    led.toggle()
    
    if bin( machine.Pin(maxPos, machine.Pin.OUT).value() ==  0 ) :
        timesa = timesa + 1
        
    if bin( machine.Pin(minPos, machine.Pin.OUT).value() ==  0 ) :
        timesi = timesi + 1 



