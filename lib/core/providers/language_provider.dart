import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:busnow/core/localization/app_localizations.dart';

// Provider to expose the current text direction
final textDirectionProvider = Provider<TextDirection>((ref) {
  final language = ref.watch(appLanguageProvider);
  return language.isRtl ? TextDirection.rtl : TextDirection.ltr;
});

// Provider to expose the current locale
final localeProvider = Provider<Locale>((ref) {
  final language = ref.watch(appLanguageProvider);
  return Locale(language.code);
});

// Provider for direction-aware edge insets
final directionAwareEdgeInsetsProvider = Provider.family<EdgeInsets, EdgeInsetsDirectional>((ref, directionalInsets) {
  final textDirection = ref.watch(textDirectionProvider);
  
  return directionalInsets.resolve(textDirection);
});

// Provider for direction-aware alignment
final directionAwareAlignmentProvider = Provider.family<Alignment, AlignmentDirectional>((ref, directionalAlignment) {
  final textDirection = ref.watch(textDirectionProvider);
  
  return directionalAlignment.resolve(textDirection);
});