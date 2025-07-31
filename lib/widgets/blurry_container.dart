import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BlurryContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double blurSigma;
  final Color? color;
  final BorderRadius? borderRadius;

  const BlurryContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.blurSigma = 16.0, // Set to 16 as per Figma spec
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16.sp);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: radius,
          color: Colors.black.withOpacity(0.15), // 15% black fill
          border: Border.all(
            width: 1,
            // Stroke: linear from white → #b2b2b2 → white
            color: Colors.white.withOpacity(0.8), // fallback for border
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.8),     // 80% white
              const Color(0xFFB2B2B2).withOpacity(0.2), // 20% #b2b2b2
              Colors.white.withOpacity(0.8),     // 80% white
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            // Drop shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.195),
              offset: const Offset(0, 12),
              blurRadius: 40,
            ),
            // Simulate inner shadow using inset blur (Flutter doesn’t support real inner shadows natively)
            BoxShadow(
              color: Colors.white.withOpacity(0.102),
              offset: const Offset(0, 2),
              blurRadius: 20,
              spreadRadius: 6,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Apply the blur filter
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(color: Colors.transparent),
            ),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}
