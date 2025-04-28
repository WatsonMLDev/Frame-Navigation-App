# Project Brief: nav_frame

## Core Requirements & Goals

- **Primary Goal:** Develop a navigation application (`nav_frame`) that provides reliable real-time navigation guidance through frame devices.
- **Secondary Goals:**
    - Interface with external hardware devices referred to as "frames"
    - Implement robust location tracking with position history
    - Utilize advanced navigation algorithms based on position history
    - Potentially utilize image processing for navigation
- **Non-Goals:** 
    - Complex UI on mobile device (focus is on frame display)
    - Social features
    - Map editing capabilities
    - Offline map storage

## Target Audience

- Users of the "frames" hardware who need:
  - Real-time navigation guidance
  - Simple, clear directional information
  - Reliable position tracking
  - Battery-efficient operation

## Key Features

### Navigation System
- Real-time location tracking (1s interval)
- Position history management (last 5 positions)
- Bearing calculation between positions
- Average speed computation
- Route progress tracking
- Turn-by-turn navigation

### Frame Integration
- Bluetooth communication with "frames"
- Clear display of navigation data
- Tap-based interaction system
- Battery status monitoring
- Frame display optimization

### Location Services
- Dual stream system:
  * locationStream for real-time updates
  * historyStream for enhanced tracking
- Permission handling
- Background location support
- Resource-efficient tracking

### Additional Features
- Image processing capabilities (map interpretation, visual cues)
- Frame interaction via Lua scripting
- Progressive rendering for complex visuals
- Battery optimization strategies

## Success Metrics

### Technical Metrics
- Location tracking accuracy within 10 meters
- Update frequency of 1 second maintained
- Battery drain < 10% per hour of use
- Frame connection stability > 99%
- Position history maintenance of 5 positions

### User Experience Metrics
- Navigation instruction clarity
- Response time < 500ms for user interactions
- Smooth transitions between instructions
- Reliable bearing calculations
- Accurate speed estimations

## Assumptions

- "Frames" are Bluetooth-enabled hardware devices
- The `simple_frame_app` package provides the necessary interface
- Users have consistent GPS signal access
- Mobile devices have sufficient processing power
- Users grant necessary permissions

## Constraints

### Technical Constraints
- Flutter/Dart development environment required
- Specific hardware ("frames") dependency
- Maximum 5 positions in history queue
- 1-second minimum location update interval
- Limited frame display capabilities

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

## Development Priorities

1. **Core Navigation**
   - Location tracking system
   - Position history management
   - Direction calculation
   - Route guidance

2. **Frame Integration**
   - Display system
   - User interaction
   - Battery management
   - Connection stability

3. **Optimization**
   - Battery efficiency
   - Processing efficiency
   - Memory management
   - Error handling
