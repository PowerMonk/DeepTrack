import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final Color color;

  const CustomProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / goal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(
              '${current.toStringAsFixed(1)}h / ${goal.toStringAsFixed(0)}h',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: ProgressBarPainter(
              progress: progress,
              progressColor: color,
              backgroundColor: Colors.grey[300]!,
            ),
            size: const Size(double.infinity, 8),
          ),
        ),
      ],
    );
  }
}

class ProgressBarPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  ProgressBarPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background paint
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // Progress paint
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.fill;

    // Draw background rounded rectangle
    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    );
    canvas.drawRRect(backgroundRect, backgroundPaint);

    // Draw progress rounded rectangle
    if (progress > 0) {
      final progressWidth = size.width * progress;
      final progressRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, progressWidth, size.height),
        const Radius.circular(8),
      );
      canvas.drawRRect(progressRect, progressPaint);
    }
  }

  @override
  bool shouldRepaint(ProgressBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
