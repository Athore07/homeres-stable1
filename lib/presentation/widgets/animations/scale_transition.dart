// lib/presentation/widgets/animations/scale_transition.dart
import 'package:flutter/material.dart';

class ScaleTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const ScaleTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.elasticOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.5, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }
}

