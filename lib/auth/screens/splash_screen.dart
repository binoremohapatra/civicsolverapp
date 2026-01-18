import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../widgets/background_effects.dart';
import '../../widgets/glass_card.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete; // Callback required by main.dart

  const SplashScreen({super.key, required this.onComplete});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start timer to trigger navigation after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onComplete(); // Calls the callback passed from main.dart
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Stack(
        children: [
          // Background Effects
          const LiquidBackground(),
          const CanvasParticles(),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 3D Animated Logo with Hero tag for smooth transition to Login
                const Hero(
                  tag: 'app-logo',
                  child: OrbitingShieldIcon(size: 100),
                ),

                const SizedBox(height: 40),

                // Premium Typography
                Text(
                  "CivicSolver",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F4C81),
                    letterSpacing: -1.0,
                    height: 1.0,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 16),

                Text(
                  "Empowering Citizens, Securing Trust",
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- REUSABLE 3D ICON WIDGET ---
// This is exported so LoginScreen can use it too
class OrbitingShieldIcon extends StatefulWidget {
  final double size;
  const OrbitingShieldIcon({super.key, required this.size});
  @override
  State<OrbitingShieldIcon> createState() => _OrbitingShieldIconState();
}

class _OrbitingShieldIconState extends State<OrbitingShieldIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildOrbitingDot(double angle, double phase, double tiltZ) {
    return Transform(
      transform: Matrix4.identity()
        ..rotateZ(tiltZ)
        ..translate((widget.size * 0.8) * math.cos(angle * 2 + phase), (widget.size * 0.4) * math.sin(angle * 2 + phase)),
      child: Container(
        width: 6, height: 6,
        decoration: BoxDecoration(
            color: const Color(0xFFFFD700), // Gold Color
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.6), blurRadius: 8)
            ]
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double angle = _controller.value * 2 * math.pi;
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Rotating Shield Container
              Transform(
                transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
                alignment: Alignment.center,
                child: Container(
                  width: widget.size, height: widget.size,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0F4C81), Color(0xFF1E40AF)]
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF0F4C81).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                  ),
                  child: Center(
                      child: Icon(Icons.shield_outlined, color: Colors.white, size: widget.size * 0.6)
                  ),
                ),
              ),
              // Orbiting Particles
              _buildOrbitingDot(angle, 0, math.pi / 4),
              _buildOrbitingDot(angle, 2 * math.pi / 3, -math.pi / 4),
              _buildOrbitingDot(angle, 4 * math.pi / 3, 0),
            ],
          );
        },
      ),
    );
  }
}