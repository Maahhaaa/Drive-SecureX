# DriveSecureX (DSX) 

**Real-time Machine Learning-based Intrusion Detection System for Vehicle CAN Bus Networks**

DriveSecureX is a full-stack cybersecurity system that detects and responds to cyberattacks on the vehicle Controller Area Network (CAN) bus in real time. Since the CAN protocol was designed without built-in encryption or authentication, it remains highly vulnerable to attacks — DSX addresses this gap end-to-end, from traffic simulation to a live mobile alert system.

Graduation project — Electrical Engineering Department (Computer and Systems Section), Faculty of Engineering, Aswan University, July 2026. Developed at the Computer and Artificial Intelligence Research Center (CAIR).

---

## 📖 Overview

Using the Instrument Cluster Simulator (ICSim), DSX injects and captures realistic **Denial of Service (DoS)** and **Fuzzing** attacks alongside normal CAN traffic to build a labeled dataset. This data is used to train a machine learning model that classifies traffic as normal or malicious. The model is served through a REST API and consumed by a Flutter mobile app that continuously monitors live CAN traffic, alerts the driver of detected threats, and can trigger an automated block response.

## ⚙️ System Pipeline

```
ICSim (CAN Simulator) → Preprocessing & Feature Engineering →
XGBoost Classifier → REST API Backend → Flutter Mobile App
```

## 📊 Key Results

| Metric | Result |
|---|---|
| Classification accuracy (ICSim dataset) | ~99.8% (XGBoost) |
| Cross-vehicle generalization (CAN-MIRGU real dataset) | 93% |
| Detection latency | ~0.2s for 90,000 messages |

## 📂 Repository Structure

```
Drive-SecureX/
├── ml-model/     # CAN traffic preprocessing, feature engineering, and XGBoost model training
├── server/       # REST API backend serving detection results to the mobile app
└── mobile-app/   # Flutter app for live monitoring, alerts, and automated response
```

Each component has its own README with setup and usage details:
- [`ml-model/README.md`](./ml-model/README.md)
- [`server/README.md`](./server/README.md)
- [`mobile-app/README.md`](./mobile-app/README.md)

## 🚀 Quick Start

1. Set up and run the **ML model** / detection pipeline — see [`ml-model/README.md`](./ml-model/README.md)
2. Start the **backend server** — see [`server/README.md`](./server/README.md)
3. Run the **mobile app** and point it at the server — see [`mobile-app/README.md`](./mobile-app/README.md)

## 🎯 Limitations

- Currently validated in a simulated environment (ICSim); real-vehicle deployment is a next step
- The mobile app's server hostname is static and must be updated manually if the server's network changes (see [`mobile-app/README.md`](./mobile-app/README.md))

## 🔮 Future Work

- Deployment on Raspberry Pi for real-vehicle implementation
- Dynamic network/hostname discovery for the mobile app
- Expanded attack coverage (message injection, replay, spoofing)

## 👥 Team

**Prepared by:** Aya Abdelwahab, Al-zahraa Fathi, Esraa Abdelmonem, Noha Nour El-Din, Maha Mamdouh, Youssef Gamal

**Supervised by:** Dr. Ghada Abozaid, Dr. Samia Heshmat, Eng. Reda Badry, Eng. Rowan Omar
