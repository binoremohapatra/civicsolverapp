import 'package:flutter/material.dart';

class TiltCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final Color? color;
  final Gradient? gradient;

  const TiltCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.color,
    this.gradient,
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> {
  double _rotateX = 0;
  double _rotateY = 0;
  bool _isHovering = false;

  void _handleHover(PointerEvent details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPos = box.globalToLocal(details.position);

    // Normalize coordinates from -0.5 to 0.5
    final double xPct = (localPos.dx / box.size.width) - 0.5;
    final double yPct = (localPos.dy / box.size.height) - 0.5;

    setState(() {
      _isHovering = true;
      // High sensitivity for "Hand Movement" feel
      _rotateY = xPct * 0.8;
      _rotateX = yPct * -0.8;
    });
  }

  void _handleExit() {
    setState(() {
      _isHovering = false;
      _rotateX = 0;
      _rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _handleHover,
      onExit: (_) => _handleExit(),
      child: TiltStateProvider(
        isHovering: _isHovering,
        rotateX: _rotateX,
        rotateY: _rotateY,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: widget.color ?? Colors.white,
              gradient: widget.gradient,
              borderRadius: widget.borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  // Shadow shifts slightly to follow tilt
                  offset: Offset(-_rotateY * 10, _rotateX * 10 + 6),
                )
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// UPDATED Provider to pass the 3D rotation values
class TiltStateProvider extends InheritedWidget {
  final bool isHovering;
  final double rotateX;
  final double rotateY;

  const TiltStateProvider({
    super.key,
    required this.isHovering,
    required this.rotateX,
    required this.rotateY,
    required super.child,
  });

  static TiltStateProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TiltStateProvider>();
  }

  @override
  bool updateShouldNotify(TiltStateProvider oldWidget) =>
      oldWidget.rotateX != rotateX || oldWidget.rotateY != rotateY;
}