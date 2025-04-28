import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math' as math show pi, sin, cos, sqrt, atan2, min, max;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart' as geo;

class TrafficRouteLine extends StatefulWidget {
  const TrafficRouteLine({Key? key}) : super(key: key);

  // Make state type public
  static TrafficRouteLineState? of(BuildContext context) =>
      context.findAncestorStateOfType<TrafficRouteLineState>();

  @override
  State createState() => TrafficRouteLineState();
}

class NavigationProgress {
  final String nextInstruction;    // Next maneuver instruction
  final String? roadName;          // Next road name if available
  final double distanceToNext;     // Distance to next maneuver in meters
  final List<String> completed;    // List of completed instructions
  final int stepIndex;            // Current step index in route

  NavigationProgress({
    required this.nextInstruction,
    this.roadName,
    required this.distanceToNext,
    required this.completed,
    required this.stepIndex,
  });
}

class TrafficRouteLineState extends State<TrafficRouteLine> {
  late MapboxMap mapboxMap;
  int _currentStepIndex = 0;
  List<String> _completedSteps = [];
  Map<String, dynamic>? _routeResponse; // Store the complete route response
  Map<String, dynamic>? get routeResponse => _routeResponse; // Getter for main.dart
  geo.Position? _currentLocation;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String? _searchError;
  List<Map<String, dynamic>> _searchSuggestions = [];
  Map<String, dynamic>? _selectedDestination;

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final accessToken = dotenv.env['ACCESS_TOKEN'];
      final encodedQuery = Uri.encodeComponent(query);
      final url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/$encodedQuery.json?access_token=$accessToken&types=place,address&limit=5';
      
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchSuggestions = (data['features'] as List)
              .map((feature) => {
                    'name': feature['place_name'],
                    'coordinates': feature['center'],
                  })
              .toList();
        });
      } else {
        setState(() {
          _searchError = 'Failed to load suggestions';
          _searchSuggestions = [];
        });
      }
    } catch (e) {
      setState(() {
        _searchError = 'Error: $e';
        _searchSuggestions = [];
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<NavigationProgress> getNavigationProgress(geo.Position currentPosition) async {
    if (_routeResponse == null || _currentLocation == null) {
      throw Exception('Route or current location not available');
    }

    final route = _routeResponse!;
    final legs = route['legs'] as List;
    List<Map<String, dynamic>> allSteps = [];
    
    // Flatten all steps from all legs into a single list
    for (var leg in legs) {
      final steps = leg['steps'] as List;
      allSteps.addAll(steps.cast<Map<String, dynamic>>());
    }

    // Ensure we don't go out of bounds
    int currentStepIdx = math.min(_currentStepIndex, allSteps.length - 1);
    
    // Get the current step
    final currentStep = allSteps[currentStepIdx];
    
    // First check if we're close to the current maneuver point
    final currentManeuverLocation = (currentStep['maneuver']['location'] as List)
        .map((e) => (e as num).toDouble()).toList();
        
    double distanceToCurrentManeuver = _calculateDistance(
      currentPosition.latitude,
      currentPosition.longitude,
      currentManeuverLocation[1],
      currentManeuverLocation[0]
    );
    
    // If we're within 15 meters of current maneuver and not at the end, move to next step
    if (distanceToCurrentManeuver < 15 && currentStepIdx < allSteps.length - 1) {
      _currentStepIndex = currentStepIdx + 1;
      currentStepIdx = _currentStepIndex;
      
      // Update completed steps
      if (!_completedSteps.contains(currentStep['maneuver']['instruction'])) {
        _completedSteps.add(currentStep['maneuver']['instruction']);
      }
    }
    
    // Get the step we should now be following (either same or advanced)
    final activeStep = allSteps[currentStepIdx];
    
    // Get next step if available (for preview)
    final nextStep = currentStepIdx < allSteps.length - 1 
        ? allSteps[currentStepIdx + 1] 
        : activeStep;

    // Extract next instruction
    String nextInstruction = activeStep['maneuver']['instruction'] as String;

    // Get road name from banner instructions if available
    String? roadName;
    if (activeStep['bannerInstructions'] != null && 
        (activeStep['bannerInstructions'] as List).isNotEmpty) {
      roadName = (activeStep['bannerInstructions'][0]['primary']['text'] as String?) ?? 
                 activeStep['name'] as String?;
    }

    return NavigationProgress(
      nextInstruction: nextInstruction,
      roadName: roadName,
      distanceToNext: distanceToCurrentManeuver,
      completed: List.from(_completedSteps),
      stepIndex: _currentStepIndex,
    );
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    
    // Convert degrees to radians
    double lat1Rad = lat1 * math.pi / 180;
    double lat2Rad = lat2 * math.pi / 180;
    double deltaLat = (lat2 - lat1) * math.pi / 180;
    double deltaLon = (lon2 - lon1) * math.pi / 180;

    // Haversine formula
    double a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
              math.cos(lat1Rad) * math.cos(lat2Rad) *
              math.sin(deltaLon / 2) * math.sin(deltaLon / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c; // Distance in meters
  }

  Future<void> _calculateRoute() async {
    if (_currentLocation == null || _selectedDestination == null) return;

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      _clearRoute();

      // Get and add new route
      final routeData = await _fetchRouteFromAPI();
      await mapboxMap.style.addSource(GeoJsonSource(
        id: "route-source",
        data: routeData,
      ));
      await _addRouteLine();

      // Update camera to show both points
      await mapboxMap.flyTo(
        CameraOptions(
          center: Point.fromJson({
            "coordinates": [
              (_currentLocation!.longitude + _selectedDestination!['coordinates'][0]) / 2,
              (_currentLocation!.latitude + _selectedDestination!['coordinates'][1]) / 2
            ]
          }),
          zoom: 10.0,
          padding: MbxEdgeInsets(left: 50, top: 50, right: 50, bottom: 50)
        ),
        MapAnimationOptions(duration: 2000)
      );
    } catch (e) {
      setState(() {
        _searchError = 'Error calculating route: $e';
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<geo.Position> _getCurrentLocation() async {
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == geo.LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await geo.Geolocator.getCurrentPosition();
  }

  
  // Sample coordinates
  final originCoords = [0.0, 0.0]; // San Francisco [lon, lat]
  final destCoords = [0.0, 0.0];   // Pier 39 [lon, lat]

  _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;
    await mapboxMap.loadStyleURI(MapboxStyles.MAPBOX_STREETS);
    
    // Update camera to user location if available
    if (_currentLocation != null) {
      await mapboxMap.flyTo(
        CameraOptions(
          center: Point.fromJson({
            "coordinates": [_currentLocation!.longitude, _currentLocation!.latitude]
          }),
          zoom: 14.0
        ),
        MapAnimationOptions(duration: 2000)
      );
    }
  }

  _onStyleLoadedCallback(StyleLoadedEventData data) async {
    // Map style loaded and ready
  }

  Future<void> _clearRoute() async {
    try {
      // Try to remove existing route if it exists
      try {
        await mapboxMap.style.removeStyleLayer("route-layer");
        await mapboxMap.style.removeStyleSource("route-source");
      } catch (e) {
        // Ignore errors if layers/sources don't exist
      }
    } catch (e) {
      print('Error clearing route: $e');
    }
  }

  Future<String> _fetchRouteFromAPI() async {
    if (_currentLocation == null || _selectedDestination == null) {
      throw Exception('Current location or destination not set');
    }

    print('Fetching route...');
    final accessToken = dotenv.env['ACCESS_TOKEN'];
    final origin = '${_currentLocation!.longitude},${_currentLocation!.latitude}';
    final destination = '${_selectedDestination!['coordinates'][0]},${_selectedDestination!['coordinates'][1]}';
    final url = 'https://api.mapbox.com/directions/v5/mapbox/driving/$origin;$destination?alternatives=true&banner_instructions=true&geometries=geojson&language=en&overview=full&roundabout_exits=true&steps=true&access_token=$accessToken';
    
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      _routeResponse = jsonResponse['routes'][0]; // Store complete response
      print('Route response stored: ${_routeResponse != null}');
      
      final route = jsonResponse['routes'][0];
      final geometry = route['geometry'];
      
      // Create a GeoJSON feature collection with the route
      final geoJson = {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'properties': {},
            'geometry': geometry
          }
        ]
      };
      
      return json.encode(geoJson);
    } else {
      throw Exception('Failed to fetch route: ${response.statusCode}');
    }
  }

  _addRouteLine() async {
    await mapboxMap.style.addLayer(LineLayer(
      id: "route-layer",
      sourceId: "route-source",
      lineWidth: 3.0,
      lineColor: Colors.blue.value,
      lineJoin: LineJoin.ROUND,
      lineCap: LineCap.ROUND
    ));
  }

  @override
  void initState() {
    super.initState();
    final token = dotenv.env['ACCESS_TOKEN'];
    if (token != null) {
      MapboxOptions.setAccessToken(token);
    }
    _getCurrentLocation().then((position) {
      setState(() {
        _currentLocation = position;
      });
      // Update map camera when location is obtained
      if (mapboxMap != null) {
        mapboxMap.flyTo(
          CameraOptions(
            center: Point.fromJson({
              "coordinates": [position.longitude, position.latitude]
            }),
            zoom: 14.0
          ),
          MapAnimationOptions(duration: 2000)
        );
      }
    }).catchError((error) {
      print('Error getting location: $error');
    });
  }

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void _showSuggestions() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 5,
        width: size.width - 56, // Account for padding
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0.0, 55.0),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 200,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _searchSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _searchSuggestions[index];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDestination = suggestion;
                        _searchController.text = suggestion['name'];
                        _searchSuggestions = [];
                      });
                      _overlayEntry?.remove();
                      _overlayEntry = null;
                    },
                    child: ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(
                        suggestion['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      minLeadingWidth: 20,
                      dense: true,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: CompositedTransformTarget(
                    link: _layerLink,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Enter destination',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        suffixIcon: _isSearching 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2)
                            )
                          : null,
                        errorText: _searchError,
                      ),
                      onChanged: (value) {
                        _searchLocations(value);
                        if (_searchSuggestions.isNotEmpty) {
                          _showSuggestions();
                        } else {
                          _overlayEntry?.remove();
                          _overlayEntry = null;
                        }
                      },
                      onTap: () {
                        if (_searchController.text.isNotEmpty) {
                          _searchLocations(_searchController.text);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _selectedDestination != null ? _calculateRoute : null,
                  child: const Text('Calculate Route'),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: MapWidget(
            key: const ValueKey("mapWidget"),
            styleUri: MapboxStyles.MAPBOX_STREETS,
            cameraOptions: CameraOptions(
              center: Point.fromJson({
                "coordinates": _currentLocation != null 
                    ? [_currentLocation!.longitude, _currentLocation!.latitude]
                    : [0, 0] // Default to SF Airport if location not available
              }),
              zoom: 12.0,
              bearing: 0,
              pitch: 0
            ),
            onMapCreated: _onMapCreated,
            onStyleLoadedListener: _onStyleLoadedCallback,
          ),
        ),
        ],
    );
  }
}
