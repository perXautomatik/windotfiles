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

if (6 timesa 0 then maxc OR celc > maxc )
    maxc = celc
    MappedToPinns = 7
    timesa = 0
else if (6 timesi 0 min OR celc < min )
    minc = celc
    MappedToPinns = 0
    timesi = 0
else 
    MappedToPinns = round(((celc-min)\(maxc - minc))*7)


  print(",,")

  led = machine.Pin(MappedToPinns, machine.Pin.OUT)

  if ( machine.Pin(15, machine.Pin.OUT).value() =  0 )
    timesa = timesa + 1; 
    

  if ( machine.Pin(7, machine.Pin.OUT).value() =  0 )
    timesi = timesi + 1; 

  print("....")


