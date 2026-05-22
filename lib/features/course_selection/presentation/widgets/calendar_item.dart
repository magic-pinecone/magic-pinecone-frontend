import 'package:flutter/material.dart';

class CalendarItem extends StatelessWidget {
  const CalendarItem({
    super.key,
    required this.courseName,
    required this.length,
    this.onTap,
  });

  final String courseName;
  final int length;
  final VoidCallback? onTap;

  static const List<Color> _materialPalette = [
    Color(0xFFEF5350), // Red 400
    Color(0xFFEC407A), // Pink 400
    Color(0xFFAB47BC), // Purple 400
    Color(0xFF7E57C2), // Deep Purple 400
    Color(0xFF5C6BC0), // Indigo 400
    Color(0xFF42A5F5), // Blue 400
    Color(0xFF29B6F6), // Light Blue 400
    Color(0xFF26C6DA), // Cyan 400
    Color(0xFF26A69A), // Teal 400
    Color(0xFF66BB6A), // Green 400
    Color(0xFF9CCC65), // Light Green 400
    Color(0xFFD4E157), // Lime 400
    Color(0xFFFFEE58), // Yellow 400
    Color(0xFFFFCA28), // Amber 400
    Color(0xFFFFA726), // Orange 400
    Color(0xFFFF7043), // Deep Orange 400
    Color(0xFF8D6E63), // Brown 400
    Color(0xFFBDBDBD), // Grey 400
    Color(0xFF78909C), // Blue Grey 400
  ];

  Color _getColorForString(String input) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = input.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final index = hash.abs() % _materialPalette.length;
    return _materialPalette[index];
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForString(courseName);

    return Card(
      margin: EdgeInsets.zero,
      color: color.withValues(alpha: 0.2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: color.withValues(alpha: 0.5), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                courseName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color.lerp(color, Colors.black, 0.2),
                ),
                maxLines: length > 1 ? 3 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
