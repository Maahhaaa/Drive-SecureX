"""
CAN IDS live pipeline — threaded python-can listener feeding a REST /latest
endpoint for the mobile app, matching the startup_event / /latest pattern.

Run with:  uvicorn main:app --host 0.0.0.0 --port 8000
(see run instructions at the bottom of this file's docstring / chat reply)
"""

import re
import math
import time
import threading
import asyncio
from collections import Counter, defaultdict, deque

import numpy as np
import pandas as pd
import joblib
import can

from fastapi import FastAPI

# ---------------------------------------------------------------------------
# Feature columns — must match training order exactly
# ---------------------------------------------------------------------------
FEATURE_COLUMNS = [
    'DLC',
    'dominant_id_ratio',
    'id_time_diff',
    'message_frequency',
    'payload_entropy',
    'payload_change',
    'byte_mean',
    'byte_std',
    'byte1', 'byte2', 'byte3', 'byte4',
    'byte5', 'byte6', 'byte7', 'byte8',
]


def shannon_entropy(byte_list) -> float:
    if not byte_list:
        return 0.0
    counts = Counter(byte_list)
    n = len(byte_list)
    return -sum((c / n) * math.log2(c / n) for c in counts.values())


class CANFeatureExtractor:
    """Rolling per-CAN-ID state, fed one frame at a time off the live bus."""

    def __init__(self, freq_window: int = 20):
        self.freq_window = freq_window
        self.total_count = 0
        self.id_counts = Counter()
        self.last_timestamp = {}
        self.last_payload = {}
        self.id_timestamps = defaultdict(lambda: deque(maxlen=freq_window))

    def extract(self, canid: str, timestamp: float, payload: list) -> dict:
        self.total_count += 1
        self.id_counts[canid] += 1
        dominant_id_ratio = self.id_counts[canid] / self.total_count

        last_ts = self.last_timestamp.get(canid, timestamp)
        id_time_diff = timestamp - last_ts

        ts_window = self.id_timestamps[canid]
        ts_window.append(timestamp)
        if len(ts_window) >= 2:
            span = ts_window[-1] - ts_window[0]
            message_frequency = (len(ts_window) - 1) / span if span > 0 else 0.0
        else:
            message_frequency = 0.0

        payload_entropy = shannon_entropy(payload)

        prev_payload = self.last_payload.get(canid, payload)
        payload_change = float(np.mean([abs(c - p) for c, p in zip(payload, prev_payload)]))

        byte_mean = float(np.mean(payload))
        byte_std = float(np.std(payload))

        self.last_timestamp[canid] = timestamp
        self.last_payload[canid] = payload

        feats = {
            'DLC': len(payload),
            'dominant_id_ratio': dominant_id_ratio,
            'id_time_diff': id_time_diff,
            'message_frequency': message_frequency,
            'payload_entropy': payload_entropy,
            'payload_change': payload_change,
            'byte_mean': byte_mean,
            'byte_std': byte_std,
        }
        for i in range(8):
            feats[f'byte{i + 1}'] = payload[i]
        return feats


# ---------------------------------------------------------------------------
# Model + state — loaded once at import time
# ---------------------------------------------------------------------------
model = joblib.load('can_ids_model.pkl')
label_encoder = joblib.load('label_encoder.pkl')
extractor = CANFeatureExtractor()

latest_http_result = {}
main_loop = None


# ---------------------------------------------------------------------------
# Background CAN listener (runs in its own thread, reads vcan0 forever)
# ---------------------------------------------------------------------------
def can_listener():
    global latest_http_result

    bus = can.Bus(channel='vcan0', interface='socketcan')
    print("[can_listener] listening on vcan0...")

    for msg in bus:
        try:
            canid = format(msg.arbitration_id, 'X')
            timestamp = msg.timestamp if msg.timestamp else time.time()
            payload = (list(msg.data) + [0] * 8)[:8]

            feats = extractor.extract(canid, timestamp, payload)
            X = pd.DataFrame([feats])[FEATURE_COLUMNS]
            pred = model.predict(X)[0]
            label = label_encoder.inverse_transform([pred])[0]

            latest_http_result = {
                "canId": f"0x{canid}",
                "timestamp": timestamp,
                "byte1": payload[0], "byte2": payload[1], "byte3": payload[2], "byte4": payload[3],
                "byte5": payload[4], "byte6": payload[5], "byte7": payload[6], "byte8": payload[7],
                "timeDiff": feats['id_time_diff'],
                "label": str(label),
            }
        except Exception as e:
            print(f"[can_listener] error processing frame: {e}")


# ---------------------------------------------------------------------------
# FastAPI app
# ---------------------------------------------------------------------------
app = FastAPI()


@app.on_event("startup")
async def startup_event():
    global main_loop
    main_loop = asyncio.get_running_loop()
    threading.Thread(
        target=can_listener,
        daemon=True
    ).start()
    print("CAN listener started")


@app.get("/latest")
def get_latest():
    return latest_http_result
