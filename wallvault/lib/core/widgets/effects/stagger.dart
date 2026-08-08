import 'package:flutter/material.dart';
import 'entrance.dart';

/// Vertical column whose children fade-up one-by-one (staggered).
///
/// Use this for cards, menu rows, stat grids, settings rows — anything that
/// should reveal in sequence when a screen (or data) appears.
class StaggerChildren extends StatelessWidget {
  final List<Widget> children;
  final int stepMs;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;

  const StaggerChildren({
    super.key,
    required this.children,
    this.stepMs = 60,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (var i = 0; i < children.length; i++)
          Entrance.fadeUp(children[i], delayMs: stepMs * i),
      ],
    );
  }
}

/// Convenience wrapper for a single staggered entry at a given index,
/// so grids/masonry can pass their own index without restructuring.
class StaggeredItem extends StatelessWidget {
  final Widget child;
  final int index;
  final int stepMs;

  const StaggeredItem({
    super.key,
    required this.child,
    required this.index,
    this.stepMs = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Entrance.fadeUp(child, delayMs: stepMs * index);
  }
}