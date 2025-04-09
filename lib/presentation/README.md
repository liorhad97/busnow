# BusNow Presentation Layer

## Overview

This folder contains the presentation layer of the BusNow application, which has been refactored following SOLID principles and clean architecture patterns. The presentation layer is responsible for all UI components, rendering, animations, and user interactions.

## Structure

```
presentation/
├── screens/              # Main screens of the app
├── widgets/              # Reusable widgets (organized by category)
│   ├── bus/              # Bus-related widgets
│   ├── map/              # Map-related widgets
│   ├── bottom_sheets/    # Bottom sheet implementations
│   ├── animations/       # Animation widgets and components
│   ├── common/           # Common UI elements (buttons, indicators, etc.)
│   └── decorations/      # Visual decorations, painters, gradients
├── providers/            # State management providers
├── utils/                # Presentation-layer utilities
│   ├── animations/       # Animation utilities
│   ├── map/              # Map-related utilities
│   └── ui/               # UI helper functions
└── mixins/               # Reusable widget behavior mixins
```

## Key Components

### Screens

- `BusMapScreen`: The main screen displaying the map, bus stops, and schedule details.

### Widgets

#### Bus Components

- `BusNumberCircle`: Circular display of bus numbers with gradient styling
- `BusScheduleCard`: Card displaying bus schedule details
- `BusScheduleItem`: Individual schedule item in a list
- `BusStatusIndicator`: Status indicator showing bus timing information
- `BlinkingTimeDisplay`: Animation for highlighting imminent arrivals
- `BusTimeInfo`: Component showing time information for buses
- `BusActionButtons`: Action buttons for tracking and alerts
- `RouteVisualization`: Visual representation of bus routes

#### Map Components

- `MapCenterCursor`: A cursor shown at map center
- `PulsingCursorDot`: Animated dot for the cursor
- `MapControlsPanel`: Panel of map control buttons
- `MapControlButton`: Individual map control button
- `MapOverlayGradient`: Gradient overlay for map contrast

#### Bottom Sheets

- `BottomSheetHandle`: Pull handle for bottom sheets
- `EnhancedBottomSheet`: Main bottom sheet for bus information

#### Animations

- `AnimatedLoadingIndicator`: Loading spinner with multiple animation types
- `InlineLoadingIndicator`: Compact loading indicator

#### Decorations

- `GradientOverlayPainter`: Painter for creating gradient overlays
- `LoadingIndicatorPainter`: Painter for drawing loading indicators

### Utilities

- `AnimationTransitions`: Common animation patterns
- `BusStatusCalculator`: Utility for calculating bus statuses

## Design Principles

1. **Single Responsibility**: Each component has a clear, focused purpose
2. **Reusability**: Components are designed to be reused across the application
3. **Testability**: UI logic is separated from business logic for easier testing
4. **Maintainability**: Smaller files with clear documentation make maintenance easier
5. **Performance**: Components are optimized to minimize unnecessary rebuilds

## Usage Guidelines

1. **Add new screens** to the `screens/` directory
2. **Add new widgets** to the appropriate subdirectory in `widgets/`
3. **Keep files small** - aim for less than 300 lines per file
4. **Document components** with clear descriptions of their purpose and features
5. **Extract repeated patterns** into utility classes or mixins

## Animation Guidelines

1. Use the `AnimationTransitions` utility for standard animations
2. Keep animation durations consistent using the constants in `AppDimensions`
3. Use staggered animations for lists and sequential elements
4. Ensure animations work well in both light and dark themes