import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const ActionButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Icon(
            icon,
            size: 18,
            color: onTap == null ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
      ),
    );
  }
}
