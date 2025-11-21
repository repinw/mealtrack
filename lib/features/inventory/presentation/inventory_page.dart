import 'package:flutter/material.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Placeholder(child: Text(title));
  }
}
