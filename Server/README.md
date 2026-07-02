# CAN IDS Live Detection API

A real-time **CAN Bus Intrusion Detection System (IDS)** built with **Python**, **FastAPI**, and **python-can**. The application continuously listens to a SocketCAN interface (`vcan0`), extracts statistical features from incoming CAN frames, classifies each frame using a pre-trained Machine Learning model, and exposes the latest prediction through a REST API for a mobile application.

---

## Features

- 🚗 Real-time CAN Bus monitoring
- 🧠 Machine Learning-based attack detection
- ⚡ FastAPI REST API
- 🔄 Continuous CAN frame processing
- 📊 Rolling feature extraction
- 📱 Mobile application integration
- 🧵 Background threaded CAN listener
- 🛡️ Supports Normal and Attack traffic classification

---

# System Architecture

```text
                CAN Bus (vcan0)
                      │
                      ▼
         python-can Background Listener
                      │
                      ▼
          CAN Feature Extraction Engine
                      │
                      ▼
           Trained Machine Learning Model
                      │
                      ▼
          Latest Prediction (Memory Cache)
                      │
                      ▼
              FastAPI REST API (/latest)
                      │
                      ▼
                Flutter Mobile App
```

---

# Project Structure

```text
.
├── main.py
├── can_ids_model.pkl
├── label_encoder.pkl
├── requirements.txt
└── README.md
```

---

# Requirements

- Python 3.10+
- Linux
- SocketCAN
- Virtual CAN Interface (`vcan0`) or Physical CAN Interface

---




```bash
pip install fastapi uvicorn python-can pandas numpy scikit-learn joblib
```

---

# Create Virtual CAN Interface

Load the Virtual CAN module

```bash
sudo modprobe vcan
```

Create the interface

```bash
sudo ip link add dev vcan0 type vcan
```

Bring it up

```bash
sudo ip link set up vcan0
```

Verify

```bash
ip link show vcan0
```

---

# Running the API

Start the FastAPI server

```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

If everything starts correctly, you should see

```text
CAN listener started
[can_listener] listening on vcan0...
```

---

# REST API

## Get Latest Prediction

### Endpoint

```http
GET /latest
```

### Example Request

```bash
curl http://localhost:8000/latest
```

### Example Response

```json
{
    "canId": "0x123",
    "timestamp": 1721035471.52,
    "byte1": 12,
    "byte2": 45,
    "byte3": 78,
    "byte4": 10,
    "byte5": 0,
    "byte6": 0,
    "byte7": 0,
    "byte8": 0,
    "timeDiff": 0.012,
    "label": "Normal"
}
```

---



# Threaded CAN Listener

A dedicated daemon thread continuously reads CAN frames from the SocketCAN interface.

```python
threading.Thread(
    target=can_listener,
    daemon=True
).start()
```

This design allows the FastAPI server to remain responsive while processing CAN traffic in real time.

---



# Mobile Application Integration

The Flutter mobile application periodically sends

```http
GET /latest
```

The response contains

- CAN ID
- Timestamp
- Payload Bytes
- Time Difference
- Predicted Label

---

# Testing

Generate a CAN frame

```bash
cansend vcan0 123#1122334455667788
```

Monitor traffic

```bash
candump vcan0
```

Retrieve the latest prediction

```bash
curl http://localhost:8000/latest
```

---

# Technologies Used

- Python
- FastAPI
- python-can
- SocketCAN
- NumPy
- Pandas
- Scikit-learn
- Joblib
- Uvicorn

---
