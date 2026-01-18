import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MagneticButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool disabled;

  const MagneticButton({
    super.key,
    required this.child,
    this.onPressed,
    this.disabled = false,
  });

  @override
  State<MagneticButton> createState() => _MagneticButtonState();
}

class _MagneticButtonState extends State<MagneticButton> with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;

  void _handleHover(PointerEvent event, Size size) {
    if (widget.disabled) return;

    final dx = event.localPosition.dx - size.width / 2;
    final dy = event.localPosition.dy - size.height / 2;

    // Magnetic pull strength (divider reduces distance)
    setState(() => _offset = Offset(dx / 4, dy / 4));
  }

  void _handleExit(PointerEvent event) {
    setState(() => _offset = Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        final renderBox = context.findRenderObject() as RenderBox;
        _handleHover(event, renderBox.size);
      },
      onExit: _handleExit,
      cursor: widget.disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0),
          child: widget.child,
        ),
      ),
    );
  }
}