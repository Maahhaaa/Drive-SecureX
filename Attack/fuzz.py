import can
import random
import time

bus = can.interface.Bus(
    channel='vcan0',
    bustype='socketcan'
)

def random_data():
    # MUST be 8 bytes because your API expects byte1..byte8
    return bytes(random.getrandbits(8) for _ in range(8))

print("[*] Starting CAN Fuzzing (API compatible)...")

while True:
    arbitration_id = random.randint(0x000, 0x7FF)
    data = random_data()

    msg = can.Message(
        arbitration_id=arbitration_id,
        data=data,
        is_extended_id=False
    )

    try:
        bus.send(msg)
    except can.CanError as e:
        print(f"[!] Send error: {e}")

    time.sleep(0.00001)
