import 'package:flutter/material.dart';
import 'package:busnow/presentation/widgets/settings/settings_dialog.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 8,  // Will be automatically adjusted for RTL
      child: Material(
        color: Colors.white,
        elevation: 4,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _showSettingsDialog(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.settings,
              color: Colors.black87,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }
}