import 'package:busnow/core/localization/app_localizations.dart';
import 'package:busnow/core/providers/language_provider.dart';
import 'package:busnow/core/themes/app_theme.dart';
import 'package:busnow/presentation/screens/bus_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

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
  // Check if location services are enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  
  if (!serviceEnabled) {
    // Location services are disabled, we'll handle this in the UI
    print('Location services are disabled');
    return;
  }

  // Check initial permission status (but don't request yet - will do that in UI)
  LocationPermission permission = await Geolocator.checkPermission();
  print('Initial location permission status: $permission');
  
  // We'll request permissions in the UI flow rather than on startup
  // This provides a better UX as users understand why we need location
  
  // Ensure we have required permissions added to AndroidManifest.xml:
  // <uses-permission android:name="android.permission.INTERNET" />
  // <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  // <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

  // For iOS, add to Info.plist:
  // <key>NSLocationWhenInUseUsageDescription</key>
  // <string>This app needs access to location to find nearby bus stops.</string>
  // <key>NSLocationAlwaysUsageDescription</key>
  // <string>This app needs access to location to find nearby bus stops.</string>
}

class BusTrackingApp extends ConsumerWidget {
  const BusTrackingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for changes in language
    final locale = ref.watch(localeProvider);
    final textDirection = ref.watch(textDirectionProvider);

    return MaterialApp(
      title: 'BusNow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(Brightness.light),
      darkTheme: AppTheme.getTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      
      // Set up localization
      locale: locale,
      supportedLocales: const [
        Locale('en'), // English
        Locale('he'), // Hebrew
        Locale('ar'), // Arabic
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Set LTR/RTL text direction
      builder: (context, child) {
        return Directionality(
          textDirection: textDirection,
          child: child!,
        );
      },
      
      home: const BusMapScreen(),
    );
  }
}