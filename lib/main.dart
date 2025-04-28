import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For environment variables
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:simple_frame_app/simple_frame_app.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:frame_msg/tx/plain_text.dart';
import 'package:frame_msg/rx/tap.dart';
import 'package:frame_msg/tx/code.dart';
import 'package:simple_frame_app/text_utils.dart';

// Import the MapBox route widget
import 'widgets/get_and_display_route.dart';

// Global key to access TrafficRouteLine state
final navigationKey = GlobalKey<TrafficRouteLineState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env"); // Load environment variables
    final accessToken = dotenv.env['ACCESS_TOKEN'];
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('ACCESS_TOKEN not found in .env file');
    }
    MapboxOptions.setAccessToken(accessToken);
    runApp(const MainApp());
  } catch (e) {
    debugPrint('Error loading environment variables: $e');
    rethrow;
  }
}

final _log = Logger("MainApp");

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

/// SimpleFrameAppState mixin helps to manage the lifecycle of the Frame connection outside of this file
class MainAppState extends State<MainApp> with SimpleFrameAppState {
  MainAppState() {
    Logger.root.level = Level.FINE;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  // ---------------------------------------------------------------------------

  bool _isRunning = false;
  bool _lockedTaps = false;
  bool _run = true;
  bool _isCalculating = false;
  bool _processed = false;  // Initialize to -1 to ensure first instruction is shown
  StreamSubscription<int>? _tapSubs;

  @override
  void initState() {
    super.initState();
    _isRunning = true;
    // kick off the connection to Frame and start the app if possible
    tryScanAndConnectAndStart(andRun: true);
  }

  @override
  Future<void> run() async {
    setState(() {
      currentState = ApplicationState.running;
    });

    // Clear display initially
    await frame!.sendMessage(0x12, TxPlainText(text: "").pack());

    // Set up tap handling
    _tapSubs?.cancel();
    _tapSubs = RxTap().attach(frame!.dataResponse)
      .listen((taps) async {
        _log.fine(() => 'taps: $taps');
        onTap(taps);
      });

    // Enable tap subscription
    await frame!.sendMessage(0x10, TxCode(value: 1).pack());

    // Navigation monitoring loop with proper control
    while (_isRunning) {
      if (_run && !_lockedTaps) {
        try {
          if (!_isCalculating) {
            _isCalculating = true;
            
            geo.Position? currentPosition = await geo.Geolocator.getCurrentPosition();
            
            if (navigationKey.currentState != null) {
              NavigationProgress progress = await navigationKey.currentState!.getNavigationProgress(currentPosition);
              
              // Within range - check for step change or first instruction
              if (progress.distanceToNext < 30) {
                if (_processed == false) {
                  _processed = true;
                  String nav_text = '${progress.nextInstruction}\nD: ${progress.distanceToNext.toString()}';
                  
                  // Clear screen first
                  await frame!.sendMessage(0x12, TxPlainText(text: "  ").pack());
                  await Future.delayed(const Duration(seconds: 1));
                  
                  // Update with new text
                  List<String> progressText = TextUtils.wrapText(nav_text, 500, 4);
                  await frame!.sendMessage(0x12, TxPlainText(text: progressText.join("\n")).pack());
                  _log.info('Updated navigation display: ${progress.nextInstruction}');
                }
              }
              // Out of range - clear if we were showing something
              else{
                _processed = false;
                // await frame!.sendMessage(0x12, TxPlainText(text: "  ").pack());
                _log.info('Cleared navigation display - out of range');
              }
            }
            
            _isCalculating = false;
          }
        } catch (e) {
          _isCalculating = false;
          _log.warning('Error in navigation monitoring: $e');
        }
      }
      await Future.delayed(const Duration(seconds: 3));
    }
  }
  
  Future<void> cancel() async {
    setState(() {
      currentState = ApplicationState.canceling;
    });

    // let Frame know to stop sending taps
    final code = TxCode(value: 0);
    await frame!.sendMessage(0x10, code.pack());

    // clear the display
    final plainText = TxPlainText(text: ' ');
    await frame!.sendMessage(0x22, plainText.pack());

    setState(() {
      currentState = ApplicationState.ready;
    });
  }

  Future<void> onTap(int taps) async {
    if (_lockedTaps) return;
    
    try {
      _lockedTaps = true;
      
      switch (taps) {
        case 1:
          // Clear current display first
          await frame!.sendMessage(0x12, TxPlainText(text: "  ").pack());
          await Future.delayed(const Duration(milliseconds: 100));

          await frame!.sendMessage(0x14, TxPlainText(text: "  ").pack());
          await Future.delayed(const Duration(milliseconds: 100));
          
          final currentTime = DateFormat('hh:mm a').format(DateTime.now());
          await frame!.sendMessage(0x14, TxPlainText(text: '$currentTime~$batteryLevel%').pack());
          _log.info('Displayed time and battery: $currentTime, $batteryLevel%');
          
          await Future.delayed(const Duration(seconds: 3));
          await frame!.sendMessage(0x14, TxPlainText(text: "  ").pack());
          break;
          
        case 2:
          final routeData = navigationKey.currentState?.routeResponse;
          _log.info('Showing navigation instructions. Route data: ${routeData != null ? 'available' : 'not available'}');
          
          if (routeData != null && routeData['legs'] != null) {
            final steps = (routeData['legs'][0]['steps'] as List);
            if (steps.isNotEmpty) {
              // Clear current display first
              await frame!.sendMessage(0x12, TxPlainText(text: "  ").pack());
              await Future.delayed(const Duration(milliseconds: 100));
              
              geo.Position? currentPosition = await geo.Geolocator.getCurrentPosition();
              NavigationProgress progress = await navigationKey.currentState!.getNavigationProgress(currentPosition);
              
              List<String> progressText = TextUtils.wrapText(progress.nextInstruction, 500, 4);
              await frame!.sendMessage(0x12, TxPlainText(text: progressText.join("\n")).pack());
              
              await Future.delayed(const Duration(seconds: 3));
              await frame!.sendMessage(0x12, TxPlainText(text: "  ").pack());
            }
          }
          break;
          
        default:
          break;
      }
    } catch (e) {
      _log.severe('Error handling tap: $e');
    } finally {
      _lockedTaps = false;
    }
  }

  @override
  void dispose() {
    _isRunning = false;  // Stop the navigation loop
    _tapSubs?.cancel();  // Cancel tap subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Frame App',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Navigation Frame App'),
          actions: [getBatteryWidget()],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Add the MapBox route widget with expanded to fill available space
              Expanded(
                child: TrafficRouteLine(key: navigationKey),
              ),
            ],
          ),
        ),
        floatingActionButton: getFloatingActionButtonWidget(const Icon(Icons.camera_alt), const Icon(Icons.cancel)),
        persistentFooterButtons: getFooterButtonsWidget(),
      ),
    );
  }
}
