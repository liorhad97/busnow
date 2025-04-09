import 'package:busnow/core/config/language_config.dart';
import 'package:busnow/core/localization/app_localizations.dart';
import 'package:busnow/core/providers/app_providers.dart';
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
  // Initialize language configuration
  await LanguageConfig.instance.initializeLanguage();
  
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
    // Listen for language changes to rebuild the app
    final appSettings = ref.watch(appSettingsProvider);
    
    final languageConfig = LanguageConfig.instance;
    final locale = languageConfig.locale;
    final isLtr = appSettings.isLtr;

    return MaterialApp(
      title: 'BusNow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(Brightness.light),
      darkTheme: AppTheme.getTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      locale: locale,
      
      // Set text direction based on language
      builder: (context, child) {
        return Directionality(
          textDirection: isLtr ? TextDirection.ltr : TextDirection.rtl,
          child: child!,
        );
      },
      
      // Configure localization
      supportedLocales: [
        const Locale('en'), // English
        const Locale('he'), // Hebrew
        const Locale('ar'), // Arabic
      ],
      
      // Localization delegates
      localizationsDelegates: const [
        // App-specific localizations
        AppLocalizations.delegate,
        
        // Built-in localization of basic text for Material widgets
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Returns a locale which will be used by the app
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        // If the locale of the device is not supported, use the first one
        // (English in this case)
        return supportedLocales.first;
      },
      
      home: const BusMapScreen(),
    );
  }
}
