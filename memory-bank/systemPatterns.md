# System Patterns: nav_frame

## Architecture Overview

```mermaid
flowchart TD
    subgraph Mobile["Mobile App (Flutter)"]
        App[MainApp] --> State[MainAppState]
        State --> Connection[Frame Connection]
        State --> Display[Display Management]
        State --> Navigation[Navigation System]
        State --> Location[Location Service]
    end

    subgraph Frame["Frame Device (Lua)"]
        Loop[app_loop] --> DataProc[Data Processing]
        DataProc --> DisplayCtrl[Display Controller]
        DataProc --> IMU[IMU/Tap Handler]
        DataProc --> Battery[Battery Monitor]
    end

    Mobile <--> |Bluetooth| Frame
```

## Communication Protocol

### Phone to Frame Messages
```mermaid
flowchart LR
    Phone --> |0x20| Frame[USER_SPRITE]
    Phone --> |0x14| Frame[DATE_MSG]
    Phone --> |0x12| Frame[TEXT_MSG]
    Phone --> |0x10| Frame[CLEAR_MSG]
    Phone --> |0x16| Frame[TAP_SUBS_MSG]
```

### Frame to Phone Messages
```mermaid
flowchart LR
    Frame --> |0x09| Phone[TAP_MSG]
    Frame --> |Battery| Phone[Battery Updates]
```

## Navigation Tracking System

```mermaid
flowchart TD
    subgraph LocationTracking
        LP[Location Polling Service] -->|Every 1s| PH[Position History]
        PH -->|Last 5 positions| RC[Route Calculator]
        RC --> DD[Direction Determinator]
        PH --> BC[Bearing Calculator]
        PH --> SC[Speed Calculator]
    end

    subgraph NavigationState
        CS[Connection State] --> NS[Navigation State]
        NS --> UI[UI Updates]
        NS --> FD[Frame Display]
    end

    subgraph DirectionLogic
        DD -->|Bearing| CA[Compass Analysis]
        CA -->|Turn Instructions| NS
        DD -->|Distance| NI[Next Instruction]
        NI -->|Updates| NS
        BC -->|Current Bearing| CA
        SC -->|Average Speed| NS
    end
```

### Components:
1. **Location Tracking Service**
   - Asynchronous location updates stream
   - Position history management (max 5 positions)
   - 1-second polling interval
   - Two stream types:
     * locationStream: Single position updates
     * historyStream: List of recent positions

2. **Direction Calculator**
   - Bearing calculation between points
   - Average speed computation
   - Relative angle computation
   - Turn instruction generation
   - Uses position history for smoother calculations

3. **Navigation State Management**
   - Route data management
   - Progress tracking
   - Navigation status handling
   - Frame display integration
   - Position history integration

## Core Components

### 1. Mobile Application (Flutter)
- Uses SimpleFrameAppState mixin for lifecycle management
- State machine pattern for connection states:
  - disconnected → initializing → scanning → connecting
  - connected → running → ready
  - stopping → disconnecting

### 2. Frame Device (Lua)
- Main app_loop with error handling
- Message parser system
- Display management
- IMU/tap detection
- Battery monitoring
- Progressive sprite rendering

### 3. Display System
**Mobile Side:**
- Text message formatting
- Sprite/image preparation
- Clear screen control
- State-based UI updates

**Frame Side:**
- Text rendering
- Bitmap display
- Sprite handling
- Progressive rendering
- Palette management

### 4. User Input System
```mermaid
flowchart LR
    FrameIMU[Frame IMU] --> TapDetect[Tap Detection]
    TapDetect --> |0x09| Handler[Mobile Tap Handler]
    Handler --> Single[Single Tap: Time/Battery]
    Handler --> Double[Double Tap: Navigation]
    Handler --> Multi[Multi Tap: Custom]
```

### 5. Location Services System
```mermaid
flowchart TD
    subgraph LocationService
        LS[Location Service] -->|1s interval| CP[Current Position]
        CP --> PH[Position History]
        PH --> HS[History Stream]
        PH --> BC[Bearing Calculator]
        PH --> SC[Speed Calculator]
    end

    subgraph Consumers
        HS --> Navigation[Navigation System]
        BC --> Navigation
        SC --> Navigation
        Navigation --> Display[Display Updates]
    end
```

### 6. Navigation System
- Image processing via OpenCV
- Map interpretation
- Route guidance
- Visual feedback through frame display
- Position history integration for enhanced tracking

## Design Patterns

1. **State Pattern**
   - Mobile: Application state management
   - Frame: Display state management

2. **Observer Pattern**
   - Tap event handling
   - Battery monitoring
   - Bluetooth data monitoring
   - Location tracking streams

3. **Command Pattern**
   - Message passing system
   - Display operations
   - Navigation commands

4. **Queue Pattern**
   - Position history management
   - Limited size queue (5 positions)
   - FIFO operation

5. **Parser Pattern**
   - Message parsing system on frame
   - Data format handling

## Error Handling
- Mobile: Comprehensive logging system
- Frame: pcall error containment
- Graceful degradation
- Connection recovery
- Resource cleanup
- Location service error recovery

## Data Flow
```mermaid
flowchart LR
    Input[User Input] --> State[State Management]
    Location[Location Service] --> History[Position History]
    History --> Process[Processing]
    State --> Process
    Process --> Proto[Protocol Layer]
    Proto --> Frame[Frame Display]
    
    External[External Data] --> Process
    Battery[Battery Status] --> Proto
```

## Security Considerations
- Bluetooth permissions management
- Location permissions handling
- Safe Lua script execution
- Error containment
- Resource cleanup on disconnect
- Progressive data handling
- Position data privacy
