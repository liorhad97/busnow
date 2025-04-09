import 'package:flutter/material.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/core/localization/app_localizations.dart';

/// Header for the bottom sheet displaying bus stop information
///
/// Shows the bus stop name, bus count, and a refresh button
class BusStopHeader extends StatelessWidget {
  final Animation<double> animation;
  final String title;
  final int busCount;
  final VoidCallback onRefresh;
  final bool isLoading;

  const BusStopHeader({
    Key? key,
    required this.animation,
    required this.title,
    required this.busCount,
    required this.onRefresh,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    // Use plural form based on bus count
    final String scheduleText = busCount == 1 
        ? localizations.translate('schedule') 
        : localizations.translate('schedule'); // For languages with plural forms, you could have different keys

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium,
        vertical: AppDimensions.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bus stop name with animated opacity
          FadeTransition(
            opacity: animation,
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: AppDimensions.spacingExtraSmall),

          // Bus count and refresh button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bus count with animated slide
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                )),
                child: Text(
                  '$busCount $scheduleText',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),

              // Refresh button with animation
              FadeTransition(
                opacity: animation,
                child: IconButton(
                  onPressed: isLoading ? null : onRefresh,
                  icon: isLoading
                      ? SizedBox(
                          width: AppDimensions.iconSizeSmall,
                          height: AppDimensions.iconSizeSmall,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.refresh_rounded,
                          color: theme.colorScheme.primary,
                          size: AppDimensions.iconSizeSmall,
                        ),
                  tooltip: localizations.translate('refresh'),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: AppDimensions.iconSizeMedium,
                    height: AppDimensions.iconSizeMedium,
                  ),
                  splashRadius: AppDimensions.iconSizeSmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
