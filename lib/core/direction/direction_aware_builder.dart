import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:busnow/core/providers/app_providers.dart';

/// A widget that builds differently based on text direction (LTR or RTL)
class DirectionAwareBuilder extends ConsumerWidget {
  final Widget Function(BuildContext context, bool isLtr) builder;

  const DirectionAwareBuilder({
    required this.builder,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider);
    final isLtr = appSettings.isLtr;

    return builder(context, isLtr);
  }
}

/// Extension on BuildContext to easily get directional values
extension DirectionalContext on BuildContext {
  bool get isLtr {
    final directionality = Directionality.of(this);
    return directionality == TextDirection.ltr;
  }
  
  /// Get start edge based on text direction
  EdgeInsets edgeInsetsOnly({
    double start = 0.0,
    double end = 0.0,
    double top = 0.0,
    double bottom = 0.0,
  }) {
    if (isLtr) {
      return EdgeInsets.only(
        left: start,
        right: end,
        top: top,
        bottom: bottom,
      );
    } else {
      return EdgeInsets.only(
        left: end,
        right: start,
        top: top,
        bottom: bottom,
      );
    }
  }
  
  /// Get directional alignment
  Alignment get startAlignment => isLtr ? Alignment.centerLeft : Alignment.centerRight;
  Alignment get endAlignment => isLtr ? Alignment.centerRight : Alignment.centerLeft;
  
  /// Get directional border radius
  BorderRadius borderRadiusDirectional({
    double topStart = 0.0,
    double topEnd = 0.0,
    double bottomStart = 0.0,
    double bottomEnd = 0.0,
  }) {
    if (isLtr) {
      return BorderRadius.only(
        topLeft: Radius.circular(topStart),
        topRight: Radius.circular(topEnd),
        bottomLeft: Radius.circular(bottomStart),
        bottomRight: Radius.circular(bottomEnd),
      );
    } else {
      return BorderRadius.only(
        topLeft: Radius.circular(topEnd),
        topRight: Radius.circular(topStart),
        bottomLeft: Radius.circular(bottomEnd),
        bottomRight: Radius.circular(bottomStart),
      );
    }
  }
}
