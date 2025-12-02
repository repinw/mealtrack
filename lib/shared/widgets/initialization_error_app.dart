import 'package:flutter/material.dart';

/// Ein einfacher Bildschirm, der angezeigt wird, wenn die App nicht starten kann.
class InitializationErrorApp extends StatelessWidget {
  const InitializationErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'App konnte nicht initialisiert werden.\nBitte starte die App neu.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
