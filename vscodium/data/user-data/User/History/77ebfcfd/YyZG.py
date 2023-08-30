import machine
import time

apin = machine.ADC(27)

lowestAverage = 1470

while True:
  time.sleep(0.4)
  millivolts = apin.read_u16()
  celsius = (millivolts - 500.0) / 10.0
    
  dividedW = (celsius-lowestAverage)/9

''' we're observing a window of aproximately 0-70 units fluctoations
    we hope to spread out the fluctuations over the whole band of leds some what evenly
    for the sake of doing that we could give it a static value but that's obeusly boring
    so instead we're trye to use the pin values as a crude memmory, we can modify the light array
    by tweaking the offset, and amplitude, id like to not go above any values or to belove, as that sim
    ply ressults in overflow and cycles arround due to our modulus check, but i think it's bit unharmonic though.
    
    amplitude is modified by the dividedW and ofset is the lowestAverage

    '''
  
  modByNrSensors = dividedW%7  
  MappedToPinns = 15-round(modByNrSensors)  
  led = machine.Pin(MappedToPinns, machine.Pin.OUT)
  led.toggle()
  
  print("....")
  print(MappedToPinns)
  print(celsius)
  
  lowest = machine.Pin(15, machine.Pin.OUT).value()
  print(lowest)
  state14 = machine.Pin(14, machine.Pin.OUT).value()
  print(state14)
  state13 = machine.Pin(13, machine.Pin.OUT).value()
  print(state13)
  state12 = machine.Pin(12, machine.Pin.OUT).value()
  print(state12)
  state11 = machine.Pin(11, machine.Pin.OUT).value()
  print(state11)
  state10 = machine.Pin(10, machine.Pin.OUT).value()
  print(state10)
  state9 = machine.Pin(9, machine.Pin.OUT).value()
  print(state9)
  state8 = machine.Pin(8, machine.Pin.OUT).value()
  print(state8)
  highest = machine.Pin(7, machine.Pin.OUT).value()
  print(highest)


