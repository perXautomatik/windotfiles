# boot.py -- run on boot-up
def clearPins():
    for i in range(1,27):
        pin = machine.Pin(i, machine.Pin.OUT)
        pin.off()    
    
    return void