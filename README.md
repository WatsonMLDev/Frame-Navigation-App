# Navigation Frame App (nav_frame)

[![Status](https://img.shields.io/badge/status-Proof--of--Concept-orange)](https://shields.io/)
[![Flutter Version](https://img.shields.io/badge/Flutter-%5E3.6.0-blue)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-%5E3.6.0-blue)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE) <!-- Assuming MIT, add LICENSE file if missing -->

**Display real-time navigation instructions from Mapbox on a companion "Frame" wearable device via Bluetooth LE.**

This Flutter application connects to a specialized "Frame" hardware device using Bluetooth Low Energy (BLE). It allows users to search for a destination, calculates a driving route using the Mapbox Directions API, displays the route on an in-app map, and sends basic navigation instructions (like the next maneuver) to the connected Frame device based on the user's current location.

## 🚧 Project Status: Proof-of-Concept

This project demonstrates the core concept but requires significant improvements for real-world usability.

**Implemented Features:**
*   ✅ Mapbox map integration for route visualization (`mapbox_maps_flutter`).
*   ✅ Destination search using Mapbox Geocoding API.
*   ✅ Route calculation using Mapbox Directions API.
*   ✅ Displaying the calculated route line on the map.
*   ✅ Basic BLE communication with a Frame device (`flutter_blue_plus`, `simple_frame_app`).
*   ✅ Sending text data (time, battery, next step instruction) to the Frame (`frame_msg`).
*   ✅ Receiving tap events from the Frame to trigger actions (show time/battery, show next instruction).
*   ✅ Basic location tracking using `geolocator`.
*   ✅ Rudimentary navigation progress: Checks distance to the *current* route step's maneuver point and advances if within a threshold (15m).
*   ✅ Loading Mapbox Access Token via `.env` file.
*   ✅ Basic permission handling for Location and Bluetooth.

**Key Areas Needing Work:**
*   🔴 **Navigation Logic:** Extremely basic. Does not handle off-route scenarios, route snapping, or complex maneuvers effectively. No turn-by-turn guidance beyond the next immediate step text.
*   🔴 **Frame Display Stability:** Potential for display glitches, timing issues, or artifacts on the Frame device (as hinted in original README/memory bank, though not explicitly confirmed in current code). No sophisticated buffer management evident.
*   🔴 **Error Handling:** Minimal error handling for API calls, BLE communication, and location services.
*   🔴 **Testing:** No automated tests included in the repository.
*   🔴 **Optimization:** Location polling and BLE communication could be optimized for battery life.

## 🛠️ How It Works

1.  **Setup:** The app loads a Mapbox Access Token from a `.env` file.
2.  **Connection:** It scans for and connects to a compatible Frame device via BLE using `flutter_blue_plus` and `simple_frame_app`.
3.  **Destination:** The user searches for a destination using the search bar (powered by Mapbox Geocoding API).
4.  **Routing:** Upon selecting a destination and clicking "Calculate Route", the app fetches a driving route from the Mapbox Directions API using the current location (`geolocator`) and the destination coordinates.
5.  **Map Display:** The calculated route is drawn as a line on the integrated `MapboxMap` widget.
6.  **Location Tracking:** The app periodically (every 3 seconds in the current loop) gets the user's current location.
7.  **Basic Progress:** It calculates the distance to the maneuver point of the *current* step in the Mapbox route.
    *   If the distance is close (< 15m), it advances the internal step counter.
    *   If the distance is within display range (< 30m), the text instruction for the current step can be sent to the Frame.
8.  **Frame Interaction:**
    *   **Taps:** The user can tap the Frame device.
        *   Single Tap: Sends current time and phone battery level to the Frame.
        *   Double Tap: Sends the text instruction for the *current* navigation step to the Frame.
    *   **Display:** The Frame device runs `frame_app.lua` to receive text messages (via `frame_msg` codes 0x12, 0x14) and display them.
    *   **Battery:** The Frame periodically sends its battery level back (handled by `simple_frame_app`).

## 💻 Tech Stack

*   **Framework:** Flutter (`^3.6.0` or higher based on `pubspec.lock`)
*   **Language:** Dart (`^3.6.0` or higher based on `pubspec.lock`)
*   **Mapping & Navigation:**
    *   `mapbox_maps_flutter`: Map display and route line rendering.
    *   `http`: For Mapbox API requests (Geocoding, Directions).
    *   `geolocator`: Device location tracking.
*   **Bluetooth LE:**
    *   `flutter_blue_plus`: BLE scanning, connection, communication.
    *   `simple_frame_app`: Higher-level abstraction for Frame interaction.
    *   `frame_msg`: Defines message structures for Frame communication.
*   **Utilities:**
    *   `flutter_dotenv`: Loading environment variables (like Mapbox token).
    *   `permission_handler`: Requesting runtime permissions.
    *   `logging`: Application logging.
    *   `intl`: Time formatting.
*   **Frame Device:** Lua (for `frame_app.lua`)

*(Note: `opencv_dart`, `image_picker`, `image` are listed in the `pubspec.yaml` but do not appear to be actively used in the provided `main.dart` or `get_and_display_route.dart` code. Image processing features are currently **not** implemented.)*

## 🚀 Getting Started

### Prerequisites

*   Flutter SDK installed (version specified in `pubspec.yaml` or higher).
*   A configured development environment for Flutter (Android Studio/Xcode).
*   A compatible "Frame" hardware device.
*   A Mapbox Access Token.

### Installation & Setup

1.  **Clone the Repository:**
    ```bash
    git clone <repository-url>
    cd watsonmldev-frame-navigation-app
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Configure Mapbox Token:**
    *   Create a file named `.env` in the project root directory (`watsonmldev-frame-navigation-app/.env`).
    *   Add your Mapbox Access Token to the `.env` file:
        ```dotenv
        ACCESS_TOKEN=YOUR_MAPBOX_ACCESS_TOKEN_HERE
        ```
    *   **Important:** Ensure the `.env` file is listed in your `.gitignore` file to avoid committing your token. The `pubspec.yaml` correctly includes it in assets.

4.  **Permissions:** Ensure your device grants the necessary permissions when prompted:
    *   Location Access (While Using the App / Always - depending on platform requirements)
    *   Bluetooth Access / Nearby Devices

5.  **Run the Application:**
    *   Ensure your Frame device is powered on and discoverable.
    *   Connect your phone via USB or use wireless debugging.
    *   Run the app:
        ```bash
        flutter run
        ```
    *   The app should automatically attempt to scan and connect to the Frame device upon startup.

## ❗ Current Limitations & Known Issues

*   **Basic Navigation Logic:** Only considers distance to the *current* step's maneuver point. Does not account for being off-route, road geometry, or provide true turn-by-turn guidance. Easily confused if the user deviates.
*   **No Off-Route Detection/Recalculation:** If you go off the calculated route, the app will not detect it or calculate a new route automatically.
*   **No Route Snapping:** The user's location is not snapped to the route line, which can lead to inaccurate distance calculations.
*   **Frame Display Issues:** Potential for display glitches, timing issues, or artifacts on the Frame device hardware due to simple communication protocol and lack of explicit buffer management/synchronization in the provided code.
*   **Hardcoded Thresholds:** Uses fixed distances (15m for step advance, 30m for display) which may not be suitable for all situations (e.g., walking vs. driving, GPS accuracy).
*   **Unused Asset:** `assets/sf_airport_route.geojson` is present but not used by the application code.
*   **Missing Image Processing:** Dependencies exist, but no image processing features are implemented.
*   **Limited Error Handling:** Does not robustly handle API errors, BLE disconnects, or location service failures.
*   **No Tests:** Lacks automated tests.

## 🎯 Future Work / To-Do

*   **Implement Robust Navigation Logic:**
    *   Use a proper navigation SDK or algorithm for turn-by-turn guidance.
    *   Implement route snapping.
    *   Add off-route detection.
    *   Implement automatic route recalculation.
    *   Incorporate bearing and speed into guidance.
*   **Improve Frame Display:**
    *   Investigate and fix any display glitches or artifacts on the Frame hardware.
    *   Implement more robust communication, potentially including acknowledgments or buffer management if the hardware/firmware supports it.
    *   Optimize data sent to the frame (e.g., send deltas or use more compact formats).
*   **Enhance Error Handling:** Add comprehensive error handling for network requests, BLE operations, and location services.
*   **Add Testing:** Implement unit, widget, and integration tests.
*   **Optimize Performance:**
    *   Profile and optimize battery consumption (location polling, BLE).
    *   Optimize UI performance.
*   **Refine UI/UX:** Improve the mobile app interface and interaction flow.
*   **Clean Up:** Remove unused assets (`sf_airport_route.geojson`) and potentially unused dependencies (`opencv_dart`, `image_picker`, `image`) if they are not planned for near-future use.
*   **Documentation:** Add comments to the code and potentially more detailed documentation.

## 🤝 Contributing

Contributions are welcome! If you'd like to contribute, please follow these general steps:

1.  Fork the repository.
2.  Create a new branch (`git checkout -b feature/your-feature-name` or `bugfix/issue-description`).
3.  Make your changes.
4.  Ensure your changes adhere to the existing code style (consider running `dart format .`).
5.  Write tests for your changes (if applicable).
6.  Commit your changes (`git commit -m 'Add some feature'`).
7.  Push to the branch (`git push origin feature/your-feature-name`).
8.  Open a Pull Request against the `main` branch of the original repository.

Please provide a clear description of your changes in the Pull Request.

**Code Owners:** See the `CODEOWNERS` file. (`* WatsonMLDev`)

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details (if one exists, otherwise specify the license).

## 🙏 Acknowledgments

*   The Flutter and Dart teams.
*   The developers of the libraries used (Mapbox, flutter_blue_plus, etc.).
*   The Frame hardware team (if applicable).
