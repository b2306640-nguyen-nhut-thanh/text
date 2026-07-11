import 'dart:ui';
import 'package:flutter/material.dart';

class DashedWavePainter extends CustomPainter {
  const DashedWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();
    path.moveTo(0, 28);
    path.quadraticBezierTo(
      size.width * 0.25, 46,
      size.width * 0.5, 28,
    );
    path.quadraticBezierTo(
      size.width * 0.75, 10,
      size.width, 28,
    );

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      const dashWidth = 6.0;
      const dashSpace = 5.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}