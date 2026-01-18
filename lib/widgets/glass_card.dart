import 'package:flutter/material.dart';
import 'dart:ui'; // REQUIRED for ImageFilter
import '../theme/app_theme.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final String intensity; // 'light', 'medium', 'strong'
  final bool tiltEffect;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.intensity = 'medium',
    this.tiltEffect = true,
    this.padding = EdgeInsets.zero,
    this.onTap,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  double _rotateX = 0;
  double _rotateY = 0;
  bool _isHovered = false;

  void _onHover(PointerEvent details, Size size) {
    if (!widget.tiltEffect) return;

    final x = (details.localPosition.dx / size.width) - 0.5;
    final y = (details.localPosition.dy / size.height) - 0.5;

    setState(() {
      _rotateX = y * -0.2;
      _rotateY = x * 0.2;
    });
  }

  void _onExit(PointerEvent details) {
    setState(() {
      _isHovered = false;
      _rotateX = 0;
      _rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    double blur = 10;
    double opacity = 0.6;
    if (widget.intensity == 'light') { blur = 5; opacity = 0.4; }
    if (widget.intensity == 'strong') { blur = 20; opacity = 0.8; }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: _onExit,
      onHover: (details) {
        final renderBox = context.findRenderObject() as RenderBox;
        _onHover(details, renderBox.size);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_rotateX)
            ..rotateY(_rotateY),
          transformAlignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ShadcnTheme.radiusLg),
            child: BackdropFilter(
              // FIXED: Removed 'android.ui.' prefix
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(opacity),
                  borderRadius: BorderRadius.circular(ShadcnTheme.radiusLg),
                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(opacity + 0.1),
                      Colors.white.withOpacity(opacity - 0.1),
                    ],
                  ),
                  boxShadow: _isHovered ? [
                    BoxShadow(color: ShadcnTheme.secondary.withOpacity(0.2), blurRadius: 30, spreadRadius: 5)
                  ] : [],
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}