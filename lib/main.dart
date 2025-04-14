import 'package:busnow/core/themes/app_theme.dart';
import 'package:busnow/core/l10n/locale_provider.dart';
import 'package:busnow/core/l10n/app_localizations.dart';
import 'package:busnow/presentation/screens/bus_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  runApp(const ProviderScope(child: BusNowApp()));
}

Future<void> _configureApp() async {
  // Check if location services are enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    // Location services are disabled, we'll handle this in the UI
    debugPrint('Location services are disabled');
    return;
  }

  // Check initial permission status (but don't request yet - will do that in UI)
  LocationPermission permission = await Geolocator.checkPermission();
  debugPrint('Initial location permission status: $permission');

  // We'll request permissions in the UI flow rather than on startup
  // This provides a better UX as users understand why we need location
}

class BusNowApp extends ConsumerStatefulWidget {
  const BusNowApp({super.key});

  @override
  ConsumerState<BusNowApp> createState() => _BusNowAppState();
}

class _BusNowAppState extends ConsumerState<BusNowApp> {
  @override
  Widget build(BuildContext context) {
    // Get current locale from provider
    final localeState = ref.watch(localeProvider);
    final isRtl = ref.watch(isRtlProvider);

    return MaterialApp(
      title: 'BusNow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(Brightness.light),
      darkTheme: AppTheme.getTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      // Add localization support
      locale: localeState.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Configure RTL/LTR directionality
      builder: (context, child) {
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: const BusMapScreen(),
    );
  }
}
