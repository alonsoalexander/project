// lib/transitions/no_animation_transition.dart
import 'package:flutter/material.dart';

class NoAnimationTransitionBuilder extends PageTransitionsBuilder {
  const NoAnimationTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Returnerar skärmen direkt utan animation
    return child;
  }
}