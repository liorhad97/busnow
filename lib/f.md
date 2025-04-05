// Project Structure Overview
lib/
├── main.dart (App entry point)
├── presentation/
│   ├── screens/
│   │   └── bus_map_screen.dart
│   ├── widgets/
│   │   ├── bus_stop_marker.dart
│   │   ├── bus_schedule_list.dart
│   │   ├── bus_schedule_item.dart
│   │   └── animated_loading_indicator.dart
│   └── blocs/
│       └── bus_schedule_bloc.dart
├── domain/
│   ├── models/
│   │   ├── bus_stop.dart
│   │   └── bus_schedule.dart
│   ├── repositories/
│   │   └── bus_schedule_repository.dart
│   └── usecases/
│       └── get_bus_schedules_for_stop.dart
└── data/
    ├── repositories/
    │   └── bus_schedule_repository_impl.dart
    └── datasources/
        ├── bus_schedule_local_data_source.dart
        └── bus_schedule_remote_data_source.dart


// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'presentation/screens/bus_map_screen.dart';
import 'presentation/blocs/bus_schedule_bloc.dart';
import 'domain/repositories/bus_schedule_repository.dart';
import 'data/repositories/bus_schedule_repository_impl.dart';
import 'data/datasources/bus_schedule_local_data_source.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const BusTrackingApp());
}

class BusTrackingApp extends StatelessWidget {
  const BusTrackingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BusScheduleRepository>(
          create: (_) => BusScheduleRepositoryImpl(
            localDataSource: BusScheduleLocalDataSource(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => BusScheduleBloc(
            repository: context.read<BusScheduleRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Bus Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF26A69A),
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF26A69A),
            secondary: const Color(0xFFD4E157),
            background: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black87,
          ),
          scaffoldBackgroundColor: Colors.white,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme.copyWith(
                  headlineMedium: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  bodyLarge: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black87,
                  ),
                  bodyMedium: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.black87,
                  ),
                ),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        darkTheme: ThemeData(
          primaryColor: const Color(0xFF26A69A),
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF26A69A),
            secondary: const Color(0xFFD4E157),
            background: const Color(0xFF212121),
            surface: const Color(0xFF303030),
            onSurface: Colors.white70,
          ),
          scaffoldBackgroundColor: const Color(0xFF212121),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme.copyWith(
                  headlineMedium: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  bodyLarge: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.white70,
                  ),
                  bodyMedium: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.white70,
                  ),
                ),
          ),
          cardTheme: CardTheme(
            elevation: 4,
            color: const Color(0xFF303030),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const BusMapScreen(),
      ),
    );
  }
}

// Domain Layer - Models

// domain/models/bus_stop.dart
class BusStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  const BusStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

// domain/models/bus_schedule.dart
class BusSchedule {
  final String id;
  final String busNumber;
  final String busStopId;
  final int arrivalTimeInMinutes;
  final String destination;

  const BusSchedule({
    required this.id,
    required this.busNumber,
    required this.busStopId,
    required this.arrivalTimeInMinutes,
    required this.destination,
  });
}

// Domain Layer - Repositories

// domain/repositories/bus_schedule_repository.dart
import '../models/bus_stop.dart';
import '../models/bus_schedule.dart';

abstract class BusScheduleRepository {
  Future<List<BusStop>> getBusStops();
  Future<List<BusSchedule>> getBusSchedulesForStop(String busStopId);
}

// Domain Layer - Use Cases

// domain/usecases/get_bus_schedules_for_stop.dart
import '../models/bus_schedule.dart';
import '../repositories/bus_schedule_repository.dart';

class GetBusSchedulesForStop {
  final BusScheduleRepository repository;

  GetBusSchedulesForStop(this.repository);

  Future<List<BusSchedule>> execute(String busStopId) async {
    return await repository.getBusSchedulesForStop(busStopId);
  }
}

// Data Layer - Repositories

// data/repositories/bus_schedule_repository_impl.dart
import '../../domain/models/bus_stop.dart';
import '../../domain/models/bus_schedule.dart';
import '../../domain/repositories/bus_schedule_repository.dart';
import '../datasources/bus_schedule_local_data_source.dart';

class BusScheduleRepositoryImpl implements BusScheduleRepository {
  final BusScheduleLocalDataSource localDataSource;

  BusScheduleRepositoryImpl({required this.localDataSource});

  @override
  Future<List<BusStop>> getBusStops() async {
    return await localDataSource.getBusStops();
  }

  @override
  Future<List<BusSchedule>> getBusSchedulesForStop(String busStopId) async {
    return await localDataSource.getBusSchedulesForStop(busStopId);
  }
}

// Data Layer - Data Sources

// data/datasources/bus_schedule_local_data_source.dart
import '../../domain/models/bus_stop.dart';
import '../../domain/models/bus_schedule.dart';
import 'dart:math';

class BusScheduleLocalDataSource {
  // Mock data for bus stops
  final List<BusStop> _busStops = [
    const BusStop(
      id: 'stop1',
      name: 'Central Station',
      latitude: 37.7749,
      longitude: -122.4194,
    ),
    const BusStop(
      id: 'stop2',
      name: 'Market Street',
      latitude: 37.7899,
      longitude: -122.4014,
    ),
    const BusStop(
      id: 'stop3',
      name: 'Union Square',
      latitude: 37.7879,
      longitude: -122.4074,
    ),
    const BusStop(
      id: 'stop4',
      name: 'Fisherman\'s Wharf',
      latitude: 37.8100,
      longitude: -122.4104,
    ),
    const BusStop(
      id: 'stop5',
      name: 'Chinatown',
      latitude: 37.7941,
      longitude: -122.4078,
    ),
  ];

  // Generate random bus schedules for a given stop
  List<BusSchedule> _generateBusSchedules(String busStopId) {
    final random = Random();
    final busNumbers = ['2', '7', '14', '21', '30', '45', '38R'];
    final destinations = [
      'Downtown', 'City Center', 'Airport', 'Mall', 
      'University', 'Beach', 'Financial District'
    ];

    // Generate 3-8 bus schedules for the stop
    final schedulesCount = random.nextInt(6) + 3;
    
    return List.generate(schedulesCount, (index) {
      final busNumber = busNumbers[random.nextInt(busNumbers.length)];
      final destination = destinations[random.nextInt(destinations.length)];
      // Arrival time between 1 and 30 minutes
      final arrivalTime = random.nextInt(30) + 1;
      
      return BusSchedule(
        id: 'schedule_${busStopId}_$index',
        busNumber: busNumber,
        busStopId: busStopId,
        arrivalTimeInMinutes: arrivalTime,
        destination: destination,
      );
    });
  }

  Future<List<BusStop>> getBusStops() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _busStops;
  }

  Future<List<BusSchedule>> getBusSchedulesForStop(String busStopId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));
    return _generateBusSchedules(busStopId);
  }
}

// Presentation Layer - BLoC/State Management

// presentation/blocs/bus_schedule_bloc.dart
import 'package:flutter/material.dart';
import '../../domain/models/bus_stop.dart';
import '../../domain/models/bus_schedule.dart';
import '../../domain/repositories/bus_schedule_repository.dart';

enum BusScheduleState { initial, loading, loaded, error }

class BusScheduleBloc extends ChangeNotifier {
  final BusScheduleRepository repository;

  BusScheduleBloc({required this.repository}) {
    loadBusStops();
  }

  BusScheduleState _state = BusScheduleState.initial;
  BusScheduleState get state => _state;

  List<BusStop> _busStops = [];
  List<BusStop> get busStops => _busStops;

  BusStop? _selectedBusStop;
  BusStop? get selectedBusStop => _selectedBusStop;

  List<BusSchedule> _busSchedules = [];
  List<BusSchedule> get busSchedules => _busSchedules;

  bool _isBottomSheetOpen = false;
  bool get isBottomSheetOpen => _isBottomSheetOpen;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadBusStops() async {
    _state = BusScheduleState.loading;
    notifyListeners();

    try {
      _busStops = await repository.getBusStops();
      _state = BusScheduleState.loaded;
    } catch (e) {
      _state = BusScheduleState.error;
      _errorMessage = 'Failed to load bus stops: ${e.toString()}';
    }
    
    notifyListeners();
  }

  Future<void> selectBusStop(BusStop busStop) async {
    _selectedBusStop = busStop;
    _isBottomSheetOpen = true;
    notifyListeners();

    await loadBusSchedulesForStop(busStop.id);
  }

  Future<void> loadBusSchedulesForStop(String busStopId) async {
    _state = BusScheduleState.loading;
    notifyListeners();

    try {
      _busSchedules = await repository.getBusSchedulesForStop(busStopId);
      
      // Sort by arrival time
      _busSchedules.sort((a, b) => 
        a.arrivalTimeInMinutes.compareTo(b.arrivalTimeInMinutes));
      
      _state = BusScheduleState.loaded;
    } catch (e) {
      _state = BusScheduleState.error;
      _errorMessage = 'Failed to load bus schedules: ${e.toString()}';
    }
    
    notifyListeners();
  }

  void closeBottomSheet() {
    _isBottomSheetOpen = false;
    notifyListeners();
  }

  // Get earliest arrival time per bus number
  Map<String, int> getEarliestArrivalTimes() {
    Map<String, int> earliestTimes = {};
    
    for (var schedule in _busSchedules) {
      if (!earliestTimes.containsKey(schedule.busNumber) || 
          earliestTimes[schedule.busNumber]! > schedule.arrivalTimeInMinutes) {
        earliestTimes[schedule.busNumber] = schedule.arrivalTimeInMinutes;
      }
    }
    
    return earliestTimes;
  }
}

// Presentation Layer - Screens

// presentation/screens/bus_map_screen.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../blocs/bus_schedule_bloc.dart';
import '../widgets/bus_stop_marker.dart';
import '../widgets/bus_schedule_list.dart';
import '../widgets/animated_loading_indicator.dart';
import '../../domain/models/bus_stop.dart';

class BusMapScreen extends StatefulWidget {
  const BusMapScreen({Key? key}) : super(key: key);

  @override
  State<BusMapScreen> createState() => _BusMapScreenState();
}

class _BusMapScreenState extends State<BusMapScreen> with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  Map<String, Marker> _markers = {};
  late AnimationController _mapFadeController;
  late AnimationController _markerAnimController;
  
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _mapFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _markerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
      reverseDuration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _mapFadeController.dispose();
    _markerAnimController.dispose();
    super.dispose();
  }

  Future<void> _createMarkers(BuildContext context, List<BusStop> busStops) async {
    final Map<String, Marker> markers = {};
    
    for (var busStop in busStops) {
      final markerId = MarkerId(busStop.id);
      
      // Custom marker widget
      final markerIcon = await BusStopMarkerWidget(
        busStopName: busStop.name,
        animationController: _markerAnimController,
      ).toBitmapDescriptor();
      
      markers[busStop.id] = Marker(
        markerId: markerId,
        position: LatLng(busStop.latitude, busStop.longitude),
        icon: markerIcon,
        onTap: () {
          HapticFeedback.lightImpact();
          final bloc = context.read<BusScheduleBloc>();
          bloc.selectBusStop(busStop);
          _animateToStop(busStop);
          _mapFadeController.forward();
        },
      );
    }
    
    setState(() {
      _markers = markers;
    });
  }
  
  Future<void> _animateToStop(BusStop busStop) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(busStop.latitude, busStop.longitude),
          zoom: 16.0,
          tilt: 45.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busScheduleBloc = Provider.of<BusScheduleBloc>(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Listen for bus stops and create markers
    if (busScheduleBloc.state == BusScheduleState.loaded && 
        _markers.isEmpty && 
        busScheduleBloc.busStops.isNotEmpty) {
      _createMarkers(context, busScheduleBloc.busStops);
    }
    
    return Scaffold(
      body: Stack(
        children: [
          // Map as hero area (top 60% of screen)
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _initialPosition,
              markers: Set<Marker>.of(_markers.values),
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationEnabled: true,
              compassEnabled: true,
              tiltGesturesEnabled: true,
              rotateGesturesEnabled: true,
              mapToolbarEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                
                // Set map style based on theme
                controller.setMapStyle(isDarkMode ? 
                  _darkMapStyle : _lightMapStyle);
              },
            ),
          ),
          
          // Bottom sheet overlay gradient
          AnimatedBuilder(
            animation: _mapFadeController,
            builder: (context, child) {
              return Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  ignoring: true,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.1 * _mapFadeController.value),
                          Colors.black.withOpacity(0.3 * _mapFadeController.value),
                        ],
                        stops: const [0.6, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Bottom Sheet
          AnimatedBuilder(
            animation: busScheduleBloc,
            builder: (context, _) {
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                left: 0,
                right: 0,
                bottom: busScheduleBloc.isBottomSheetOpen ? 0 : -MediaQuery.of(context).size.height * 0.6,
                height: MediaQuery.of(context).size.height * 0.6,
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity! > 500) {
                      busScheduleBloc.closeBottomSheet();
                      _mapFadeController.reverse();
                      HapticFeedback.mediumImpact();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Pull handle indicator
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(top: 12, bottom: 8),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            
                            // Bus stop name and info
                            if (busScheduleBloc.selectedBusStop != null)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        busScheduleBloc.selectedBusStop!.name,
                                        style: theme.textTheme.headlineMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // Refresh button
                                    BusRefreshButton(
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        if (busScheduleBloc.selectedBusStop != null) {
                                          busScheduleBloc.loadBusSchedulesForStop(
                                            busScheduleBloc.selectedBusStop!.id
                                          );
                                        }
                                      },
                                      isLoading: busScheduleBloc.state == BusScheduleState.loading,
                                    ),
                                  ],
                                ),
                              ),
                            
                            // Bus schedule list
                            Expanded(
                              child: busScheduleBloc.state == BusScheduleState.loading
                                  ? Center(child: AnimatedLoadingIndicator())
                                  : busScheduleBloc.busSchedules.isEmpty
                                      ? _buildEmptyState(theme)
                                      : BusScheduleList(
                                          busSchedules: busScheduleBloc.busSchedules,
                                          earliestTimes: busScheduleBloc.getEarliestArrivalTimes(),
                                        ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // My Location Button
          Positioned(
            right: 16,
            bottom: busScheduleBloc.isBottomSheetOpen
                ? MediaQuery.of(context).size.height * 0.6 + 16
                : 32,
            child: FloatingActionButton(
              onPressed: () async {
                HapticFeedback.selectionClick();
                final GoogleMapController controller = await _controller.future;
                controller.animateCamera(
                  CameraUpdate.newCameraPosition(_initialPosition),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_bus_outlined,
            size: 60,
            color: Color(0xFF26A69A),
          ),
          const SizedBox(height: 16),
          Text(
            "No buses yet—check back soon!",
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  // Map styles for light and dark mode
  static const String _lightMapStyle = '''
  [
    {
      "featureType": "poi",
      "elementType": "labels.icon",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    }
  ]
  ''';
  
  static const String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "administrative.country",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#9e9e9e"
        }
      ]
    }
  ]
  ''';
}

class BusRefreshButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const BusRefreshButton({
    Key? key,
    required this.onPressed,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<BusRefreshButton> createState() => _BusRefreshButtonState();
}

class _BusRefreshButtonState extends State<BusRefreshButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BusRefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: IconButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        icon: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * 3.1415926535,
              child: Icon(
                Icons.refresh_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        ),
        splashRadius: 24,
        tooltip: 'Refresh',
      ),
    );
  }
}

// Presentation Layer - Widgets

// presentation/widgets/bus_stop_marker.dart
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusStopMarkerWidget extends StatelessWidget {
  final String busStopName;
  final AnimationController animationController;

  const BusStopMarkerWidget({
    Key? key,
    required this.busStopName,
    required this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final double pulseValue = animationController.value;
        
        return Container(
          width: 60,
          height: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20 + (pulseValue * 4),
                height: 20 + (pulseValue * 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF26A69A),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF26A69A).withOpacity(0.3 + (pulseValue * 0.2)),
                      blurRadius: 8 + (pulseValue * 8),
                      spreadRadius: 2 + (pulseValue * 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_bus,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<BitmapDescriptor> toBitmapDescriptor() async {
    // Render widget to image
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    
    // Need to use a fixed size widget for rendering
    const Size size = Size(60, 60);
    build(null).build(
      AllowCreationOfChildWidgets(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Center(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF26A69A),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF26A69A).withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_bus,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ),
      ),
    );
    
    // Convert to image
    final ui.Image image = await recorder.endRecording().toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    
    // Convert to byte data
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    
    if (byteData == null) {
      throw Exception('Failed to render marker');
    }
    
    // Create bitmap descriptor
    return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
  }
}

// Helper class for rendering widgets
class AllowCreationOfChildWidgets extends StatelessWidget {
  final Widget child;
  
  const AllowCreationOfChildWidgets({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) => child;
}

// presentation/widgets/bus_schedule_list.dart
import 'package:flutter/material.dart';
import '../../domain/models/bus_schedule.dart';
import 'bus_schedule_item.dart';

class BusScheduleList extends StatelessWidget {
  final List<BusSchedule> busSchedules;
  final Map<String, int> earliestTimes;

  const BusScheduleList({
    Key? key,
    required this.busSchedules,
    required this.earliestTimes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      physics: const BouncingScrollPhysics(),
      itemCount: busSchedules.length,
      itemBuilder: (context, index) {
        final schedule = busSchedules[index];
        final isEarliest = earliestTimes[schedule.busNumber] == schedule.arrivalTimeInMinutes;
        
        // Add staggered animation for items
        return AnimatedBuilder(
          animation: AlwaysStoppedAnimation(1.0 - (index * 0.1).clamp(0.0, 1.0)),
          builder: (context, child) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 400 + (index * 50)),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BusScheduleItem(
                  schedule: schedule,
                  isEarliest: isEarliest,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// presentation/widgets/bus_schedule_item.dart
import 'package:flutter/material.dart';
import '../../domain/models/bus_schedule.dart';

class BusScheduleItem extends StatefulWidget {
  final BusSchedule schedule;
  final bool isEarliest;

  const BusScheduleItem({
    Key? key,
    required this.schedule,
    required this.isEarliest,
  }) : super(key: key);

  @override
  State<BusScheduleItem> createState() => _BusScheduleItemState();
}

class _BusScheduleItemState extends State<BusScheduleItem> 
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isEarliest) {
      _blinkController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BusScheduleItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEarliest && !oldWidget.isEarliest) {
      _blinkController.repeat(reverse: true);
    } else if (!widget.isEarliest && oldWidget.isEarliest) {
      _blinkController.stop();
      _blinkController.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Bus number circle
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.15),
                ),
                child: Center(
                  child: Text(
                    widget.schedule.busNumber,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Destination and arrival info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.schedule.destination,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Arriving in',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrival time
              AnimatedBuilder(
                animation: _blinkController,
                builder: (context, child) {
                  final bgColor = widget.isEarliest
                      ? isDarkMode
                          ? Color.lerp(
                              const Color(0xFF1B5E20).withOpacity(0.5),
                              const Color(0xFF2E7D32).withOpacity(0.7),
                              _opacityAnimation.value,
                            )
                          : Color.lerp(
                              const Color(0xFFE8F5E9),
                              const Color(0xFFC8E6C9),
                              _opacityAnimation.value,
                            )
                      : Colors.transparent;
                      
                  final textColor = widget.isEarliest
                      ? isDarkMode
                          ? const Color(0xFFA5D6A7)
                          : const Color(0xFF2E7D32)
                      : theme.colorScheme.onSurface;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${widget.schedule.arrivalTimeInMinutes} min',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// presentation/widgets/animated_loading_indicator.dart
import 'package:flutter/material.dart';

class AnimatedLoadingIndicator extends StatefulWidget {
  const AnimatedLoadingIndicator({Key? key}) : super(key: key);

  @override
  State<AnimatedLoadingIndicator> createState() => _AnimatedLoadingIndicatorState();
}

class _AnimatedLoadingIndicatorState extends State<AnimatedLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final position = _animation.value;
        final theme = Theme.of(context);
        
        return Container(
          width: 200,
          height: 100,
          child: CustomPaint(
            painter: BusAnimationPainter(
              position: position,
              color: theme.colorScheme.primary,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  'Loading schedules...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BusAnimationPainter extends CustomPainter {
  final double position;
  final Color color;

  BusAnimationPainter({
    required this.position,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.2,
      size.width,
      size.height * 0.4,
    );
    
    // Draw the path as a guide line (optional)
    final guidePaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, guidePaint);
    
    // Calculate the position along the path
    final PathMetrics metrics = path.computeMetrics();
    final PathMetric pathMetric = metrics.first;
    final double length = pathMetric.length;
    final double distance = length * position;
    final Tangent? tangent = pathMetric.getTangentForOffset(distance);
    
    if (tangent != null) {
      final busPosition = tangent.position;
      
      // Draw the bus
      final busPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      // Rotate canvas to follow path tangent
      canvas.save();
      canvas.translate(busPosition.dx, busPosition.dy);
      canvas.rotate(tangent.angle);
      
      // Draw bus (simplified rectangle with rounded corners)
      final busRect = Rect.fromCenter(
        center: Offset.zero,
        width: 20,
        height: 10,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(busRect, const Radius.circular(3)),
        busPaint,
      );
      
      // Draw wheels
      final wheelPaint = Paint()
        ..color = Colors.black.withOpacity(0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(-5, 5), 2, wheelPaint);
      canvas.drawCircle(Offset(5, 5), 2, wheelPaint);
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(BusAnimationPainter oldDelegate) {
    return position != oldDelegate.position || color != oldDelegate.color;
  }
}

// pubspec.yaml (for reference)

name: bus_tracker
description: A Flutter application for tracking bus stops and schedules.

environment:
  sdk: ">=2.18.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.3.0
  provider: ^6.0.5
  google_fonts: ^4.0.4
  flutter_svg: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.1
