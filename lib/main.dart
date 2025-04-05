import 'package:busnow/core/themes/app_theme.dart';
import 'package:busnow/presentation/screens/bus_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Ensure we have appropriate permissions configured
  _configureApp();

  runApp(const ProviderScope(child: BusTrackingApp()));
}

Future<void> _configureApp() async {
  // Ensure we add required permissions to AndroidManifest.xml:
  // <uses-permission android:name="android.permission.INTERNET" />
  // <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  // <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

  // For iOS, add to Info.plist:
  // <key>NSLocationWhenInUseUsageDescription</key>
  // <string>This app needs access to location to find nearby bus stops.</string>

  // Preload any assets needed for splash screen
}

class BusTrackingApp extends StatelessWidget {
  const BusTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BusNow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: ThemeMode.system,
      home: const BusMapScreen(),
    );
  }
}
