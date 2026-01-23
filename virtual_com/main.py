import subprocess
import time
import serial
import os
from pymavlink import mavutil

PYTHON_SIDE = "COM100"
USER_SIDE = "COM101"
COM0COM_PATH = r"C:\Program Files (x86)\com0com\setupc.exe"
MAV_CUSOMT_PAYLOAD_TYPE = 40001

'''
    https://freevirtualserialports.com/
    https://com0com.sourceforge.net/
'''
def setup_port_bridge():
    if not os.path.exists(COM0COM_PATH):
        print("Driver not found!")
        return False
    
    subprocess.run([COM0COM_PATH, "--silent", "uninstall"], capture_output=True)
    cmd = [
        COM0COM_PATH, 
        "install", 
        f"PortName={PYTHON_SIDE}",
        "EmuBR=yes", 
        "EmuOverrun=yes",
        f"PortName={USER_SIDE}",
        "EmuBR=yes",
        "EmuOverrun=yes",
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode == 0:
        print(f"Success! {USER_SIDE}")
        return True
    else:
        print(f"Error: {result.stderr}")
        return False

if __name__ == "__main__":
    if setup_port_bridge():
        try:
            ser = serial.Serial(PYTHON_SIDE, 9600)
            while True:
                ser.write(b"Hello Arduino from python\n")
                time.sleep(1)
        except Exception as e:
            print(e)