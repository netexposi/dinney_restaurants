import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BlurryContainer extends StatefulWidget {
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
    this.blurSigma = 16.0,
    this.color,
    this.borderRadius,
  });

  @override
  BlurryContainerState createState() => BlurryContainerState();
}

class BlurryContainerState extends State<BlurryContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.02), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.02, end: 1.0), weight: 10),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  /// Call this from outside using a GlobalKey to trigger the bounce animation.
  void bounce() {
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(16.sp);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: Colors.black.withOpacity(0.15),
            border: Border.all(
              width: 1,
              color: Colors.white.withOpacity(0.8),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.8),
                const Color(0xFFB2B2B2).withOpacity(0.2),
                Colors.white.withOpacity(0.8),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.195),
                offset: const Offset(0, 12),
                blurRadius: 40,
              ),
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
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.blurSigma,
                  sigmaY: widget.blurSigma,
                ),
                child: Container(color: Colors.transparent),
              ),
              Center(child: widget.child),
            ],
          ),
        ),
      ),
    );
  }
}
