import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:busnow/core/l10n/app_localizations.dart';
import 'package:busnow/core/providers/locale_provider.dart';
import 'package:busnow/presentation/screens/bus_map_screen.dart';
import 'package:busnow/presentation/widgets/language_selector.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  static const String _firstRunKey = 'first_run_completed';
  bool _isFirstRun = true;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!_isFirstRun) {
          _navigateToHome();
        }
      }
    });
    
    _checkFirstRun();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _checkFirstRun() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final firstRunCompleted = prefs.getBool(_firstRunKey) ?? false;
      
      setState(() {
        _isFirstRun = !firstRunCompleted;
      });
      
      if (!_isFirstRun) {
        _animationController.forward();
      }
    } catch (e) {
      debugPrint('Error checking first run: $e');
    }
  }
  
  Future<void> _completeFirstRun() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setBool(_firstRunKey, true);
      
      if (mounted) {
        _navigateToHome();
      }
    } catch (e) {
      debugPrint('Error saving first run: $e');
    }
  }
  
  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BusMapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo/animation
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        'assets/animations/lottie/bus_lottie.json',
                        width: mediaQuery.size.width * 0.7,
                        controller: _animationController,
                        onLoaded: (composition) {
                          _animationController.duration = composition.duration;
                          if (!_isFirstRun) {
                            _animationController.forward();
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.appTitle,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.welcomeMessage,
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              // First run - language selection
              if (_isFirstRun)
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.chooseYourLanguage,
                          style: theme.textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        const LanguageSelector(),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            _completeFirstRun();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(l10n.continue_),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
