import 'package:flutter/foundation.dart';

/// Identificador de plataforma usado por `/app/version-check` (secção 22):
/// 'windows' | 'android' | 'ios_pwa' | 'macos_pwa'.
///
/// Usa `defaultTargetPlatform` em vez de `dart:io Platform` de propósito —
/// funciona também em builds Web (kIsWeb), onde `dart:io` não compila.
class PlatformUtil {
  const PlatformUtil._();

  static String current() {
    if (kIsWeb) {
      return defaultTargetPlatform == TargetPlatform.iOS ? 'ios_pwa' : 'macos_pwa';
    }
    return defaultTargetPlatform == TargetPlatform.windows ? 'windows' : 'android';
  }
}
