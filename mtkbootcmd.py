#!/usr/bin/env python3

import sys
import time
import glob
import serial

def serial_ports():
    if sys.platform.startswith('win'):
        _ports = ['COM%s' % (i + 1) for i in range(256)]
    elif sys.platform.startswith('linux') or sys.platform.startswith('cygwin'):
        _ports = glob.glob('/dev/tty[A-Za-z]*')
    elif sys.platform.startswith('darwin'):
        # Don't accidentally look up wlan-debug and bluetooth ports
        _ports = glob.glob('/dev/tty.usbmodem*')
    else:
        raise EnvironmentError('Unsupported platform')

    result = []
    for port in _ports:
        try:
            s = serial.Serial(port)
            s.close()
            result.append(port)
        except (OSError, serial.SerialException):
            pass
    return result


BOOTSEQ = bytes(sys.argv[1], "ascii")
READYCMD = b"READY"

if __name__ == '__main__':
    print('Listening for ports!')
    abort = False
    while not abort:
        time.sleep(1)
        ports = serial_ports()
        if len(ports) > 0:
            print('Got ports:', ports)
            for port in ports:
                print('Initializing port', port)
                ser = serial.Serial(port=port, baudrate=115200)
                try:
                    resp = ser.read(5)
                    if resp == READYCMD:
                        ser.write(BOOTSEQ)
                        print("{} cmd sent".format(BOOTSEQ))
                        abort = True
                        break
                    else:
                        raise Exception()
                except:
                    print('No READY signal, next port.')
                    continue
