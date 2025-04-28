# nav_frame

![Status](https://img.shields.io/badge/status-alpha-orange)
![Flutter](https://img.shields.io/badge/flutter-%5E3.6.0-blue)
![Dart](https://img.shields.io/badge/dart-%5E3.6.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

A Flutter-based navigation application that provides real-time guidance through specialized frame devices, utilizing advanced position tracking and intelligent route guidance.

## 🚧 Project Status

Currently in **alpha stage**:
- ✅ Core navigation functionality working
- ✅ Basic frame device integration
- ✅ Location tracking system operational
- 🔄 Display system improvements in progress
- 🔄 Drift detection implementation planned
- 📈 Continuous optimization ongoing

## 🌟 Features

### Navigation System
- Real-time location tracking (1s interval)
- Position history management (5 positions)
- Advanced bearing calculations
- Turn-by-turn navigation
- Route progress tracking
- Speed-aware guidance

### Frame Integration
- Bluetooth LE communication
- Tap-based interaction system
- Battery monitoring
- Progressive rendering
- Display optimization

### Location Services
- Dual stream tracking system
- Background location support
- Permission management
- Resource-efficient operation

## 🔧 Technical Stack

- **Framework**: Flutter ^3.6.0
- **Language**: Dart ^3.6.0
- **Key Dependencies**:
  ```yaml
  flutter_blue_plus: ^2.0.0    # Bluetooth LE
  simple_frame_app: ^7.0.0    # Frame integration
  geolocator: ^10.0.0        # Location services
  opencv_dart: ^1.3.3        # Image processing
  ```

## 📱 Requirements

### Mobile Platform
- Flutter SDK ^3.6.0
- Dart SDK ^3.6.0
- Android Studio / Xcode
- Bluetooth LE support
- Location services
- Camera (optional)

### Frame Device
- Compatible frame hardware
- Bluetooth LE capability
- Display support
- IMU for tap detection

## 🚀 Getting Started

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/nav_frame.git
   cd nav_frame
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Environment**
   - Enable location services
   - Grant Bluetooth permissions
   - Allow background location access

4. **Run the Application**
   ```bash
   flutter run
   ```

## 📖 Documentation

### Project Structure
```
lib/
├── main.dart                 # Application entry
├── widgets/                  # UI components
│   └── get_and_display_route.dart
├── services/                 # Core services
├── models/                   # Data models
└── utils/                   # Utilities

assets/
├── frame_app.lua           # Frame application
└── sf_airport_route.geojson
```

### Key Components
- **Location Service**: Manages position tracking and history
- **Frame Communication**: Handles device interaction
- **Navigation System**: Processes route guidance
- **Display Management**: Controls frame display

## 🛠 Development

### Current Focus
1. **Display System Enhancement**
   - Fixing frame glitches
   - Implementing buffer management
   - Optimizing update timing

2. **Navigation Improvements**
   - Adding drift detection
   - Implementing route recalculation
   - Enhancing position tracking

### Running Tests
```bash
flutter test
```

### Building Release Version
```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow Flutter's style guide
- Use meaningful variable names
- Add comments for complex logic
- Include tests for new features

## 📝 Known Issues

1. Display glitches during certain operations
2. Missing drift detection system
3. Display update timing needs optimization
4. Screen artifacts in specific scenarios

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support or queries:
- Open an issue
- Check existing documentation
- Contact development team

## 🙏 Acknowledgments

- Frame device hardware team
- Flutter community
- Contributing developers
- Testing team

