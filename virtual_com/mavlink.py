import subprocess
import time
import serial
import os
from pymavlink import mavutil

MAV_CUSOMT_PAYLOAD_TYPE = 40002

def recv_mav_tunnel(mav_connection) -> bytes:
    msg = mav_connection.recv_match(type='TUNNEL', blocking=True)
    if msg.payload_type == MAV_CUSOMT_PAYLOAD_TYPE:
        raw_data = msg.payload
        actual_data = raw_data[:msg.payload_length]
        return actual_data

def send_mav_tunnel(mav_connection, payload):
        MAV_TUNNEL_MAX_PAYLOAD_SIZE = 128
        if len(payload) > MAV_TUNNEL_MAX_PAYLOAD_SIZE:
            raise ValueError('Payload too large! Maximum 128 bytes.')

        length = len(payload)
        # Pad the payload to 128 bytes if necessary (required by some dialects)
        padded_payload = payload.ljust(128, b'\0')

        mav_connection.mav.tunnel_send(
            target_system=mav_connection.target_system,
            target_component=mav_connection.target_component,
            payload_type=MAV_CUSOMT_PAYLOAD_TYPE,
            payload_length=length,
            payload=padded_payload
        )
        print(f"Sent {length} bytes with payload type {MAV_CUSOMT_PAYLOAD_TYPE}")


def setupMavlink():
    connection = mavutil.mavlink_connection('udpin:127.0.0.1:14551')
    print("Waiting for heartbeat from drone...")
    connection.wait_heartbeat()
    print(f"Heartbeat received from System {connection.target_system}")

    while True:
        send_mav_tunnel(connection, b'\x01\x02\x03\x04\x05\x06')
        recv_data = recv_mav_tunnel(connection)
        # print(type(recv_data))
        print(F"data: {recv_data}")
        time.sleep(0.1)

if __name__ == "__main__":
    setupMavlink()