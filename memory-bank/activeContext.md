# Active Context: nav_frame

## Current Development Focus

### Primary Areas
1. **Navigation Tracking System** (CURRENT FOCUS)
   - Location polling system implementation completed
   - Position history tracking implemented (max 5 positions)
   - Real-time direction calculation
   - Route progress tracking with TomTom integration
   - Route snapping functionality implemented
   - Progress visualization added to UI and frame display
   - Based on successful simulate_nav.py and map_vis.py implementations

2. **Frame Communication**
   - Basic Bluetooth connectivity established
   - Message protocol implemented
   - Tap detection and handling working

2. **Display Management**
   - Text rendering functional
   - Basic sprite/image support implemented
   - Screen clearing and updates working

3. **Navigation Features**
   - Initial image processing setup complete
   - Map asset (maps_route_easy.jpg) available
   - Route guidance in development

## Active Decisions

### Architecture
- Implementing position history tracking with max 5 positions
- Using historyStream for enhanced location tracking capabilities
- Implementing real-time location polling service with 1-second interval
- Using bearing calculation system from simulate_nav.py prototype
- Using TomTom API for route calculation and road snapping
- Route progress tracking with nearest point calculation
- Progress visualization in UI and on frame display
- Using SimpleFrameAppState mixin for lifecycle management
- Implementing state machine pattern for app states

### Location Service Design
- Uses broadcast StreamControllers for both current location and history
- Maintains a queue of up to 5 recent positions
- Provides current bearing calculations between last two positions
- Calculates average speed from position history
- Implements proper cleanup and disposal of resources

### User Interface
- Gesture-based interaction through taps
- Simple, clear display of information
- Progressive rendering for complex visuals

### Technical
- Using OpenCV for image processing
- Implementing custom message protocol
- Managing battery updates every 120 seconds

## Current Challenges

### Under Investigation
1. Navigation Tracking Implementation
   - Location polling optimization for battery life
   - Compass integration and error handling
   - Real-time direction calculation accuracy
   - Efficient route progress tracking
   - Implementation of historyStream for enhanced position tracking

2. Route Progress Management
   - Route snapping accuracy and performance
   - Progress calculation optimization
   - Navigation instruction timing
   - Real-time updates efficiency

3. Display Management
   - Navigation progress visualization
   - Route display optimization
   - Instruction clarity on frame
   - Update timing for progress changes

## Next Steps

### Immediate
1. Test and refine route progress tracking
   - Verify progress calculation accuracy
   - Test road snapping functionality
   - Validate navigation instructions
   - Ensure proper frame display updates

### Short Term
1. Optimize Navigation Tracking
   - Fine-tune history tracking parameters
   - Improve bearing calculations
   - Enhance route progress tracking
   - Implement advanced navigation features using position history

2. Optimize display system
   - Refine progressive rendering
   - Improve sprite handling
   - Add complex visual feedback

3. Enhance user interaction
   - Expand tap gesture capabilities
   - Add more navigation controls
   - Improve feedback mechanisms

### Medium Term
1. Add advanced navigation features
2. Optimize battery usage
3. Enhance error handling
4. Improve user feedback

## Active Considerations

### Performance
- Battery impact of continuous processing
- Bluetooth communication efficiency
- Image processing overhead
- Memory usage of position history tracking

### User Experience
- Tap gesture responsiveness
- Display clarity and timing
- Navigation feedback clarity
- Enhanced navigation accuracy with position history

### Technical Debt
- Need comprehensive error handling
- Documentation improvements needed
- Test coverage expansion required
- Position history edge cases need testing
