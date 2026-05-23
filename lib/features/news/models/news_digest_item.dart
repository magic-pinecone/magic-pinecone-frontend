import 'package:flutter/material.dart';

class NewsDigestItem {
  const NewsDigestItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
}
