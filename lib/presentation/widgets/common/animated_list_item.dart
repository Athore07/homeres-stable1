// lib/presentation/widgets/common/animated_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delay;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 100),
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: delay * index,
        )
        .slideX(
          begin: 20,
          duration: 400.ms,
          delay: delay * index,
          curve: Curves.easeOut,
        );
  }
}