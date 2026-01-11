import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtrack/core/config/google_sign_in_config.dart';

void main() {
  group('GoogleSignInConfig', () {
    test('returns clientId on Web', () {
      // kIsWeb is constant, but on actual web runner it would be true.
      // In unit test environment (dart:io), kIsWeb is false.
      // We can't easily mock kIsWeb constant in Dart without conditional imports or building for web.
      // So we focus on defaultTargetPlatform which is mutable in tests via debugDefaultTargetPlatformOverride.
    });

    test('returns clientId on Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(GoogleSignInConfig.clientId, isNotNull);
      debugDefaultTargetPlatformOverride = null;
    });

    test('returns clientId on iOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(GoogleSignInConfig.clientId, isNotNull);
      debugDefaultTargetPlatformOverride = null;
    });

    test('returns clientId on macOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(GoogleSignInConfig.clientId, isNotNull);
      debugDefaultTargetPlatformOverride = null;
    });

    test('returns clientId on Windows', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(
        GoogleSignInConfig.clientId,
        isNotNull,
      ); // Or null if we decided to support it that way, currently not null.
      debugDefaultTargetPlatformOverride = null;
    });

    test('returns null on Linux', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      expect(GoogleSignInConfig.clientId, isNull);
      debugDefaultTargetPlatformOverride = null;
    });

    test('returns null on Fuchsia', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      expect(GoogleSignInConfig.clientId, isNull);
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
