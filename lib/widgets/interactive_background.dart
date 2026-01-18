import 'package:flutter/material.dart';

class InteractiveBackground extends StatelessWidget {
  final ValueNotifier<Offset> touchPosition;

  const InteractiveBackground({super.key, required this.touchPosition});

  @override
  Widget build(BuildContext context) {
    return Container(color: const Color(0xFFF8FAFB));
  }
}
