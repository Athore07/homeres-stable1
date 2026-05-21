// lib/presentation/widgets/animations/fade_slide_transition.dart
import 'package:flutter/material.dart';

class FadeSlideTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Offset begin;
  final Curve curve;

  const FadeSlideTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.begin = const Offset(0, 0.1),
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: begin * (1 - value),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

