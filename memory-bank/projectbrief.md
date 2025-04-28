# Project Brief: nav_frame

## Current Status
- Project in alpha stage
- Core functionality technically working
- Navigation system operational but needs enhancements:
  * Drift detection and correction required
  * Display system experiencing glitches
  * Buffer management needs optimization

## Core Requirements & Goals

### Primary Goal
Develop a navigation application (`nav_frame`) that provides reliable real-time navigation guidance through frame devices.

### Secondary Goals
- Interface with external hardware devices referred to as "frames"
- Implement robust location tracking with position history
- Utilize advanced navigation algorithms based on position history
- Potentially utilize image processing for navigation
- Ensure stable and glitch-free display
- Implement drift detection and correction
- Optimize display buffer management

### Non-Goals
- Complex UI on mobile device (focus is on frame display)
- Social features
- Map editing capabilities
- Offline map storage

## Target Audience
Users of the "frames" hardware who need:
- Real-time navigation guidance
- Simple, clear directional information
- Reliable position tracking
- Battery-efficient operation
- Stable display updates
- Accurate route following

## Key Features

### Navigation System
- Real-time location tracking (1s interval)
- Position history management (last 5 positions)
- Bearing calculation between positions
- Average speed computation
- Route progress tracking
- Turn-by-turn navigation
- Drift detection and correction
- Route recalculation

### Frame Integration
- Bluetooth communication with "frames"
- Clear display of navigation data
- Tap-based interaction system
- Battery status monitoring
- Frame display optimization
- Buffer management
- Update synchronization

### Location Services
- Dual stream system:
  * locationStream for real-time updates
  * historyStream for enhanced tracking
- Permission handling
- Background location support
- Resource-efficient tracking
- Drift detection system
- Route recalculation triggers

### Additional Features
- Image processing capabilities (map interpretation, visual cues)
- Frame interaction via Lua scripting
- Progressive rendering for complex visuals
- Battery optimization strategies
- Display buffer management
- Frame rate control

## Success Metrics

### Technical Metrics
- Location tracking accuracy within 10 meters
- Update frequency of 1 second maintained
- Battery drain < 10% per hour of use
- Frame connection stability > 99%
- Position history maintenance of 5 positions
- Display update stability > 99%
- Drift correction response < 2 seconds
- Route recalculation time < 3 seconds

### User Experience Metrics
- Navigation instruction clarity
- Response time < 500ms for user interactions
- Smooth transitions between instructions
- Reliable bearing calculations
- Accurate speed estimations
- Stable display output
- Effective drift correction
- Clear visual feedback

## Assumptions
- "Frames" are Bluetooth-enabled hardware devices
- The `simple_frame_app` package provides the necessary interface
- Users have consistent GPS signal access
- Mobile devices have sufficient processing power
- Users grant necessary permissions
- Frame devices support buffer management
- Display timing control is possible

## Constraints

### Technical Constraints
- Flutter/Dart development environment required
- Specific hardware ("frames") dependency
- Maximum 5 positions in history queue
- 1-second minimum location update interval
- Limited frame display capabilities
- Display buffer size limitations
- Update timing constraints

### Permission Requirements
- Bluetooth access
- Location services (foreground and background)
- File system access
- Camera access (for image processing features)

### Resource Constraints
- Battery optimization requirements
- Memory usage limitations
- Processing power constraints
- Bluetooth bandwidth limitations
- Display buffer size
- Update frequency limitations

## Development Priorities

1. **Display System Optimization**
   - Fix frame glitches
   - Implement buffer management
   - Add update synchronization
   - Optimize render timing
   - Prevent screen artifacts

2. **Navigation Enhancement**
   - Implement drift detection
   - Add route recalculation
   - Optimize position history usage
   - Improve update efficiency
   - Enhanced accuracy

3. **System Optimization**
   - Battery efficiency
   - Processing efficiency
   - Memory management
   - Error handling
   - Performance tuning

4. **Testing & Validation**
   - Display system verification
   - Navigation accuracy testing
   - Drift correction validation
   - Performance profiling
   - User experience testing
