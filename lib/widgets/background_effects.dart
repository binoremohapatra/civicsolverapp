import 'package:flutter/material.dart';
import 'dart:math';
import '../theme/app_theme.dart';

class LiquidBackground extends StatefulWidget {
  const LiquidBackground({super.key});

  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<LiquidBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Slower, smoother liquid movement (20 seconds per cycle)
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top Left Blob
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              top: -100 + sin(_controller.value * 2 * pi) * 30, // Reduced movement range
              left: -100 + cos(_controller.value * 2 * pi) * 30,
              child: _buildBlob(ShadcnTheme.secondary.withOpacity(0.15)),
            );
          },
        ),
        // Bottom Right Blob
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              bottom: -150 + cos(_controller.value * 2 * pi) * 40,
              right: -150 + sin(_controller.value * 2 * pi) * 40,
              child: _buildBlob(ShadcnTheme.primary.withOpacity(0.1)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBlob(Color color) {
    return Container(
      width: 600,
      height: 600,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 120, spreadRadius: 60)],
      ),
    );
  }
}

// ==========================================
// PARTICLES ENGINE
// ==========================================

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double alpha;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.alpha,
  });
}

class CanvasParticles extends StatefulWidget {
  final bool mouseInteractive;

  const CanvasParticles({super.key, this.mouseInteractive = true});

  @override
  State<CanvasParticles> createState() => _CanvasParticlesState();
}

class _CanvasParticlesState extends State<CanvasParticles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final Random _random = Random();
  Offset _mousePos = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 100))
      ..addListener(_updateParticles)
      ..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_particles.isEmpty) {
      _initParticles(MediaQuery.of(context).size);
    }
  }

  void _initParticles(Size size) {
    _particles.clear();
    // Reduce count for performance and cleaner look
    int count = (size.width * size.height / 25000).clamp(20, 50).toInt();

    for (int i = 0; i < count; i++) {
      _particles.add(Particle(
        x: _random.nextDouble() * size.width,
        y: _random.nextDouble() * size.height,
        // Very slow initial velocity
        vx: (_random.nextDouble() - 0.5) * 0.5,
        vy: (_random.nextDouble() - 0.5) * 0.5,
        size: _random.nextDouble() * 3 + 2,
        alpha: _random.nextDouble() * 0.3 + 0.1, // Subtle opacity
      ));
    }
  }

  void _updateParticles() {
    final size = MediaQuery.of(context).size;

    for (var p in _particles) {
      // 1. Move
      p.x += p.vx;
      p.y += p.vy;

      // 2. Mouse Interaction (Repel)
      if (widget.mouseInteractive) {
        double dx = p.x - _mousePos.dx;
        double dy = p.y - _mousePos.dy;
        double distance = sqrt(dx * dx + dy * dy);
        double radius = 150.0; // Interaction radius

        if (distance < radius) {
          double force = (radius - distance) / radius;
          double angle = atan2(dy, dx);
          double push = force * 0.8; // Strength of push

          p.vx += cos(angle) * push;
          p.vy += sin(angle) * push;
        }
      }

      // 3. Friction (This stops them from speeding up infinitely)
      p.vx *= 0.96;
      p.vy *= 0.96;

      // 4. Wrap around screen edges
      if (p.x < 0) p.x = size.width;
      if (p.x > size.width) p.x = 0;
      if (p.y < 0) p.y = size.height;
      if (p.y > size.height) p.y = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // Allows clicks to pass through to buttons underneath
      hitTestBehavior: HitTestBehavior.translucent,
      onHover: (details) {
        _mousePos = details.localPosition;
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlePainter(_particles),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      paint.color = ShadcnTheme.primary.withOpacity(p.alpha);
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}