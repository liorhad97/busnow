import 'package:flutter/material.dart';
import 'package:busnow/core/constants/dimensions.dart';
import 'package:busnow/core/localization/app_localizations.dart';

/// Bus stop header with title, count, and refresh button
class BusStopHeader extends StatelessWidget {
  final String title;
  final int busCount;
  final Animation<double> animation;
  final VoidCallback onRefresh;
  final bool isLoading;

  const BusStopHeader({
    Key? key,
    required this.title,
    required this.busCount,
    required this.animation,
    required this.onRefresh,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Apply slide-in animation
        final slideInOffset = (1 - animation.value) * 50;

        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, slideInOffset),
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppDimensions.spacingMedium,
                right: AppDimensions.spacingMedium,
                bottom: AppDimensions.spacingMedium,
              ),
              child: Row(
                children: [
                  // Bus stop title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          busCount == 1
                              ? '1 ${localizations.translate("route")}'
                              : '$busCount ${localizations.translate("route")}s',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Refresh button
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(
                          milliseconds: AppDimensions.animDurationShort,
                        ),
                        child: isLoading
                            ? SizedBox(
                                key: const ValueKey('loading'),
                                width: AppDimensions.iconSizeMedium,
                                height: AppDimensions.iconSizeMedium,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.primary,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.refresh_rounded,
                                key: const ValueKey('refresh'),
                                color: theme.colorScheme.primary,
                              ),
                      ),
                      tooltip: localizations.translate('refresh'),
                      onPressed: isLoading ? null : onRefresh,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
