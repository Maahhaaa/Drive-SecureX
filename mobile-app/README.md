# DriveSecureX — Mobile App 📱🔒

The mobile application component of **DriveSecureX (DSX)** — a real-time CAN bus intrusion detection system. This Flutter app connects to the backend server, continuously monitors live CAN traffic passed through the ML detection pipeline, and instantly alerts the driver of any detected cyber threat.

## ✨ Features

- **Dashboard** — live CAN traffic monitoring and system health at a glance
- **Alerts screen** — real-time threat notifications with attack details
- **Take Action** button — triggers an automated block response (`POST /block_attack`) the moment a threat is detected
- **Automated response** — immediate blocking action on confirmed attacks, without waiting for user input

## 🛠️ Tech Stack

- **Framework:** Flutter (Dart)
- **Connectivity:** Wi-Fi / Bluetooth to backend REST API
- **Key components:** `CANService` (data/service layer), polling engine with buffer management, Dashboard screen, Alerts screen

## 📶 Network Setup

The app connects to the backend server over **Wi-Fi or Bluetooth**, using a **hostname** instead of a fixed IP, configured inside `CANService`.

> ⚠️ **Important:** The hostname is currently static and must be **manually updated** whenever the server changes (e.g. the server getting a new address).

To update it:
1. Open `lib/core/services/can_service.dart`
2. Locate the hostname/URI used to reach the server (e.g. `Uri.parse('http://<hostname>:8000/latest')`)
3. Replace `<hostname>` with your server's current hostname or IP address
4. Rebuild the app

## 🚀 Getting Started

### Prerequisites
- Flutter SDK
- A running instance of the DriveSecureX backend server, reachable on the same network

### Setup
```bash
flutter pub get
flutter run
```

Make sure your device/emulator and the backend server are on the same network (Wi-Fi or paired via Bluetooth), and that the hostname in `can_service.dart` points to the correct server address before running.

### Build a release APK
```bash
flutter build apk --release
```
The output APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

## 📂 Project Structure (key files)

```
lib/
├── core/
│   ├── services/
│   │   └── can_service.dart      # Connects to backend, polling, hostname config
│   └── theme/
├── features/
│   ├── alrets/                   # Alerts screen
│   └── connecting/                # Connection/onboarding flow
```

## 🎯 Limitations

- Hostname configuration is static and must be updated manually when the server(host) changes
- Requires the mobile device and server to be reachable on the same local network
