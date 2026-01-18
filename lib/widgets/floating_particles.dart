import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FloatingParticles extends StatelessWidget {
  final int count;

  const FloatingParticles({super.key, this.count = 12});

  @override
  Widget build(BuildContext context) {
    final random = Random();

    return IgnorePointer(
      child: Stack(
        children: List.generate(count, (_) {
          final size = random.nextDouble() * 6 + 3;
          return Positioned(
            top: random.nextDouble() * MediaQuery.of(context).size.height,
            left: random.nextDouble() * MediaQuery.of(context).size.width,
            child: Opacity(
              opacity: 0.12,
              child: Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2DD4BF),
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -20),
          );
        }),
      ),
    );
  }
}
