import can
import time
import random

channel = "vcan0"
interface = "socketcan"

bus = can.interface.Bus(
    channel=channel,
    interface=interface
)

can_id = 0x00  # fixed ID

print("[+] Starting CAN simulator (single loop)")
print("[+] Press Ctrl+C to stop\n")

try:
    while True:
        msg = can.Message(
            arbitration_id=can_id,
            data=[random.randint(0x00, 0xFF) for _ in range(8)],
            is_extended_id=False
        )

        try:
            bus.send(msg)
            print(f"ID=0x00 DATA={list(msg.data)}")
        except Exception as e:
            print("Send error:", e)

        time.sleep(0.000000000000000000000000000000000000000000000000000001)
        
except KeyboardInterrupt:
    print("\n[!] Stopped safely")
