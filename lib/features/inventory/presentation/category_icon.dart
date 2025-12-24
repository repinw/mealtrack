import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final String name;

  const CategoryIcon({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    const iconData = Icons.kitchen;
    return CircleAvatar(
      radius: 24,
      backgroundColor: Colors.grey.shade100,
      child: Icon(iconData, color: Colors.grey.shade700, size: 22),
    );
  }
}
