#!/usr/bin/env python3

import sys
import time
import glob
import serial
import serial.tools.list_ports

PLBROM_HWID = "VID:PID=0E8D:2000"
BOOTSEQ = bytes(sys.argv[1], "ascii")
READYCMD = b"READY"


def serial_port():
    ports = list(serial.tools.list_ports.comports())
    for port in ports:
        if PLBROM_HWID in port.hwid:
            print("Found {} with description: {}\nHWID: {}".format(port.device, port.description, port.hwid))
            return port.device
    return None


if __name__ == '__main__':
    print('Listening for ports!')
    abort = False
    while not abort:
        time.sleep(1)
        port = serial_port()
        if port is not None:
            print('Got port:', port)
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
