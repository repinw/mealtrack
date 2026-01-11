import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/foundation.dart';
import 'package:mealtrack/core/config/google_sign_in_config.dart';
import 'package:mealtrack/firebase_options.dart';

// coverage:ignore-file
Future<void> setupFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: AndroidDebugProvider(),
      providerApple: AppleDebugProvider(),
    );
  } else {
    await FirebaseAppCheck.instance.activate();
  }

  final googleClientId = GoogleSignInConfig.clientId;
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    if (googleClientId != null)
      GoogleProvider(clientId: googleClientId, scopes: ['email', 'profile']),
  ]);
}
