import 'package:flutter/material.dart';
import 'dart:math' as math;

class LogoAnimation extends StatefulWidget {
  @override
  _LogoAnimationState createState() => _LogoAnimationState();
}

class _LogoAnimationState extends State<LogoAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 6),
    );

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          // Get the size of the logo
          final logoSize = 250.0;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(math.pi *
                  2 *
                  _animationController.value), // Rotate along Y-axis
            alignment:
                Alignment.center, // Set the center of the logo as the origin
            child: Image.asset(
              'assets/logo.png',
              height: logoSize,
            ),
          );
        },
      ),
    );
  }
}
