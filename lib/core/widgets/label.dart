import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final String text;
  final Color color;

  const Label({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(text, style: TextStyle(color: color, fontSize: 14)),
      ),
    );
  }
}
