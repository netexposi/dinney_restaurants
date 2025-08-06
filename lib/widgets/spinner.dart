import 'dart:math' as math;
import 'package:dinney_restaurant/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class LoadingSpinner extends StatefulWidget {
  final Color color;

  LoadingSpinner({
    Key? key,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  _LoadingSpinnerState createState() => _LoadingSpinnerState();
}

class _LoadingSpinnerState extends State<LoadingSpinner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(10.sp),
        width: 24.sp,
        height: 24.sp,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.sp),
          color: tertiaryColor.withOpacity(0.4)
        ),
        child: CustomPaint(
          painter: _MontereySpinnerPainter(
            animation: _controller,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class _MontereySpinnerPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  static const int _barCount = 12;
  static const double _barLength = 0.4; // Increased for longer bars
  static const double _barWidth = 0.15; // Adjusted for thinner, straighter bars

  _MontereySpinnerPainter({required this.animation, required this.color})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    final double radius = size.width / 2;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    for (int i = 0; i < _barCount; i++) {
      final double angle = (i / _barCount) * 2 * math.pi;
      final double opacity = ((animation.value * _barCount + i) % _barCount) / _barCount;
      paint.color = color.withOpacity(0.2 + 0.8 * (1 - opacity));

      // Use _barLength to control the length of the bars
      final double innerRadius = radius * (1 - _barLength);
      final double outerRadius = radius;
      final double x1 = centerX + innerRadius * math.cos(angle);
      final double y1 = centerY + innerRadius * math.sin(angle);
      final double x2 = centerX + outerRadius * math.cos(angle);
      final double y2 = centerY + outerRadius * math.sin(angle);

      // Create a rectangular path for straight bars
      final double halfWidth = radius * _barWidth / 2;
      final double dx = halfWidth * math.sin(angle);
      final double dy = halfWidth * math.cos(angle);

      final path = Path()
        ..moveTo(x1 - dx, y1 + dy)
        ..lineTo(x1 + dx, y1 - dy)
        ..lineTo(x2 + dx, y2 - dy)
        ..lineTo(x2 - dx, y2 + dy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}