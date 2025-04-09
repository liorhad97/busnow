import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:busnow/core/l10n/app_localizations.dart';
import 'package:busnow/presentation/providers/bus_providers.dart';

/// A provider that delivers localized messages to the BusScheduleNotifier
class LocalizedBusMessages {
  final BuildContext context;
  
  LocalizedBusMessages(this.context);
  
  // Get the current localizations
  AppLocalizations get _l10n => AppLocalizations.of(context);
  
  // Error messages
  String get loadBusStopsError => _l10n.loadBusStopsError;
  String get loadBusSchedulesError => _l10n.loadBusSchedulesError;
  String get noStopSelected => _l10n.noStopSelected;
  String get andMore => _l10n.andMore;
  
  // Generate a localized error message with exception details
  String getLoadBusStopsErrorMessage(Exception e) {
    return '$loadBusStopsError: ${e.toString()}';
  }
  
  String getLoadBusSchedulesErrorMessage(Exception e) {
    return '$loadBusSchedulesError: ${e.toString()}';
  }
  
  // Helper method to generate a localized title for the sheet based on nearby bus stops
  String getSheetTitle(BusScheduleState state) {
    if (state.nearbyBusStops.isEmpty) {
      return state.selectedBusStop?.name ?? noStopSelected;
    }

    // Combine names of nearby bus stops
    final stopNames = state.nearbyBusStops.map((stop) => stop.name).toList();
    if (stopNames.length > 2) {
      return "${stopNames[0]} + ${stopNames[1]} + $andMore";
    } else {
      return stopNames.join(" + ");
    }
  }
}

/// Provider for the localized bus messages
final localizedBusMessagesProvider = Provider.family<LocalizedBusMessages, BuildContext>(
  (ref, context) => LocalizedBusMessages(context),
);
