import 'package:busnow/core/l10n/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// RTL-aware Icon that flips directional icons for RTL
class RtlIcon extends ConsumerWidget {
  final IconData icon;
  final double? size;
  final Color? color;

  const RtlIcon(this.icon, {super.key, this.size, this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRtl = ref.watch(isRtlProvider);

    // Map of icons that should be flipped in RTL
    Map<IconData, IconData> rtlIconMap = {
      Icons.arrow_back: Icons.arrow_forward,
      Icons.arrow_back_ios: Icons.arrow_forward_ios,
      Icons.chevron_left: Icons.chevron_right,
      Icons.last_page: Icons.first_page,
      Icons.keyboard_arrow_left: Icons.keyboard_arrow_right,
      // Add more mappings as needed
    };

    // Check if the icon needs to be flipped
    final IconData displayIcon =
        isRtl && rtlIconMap.containsKey(icon) ? rtlIconMap[icon]! : icon;

    return Icon(displayIcon, size: size, color: color);
  }
}
