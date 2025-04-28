# Technical Context: nav_frame

## Development Environment

### Core SDK & Framework
- Flutter SDK ^3.6.0
- Dart SDK ^3.6.0

### Dependencies

#### Core Dependencies
```yaml
flutter_blue_plus: ^2.0.0    # Bluetooth LE communication
logging: ^1.3.0             # Logging system
simple_frame_app: ^7.0.0    # Frame device integration
intl: ^0.17.0              # Internationalization
async: ^2.11.0             # Asynchronous programming utilities
geolocator: ^10.0.0        # Location services and tracking
```

#### Image Processing
```yaml
opencv_dart: ^1.3.3        # Computer vision capabilities
image_picker: ^1.1.2       # Image selection
image: ^4.5.2              # Image manipulation
```

#### File System & Permissions
```yaml
path_provider: ^2.1.5      # File system access
permission_handler: ^11.3.1 # Permission management
```

## Location Service Technical Details

### Location Service Features
- Real-time position tracking (1s interval)
- Position history management (max 5 positions)
- Bearing calculation between positions
- Average speed calculation
- Permission handling
- Resource management
- Drift detection threshold calculations
- Route recalculation triggers

### Stream Types
1. **locationStream**
   - Single position updates
   - Real-time current location
   - Type: Stream<Position>

2. **historyStream**
   - List of recent positions (max 5)
   - Enhanced tracking capabilities
   - Type: Stream<List<Position>>
   - Used for drift detection
   - Drift threshold calculations

### Position History
- Queue-based implementation
- FIFO operation
- Maximum size: 5 positions
- Each position includes:
  * Latitude/Longitude
  * Speed
  * Timestamp
  * Accuracy
  * Drift metrics

## Frame Device Technical Specs

### Communication
- Bluetooth Low Energy (BLE)
- Custom message protocol
- Binary data transfer
- Display buffer management

### Frame Hardware Features
- Display capabilities
  - Text rendering
  - Bitmap display
  - Sprite rendering
  - Buffer management
  - Frame sync control
  - Update timing control
- IMU (Inertial Measurement Unit)
  - Tap detection
  - Motion sensing
- Battery monitoring
- Memory constraints (considered in progressive rendering)

### Display System Enhancement
- Buffer management system
- Frame rate control
- Update synchronization
- Screen tearing prevention
- Progressive rendering optimization
- Memory-efficient updates
- Display state validation

### Lua Runtime
- Embedded Lua environment
- Core modules:
  - data.min
  - battery.min
  - code.min
  - image_sprite_block.min
  - plain_text.min
  - display_buffer.min (new)

## Asset Management

### Required Lua Scripts
```
packages/simple_frame_app/lua/
├── battery.min.lua
├── data.min.lua
├── code.min.lua
├── plain_text.min.lua
├── camera.min.lua
├── display_buffer.min.lua
└── image_sprite_block.min.lua
```

### Project Assets
```
assets/
├── frame_app.lua       # Main frame application
└── maps_route_easy.jpg # Navigation map asset
```

## Technical Constraints

### Mobile Platform
1. **Permission Requirements**
   - Bluetooth access
   - Location services (foreground and background)
   - File system access

2. **Performance Considerations**
   - Image processing overhead
   - Bluetooth communication latency
   - Battery impact
   - Location polling frequency impact
   - Position history memory usage
   - Display buffer management overhead
   - Update synchronization timing
   - Drift detection calculations

### Frame Device
1. **Hardware Limitations**
   - Display resolution
   - Memory constraints
   - Battery life
   - Processing power
   - Display update timing
   - Buffer management capabilities

2. **Communication Constraints**
   - BLE bandwidth
   - Message size limits
   - Connection stability
   - Update synchronization
   - Buffer transfer limitations

## Development Tools

### Required
- Visual Studio Code or similar IDE
- Flutter development tools
- Android/iOS development setup
- Bluetooth debugging tools
- Location testing tools
- Display debugging tools
- Frame buffer analyzer

### Optional
- OpenCV development tools
- Lua development environment
- Image processing tools
- GPS simulation tools
- Display timing analyzer
- Buffer management tools

## Testing Requirements

### Mobile App Testing
- Unit tests (flutter_test)
- Integration tests
- Bluetooth communication tests
- Image processing verification
- Location service tests
- Position history management tests
- Drift detection validation
- Display system verification
- Buffer management tests

### Frame Device Testing
- Lua script verification
- Display rendering tests
- Buffer management tests
- Input handling verification
- Battery management tests
- Update timing validation
- Frame synchronization tests

### Location Service Testing
- Position accuracy verification
- History management tests
- Stream behavior verification
- Permission handling tests
- Resource cleanup verification
- Drift detection accuracy
- Recalculation trigger validation

### Display System Testing
- Buffer management validation
- Update timing verification
- Frame synchronization tests
- Memory usage monitoring
- Performance profiling
- Glitch detection
- State validation
