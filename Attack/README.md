# CAN Bus Attack Simulators

This repository contains two simple Python scripts used to generate CAN Bus attack traffic for evaluating a **Machine Learning-based CAN Intrusion Detection System (IDS)**.

The scripts use the **python-can** library with the **SocketCAN** interface (`vcan0`) and are intended for testing in a virtual CAN environment.

---

# Included Attacks

- DoS (Denial of Service)
- Fuzz Attack

---

# Requirements

- Python 3.10+
- Linux
- SocketCAN
- Virtual CAN interface (`vcan0`)

Install dependencies

```bash
pip install python-can
```

---

# Create Virtual CAN Interface

Load the virtual CAN module

```bash
sudo modprobe vcan
```

Create the interface

```bash
sudo ip link add dev vcan0 type vcan
```

Enable the interface

```bash
sudo ip link set up vcan0
```

Verify

```bash
ip link show vcan0
```

---

# 1. DoS Attack Simulator

## Description

The DoS attack continuously injects CAN frames with a **fixed CAN Identifier (0x00)** and random payloads at the highest possible transmission rate.

The objective is to occupy the CAN bus and delay legitimate ECU communication.

### Characteristics

| Parameter | Value |
|-----------|-------|
| Attack Type | Denial of Service |
| CAN ID | 0x00 |
| Payload | Random (8 Bytes) |
| DLC | 8 |
| Transmission Rate | Maximum possible |
| Frame Type | Standard (11-bit) |

### Workflow

```text
Generate Random Payload
        │
        ▼
Create CAN Frame
        │
        ▼
CAN ID = 0x00
        │
        ▼
Transmit Immediately
        │
        ▼
Repeat Forever
```

### Run

```bash
python3 dos_attack.py
```

---

# 2. Fuzz Attack Simulator

## Description

The Fuzz attack injects CAN frames containing randomized payloads (and optionally randomized CAN IDs depending on implementation).

Its purpose is to test ECU robustness and expose unexpected software behavior.

### Characteristics

| Parameter | Value |
|-----------|-------|
| Attack Type | Fuzz |
| CAN ID | Fixed or Random |
| Payload | Random (8 Bytes) |
| DLC | 8 |
| Frame Type | Standard (11-bit) |

### Workflow

```text
Generate Random CAN Data
        │
        ▼
Create CAN Frame
        │
        ▼
Transmit to CAN Bus
        │
        ▼
Repeat Forever
```

### Run

```bash
python3 fuzz_attack.py
```

---

# Example Output

```text
[+] Starting CAN simulator
[+] Press Ctrl+C to stop

ID=0x00 DATA=[15, 91, 244, 18, 71, 33, 190, 4]
ID=0x00 DATA=[90, 18, 201, 75, 5, 63, 40, 255]
```

Stop the script with

```text
Ctrl + C
```

---

# System Architecture

```text
Python Attack Script
        │
        ▼
python-can
        │
        ▼
SocketCAN
        │
        ▼
vcan0
        │
        ▼
CAN Bus
        │
        ▼
Target ECUs / IDS
```

---

# Attack Comparison

| Feature | DoS Attack | Fuzz Attack |
|----------|------------|-------------|
| Goal | Saturate the CAN bus | Test ECU robustness |
| CAN ID | Usually fixed | Fixed or random |
| Payload | Random | Random |
| Transmission Rate | Very High | High |
| Expected Effect | Bus congestion and delayed messages | Unexpected ECU behavior or software faults |

---

# Use Cases

- CAN Bus security research
- Intrusion Detection System (IDS) evaluation
- Dataset generation
- ECU robustness testing
- Machine learning experiments
- Cybersecurity demonstrations

---

# Warning

These scripts are intended **only for educational and research purposes**.

Run them only on:

- Virtual CAN interfaces (`vcan0`)
- Laboratory testbeds
- Isolated CAN networks

Running these attacks on production vehicles or operational CAN networks may disrupt vehicle communication and compromise safety.

---

# License

Developed as part of a **CAN Bus Intrusion Detection System (IDS)** graduation project.
