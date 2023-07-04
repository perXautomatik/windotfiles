import machine
import time

apin = machine.ADC(27)

lowestAverage = 1470

while True:
  time.sleep(0.4)
  millivolts = apin.read_u16()
  celsius = (millivolts - 500.0) / 10.0
  
  
  state15 = machine.Pin(15, machine.Pin.OUT).value()
  print(state15)
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
  state7 = machine.Pin(7, machine.Pin.OUT).value()
  print(state7)

  dividedW = (celsius-lowestAverage)/10

  modByNrSensors = dividedW%7
  MappedToPinns = 15-round(modByNrSensors)
  print("....")
  print(MappedToPinns)
  print(celsius)
  
  led = machine.Pin(MappedToPinns, machine.Pin.OUT)

  led.toggle()


