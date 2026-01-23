import random
import subprocess
import time
import serial
import os
from pymavlink import mavutil

MAV_CUSTOM_PAYLOAD_TYPE = 40002
MAV_CONNECTION = 'udpin:127.0.0.1:14551'

def mav_tunnel_recv(mav_connection, blocking:bool = True) -> bytes | None:
    msg = mav_connection.recv_match(type='TUNNEL', blocking=blocking)
    if not msg:
        return None

    raw_data = msg.payload
    payload_bytes:bytes = raw_data[:msg.payload_length]
    return msg.payload_type, payload_bytes


def mav_tunnel_send(mav_connection, payload: bytes, custom_payload_type: int) -> bool:
    if not mav_connection:
        return False

    MAV_TUNNEL_MAX_PAYLOAD_SIZE = 128
    if len(payload) > MAV_TUNNEL_MAX_PAYLOAD_SIZE:
        raise ValueError('Payload too large! Maximum 128 bytes.')

    length = len(payload)
    # Pad the payload to 128 bytes with 0 - mavlink2 zero truncating
    padded_payload = payload.ljust(MAV_TUNNEL_MAX_PAYLOAD_SIZE, b'\0')

    mav_connection.mav.tunnel_send(
        target_system=mav_connection.target_system,
        target_component=mav_connection.target_component,
        payload_type=custom_payload_type,
        payload_length=length,
        payload=padded_payload
    )

    return True


def setupMavlink():
    connection = mavutil.mavlink_connection(MAV_CONNECTION)
    print("Waiting for heartbeat from drone...")
    connection.wait_heartbeat()
    print(F"mavlink target_system: {connection.target_system}")
    print(F"mavlink target_component: {connection.target_component}")
    print(f"Heartbeat received from System {connection.target_system}")

    while True:
        # rand_bytes = random.randbytes(128)
        number = 255
        rand_bytes = number.to_bytes(2, 'little')

        if mav_tunnel_send(connection, rand_bytes, MAV_CUSTOM_PAYLOAD_TYPE):
            print(f"Sent {len(rand_bytes)} bytes with payload with tunnel custom payload {MAV_CUSTOM_PAYLOAD_TYPE}")
        payload_type, recv_data = mav_tunnel_recv(connection)
        print(F"data: {payload_type} {recv_data}")
        time.sleep(0.5)

if __name__ == "__main__":
    setupMavlink()