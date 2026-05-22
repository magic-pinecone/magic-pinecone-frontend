import 'package:flutter/material.dart';

class PortalShortcutButton extends StatelessWidget {
  const PortalShortcutButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: color.withValues(alpha: isDark ? 0.24 : 0.12),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            splashColor: color.withValues(alpha: 0.3),
            highlightColor: color.withValues(alpha: 0.15),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Center(child: Icon(icon, size: 28.0, color: color)),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
