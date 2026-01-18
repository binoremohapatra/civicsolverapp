import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/magnetic_button.dart';
import '../../widgets/background_effects.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onCreateComplaint;
  final VoidCallback onViewDetails;
  final VoidCallback onViewAllComplaints;
  final VoidCallback onLogout;

  // ✅ CHANGED: Accept full list to calculate real stats
  final List<Map<String, dynamic>> complaints;

  const DashboardScreen({
    super.key,
    required this.onCreateComplaint,
    required this.onViewDetails,
    required this.onViewAllComplaints,
    required this.onLogout,
    required this.complaints, // ✅ Real Data List
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    const int baseDelay = 200;
    const int step = 150;

    // --- 📊 REAL-TIME CALCULATIONS ---

    // 1. Calculate Active Count
    final activeList = widget.complaints.where((c) {
      final status = c['status']?.toString().toLowerCase() ?? '';
      return status != 'resolved' && status != 'closed' && status != 'rejected';
    }).toList();
    final activeCount = activeList.length;

    // 2. Calculate Unique Departments (Categories)
    final uniqueCategories = activeList
        .map((c) => c['category']?.toString() ?? 'General')
        .toSet()
        .toList();
    final deptCount = uniqueCategories.length;

    // ---------------------------------

    return Scaffold(
      backgroundColor: ShadcnTheme.background,
      body: Stack(
        children: [
          // 1. BACKGROUND LAYERS
          const LiquidBackground(),
          const InteractiveParticleBackground(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  _buildTopSystemHeader()
                      .animate()
                      .fade(duration: 600.ms)
                      .slideY(begin: -0.2, end: 0, curve: Curves.easeOut),

                  const SizedBox(height: 20),

                  // GREETINGS
                  Text("Good morning,", style: ShadcnTheme.lead.copyWith(fontSize: 16))
                      .animate().fade(delay: (baseDelay).ms).slideX(),
                  Text("Citizen", style: ShadcnTheme.h1.copyWith(color: ShadcnTheme.primary, fontSize: 32, height: 1.1))
                      .animate().fade(delay: (baseDelay + 100).ms).slideX(),

                  const SizedBox(height: 24),

                  // DASHBOARD PREVIEW (With Real Data)
                  _buildDashboardPreview(activeCount, deptCount)
                      .animate().fade(delay: (baseDelay + step).ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // ACTION CARDS
                  InteractiveActionCard(
                    title: "New Complaint",
                    subtitle: "Submit a civic matter with absolute confidence",
                    icon: Icons.post_add,
                    isPrimary: true,
                    onTap: widget.onCreateComplaint,
                    entranceDelay: baseDelay + step * 2,
                  ),

                  const SizedBox(height: 16),

                  InteractiveActionCard(
                    title: "Recent Activity",
                    subtitle: "View your latest case status",
                    icon: Icons.history_edu,
                    isPrimary: false,
                    onTap: widget.onViewDetails,
                    entranceDelay: baseDelay + step * 3,
                  ),

                  const SizedBox(height: 16),

                  InteractiveActionCard(
                    title: "Complaint Registry",
                    subtitle: "Browse the full public ledger of issues",
                    icon: Icons.format_list_bulleted_rounded,
                    isPrimary: false,
                    onTap: widget.onViewAllComplaints,
                    entranceDelay: baseDelay + step * 4,
                  ),

                  const SizedBox(height: 32),

                  Text("Platform Analytics", style: ShadcnTheme.h3)
                      .animate().fade(delay: (baseDelay + step * 5).ms),
                  const SizedBox(height: 16),
                  _buildAnalyticsGrid(delay: baseDelay + step * 5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HEADER ---
  Widget _buildTopSystemHeader() {
    return GlassCard(
      intensity: 'strong',
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const OrbitingShieldIcon(size: 44),
                  const SizedBox(width: 12),
                  Text("CivicSolver", style: ShadcnTheme.h2.copyWith(fontSize: 22)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("System Status", style: TextStyle(fontSize: 10, color: Colors.grey[600], height: 1)),
                            const SizedBox(height: 2),
                            const Text("Operational", style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold, height: 1)),
                          ],
                        ),
                      ],
                    ),
                  ).animate().rotate(begin: 0, end: 2, duration: 2.seconds, curve: Curves.easeInOutBack),

                  const SizedBox(height: 8),

                  MagneticButton(
                    onPressed: widget.onLogout,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout_rounded, size: 12, color: Colors.red[400]),
                          const SizedBox(width: 4),
                          Text("Sign Out", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red[400])),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniBadge(Icons.emoji_events_outlined, "Award-Winning"),
              const SizedBox(width: 8),
              _buildMiniBadge(Icons.bolt, "99.9% Uptime", isGreen: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(IconData icon, String label, {bool isGreen = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isGreen ? Colors.green : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (isGreen ? Colors.green : Colors.orange).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 10, color: isGreen ? Colors.green : Colors.orange),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 9, color: isGreen ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ✅ UPDATED: Takes dynamic counts
  Widget _buildDashboardPreview(int activeCount, int deptCount) {
    // Dynamic text for singular/plural
    final matterText = activeCount == 1 ? "active matter being reviewed" : "active matters being reviewed";
    final deptText = deptCount == 1 ? "1 department engaged" : "$deptCount departments engaged";

    return GlassCard(
      intensity: 'medium',
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Your Civic Dashboard", style: ShadcnTheme.small.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              const Icon(Icons.auto_awesome, size: 16, color: Colors.amber)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(duration: 400.ms, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2))
                  .fade(duration: 400.ms, begin: 0.6, end: 1.0),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("$activeCount", style: ShadcnTheme.h1.copyWith(fontSize: 42, color: ShadcnTheme.primary, height: 1))
                  .animate().scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(matterText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (activeCount > 0)
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 100,
                  child: Stack(
                    children: List.generate(math.min(deptCount, 4), (index) {
                      return Positioned(
                        left: index * 16.0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: [Colors.blue.shade900, Colors.blue.shade700, Colors.teal.shade400, Colors.green.shade300][index % 4],
                          child: index == 3 ? const Icon(Icons.add, size: 10, color: Colors.white) : null,
                        ).animate().slideX(begin: -0.5, end: 0, delay: (300 + index * 100).ms, curve: Curves.easeOutBack).fadeIn(),
                      );
                    }),
                  ),
                ),
                Text(deptText, style: const TextStyle(fontSize: 10, color: Colors.grey))
                    .animate().fadeIn(delay: 800.ms),
              ],
            )
          else
            const Text("No active cases. Everything looks good! 🌟", style: TextStyle(fontSize: 12, color: Colors.grey))
        ],
      ),
    );
  }

  Widget _buildAnalyticsGrid({required int delay}) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard("Avg Response", "2.3 days", Icons.timer_outlined, Colors.blue, delay),
        _buildStatCard("Resolution", "94%", Icons.trending_up, Colors.green, delay + 50),
        _buildStatCard("Officers", "156", Icons.people_outline, Colors.indigo, delay + 100),
        _buildStatCard("Resolved", "1,247", Icons.task_alt, Colors.orange, delay + 150),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, int delay) {
    return GlassCard(
      intensity: 'light',
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          FittedBox(child: Text(value, style: ShadcnTheme.h2.copyWith(fontSize: 24))),
          Text(label, style: ShadcnTheme.small, maxLines: 1),
        ],
      ),
    ).animate().fade(delay: delay.ms).slideY(begin: 0.1);
  }
}

// =========================================================
//  INTERACTIVE BUBBLE BACKGROUND
// =========================================================
class InteractiveParticleBackground extends StatefulWidget {
  const InteractiveParticleBackground({super.key});
  @override
  State<InteractiveParticleBackground> createState() => _InteractiveParticleBackgroundState();
}

class _InteractiveParticleBackgroundState extends State<InteractiveParticleBackground> with SingleTickerProviderStateMixin {
  final List<Particle> _particles = [];
  Offset _touchPosition = Offset.zero;
  late AnimationController _controller;
  final int _particleCount = 15;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    final random = math.Random();
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        vx: (random.nextDouble() - 0.5) * 0.002,
        vy: (random.nextDouble() - 0.5) * 0.002,
        size: random.nextDouble() * 30 + 15,
        color: ShadcnTheme.primary.withOpacity(0.15 + random.nextDouble() * 0.15),
      ));
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  void _updateParticles() {
    for (var p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      if (p.x < 0 || p.x > 1) p.vx *= -1;
      if (p.y < 0 || p.y > 1) p.vy *= -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) => setState(() => _touchPosition = e.localPosition),
      onPointerMove: (e) => setState(() => _touchPosition = e.localPosition),
      onPointerUp: (e) => setState(() => _touchPosition = Offset.zero),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          _updateParticles();
          return CustomPaint(painter: ParticlePainter(_particles, _touchPosition), size: Size.infinite);
        },
      ),
    );
  }
}

class Particle {
  double x, y, vx, vy, size;
  Color color;
  Particle({required this.x, required this.y, required this.vx, required this.vy, required this.size, required this.color});
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Offset touchPos;
  ParticlePainter(this.particles, this.touchPos);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      Offset pos = Offset(p.x * size.width, p.y * size.height);
      if (touchPos != Offset.zero) {
        double dist = (pos - touchPos).distance;
        if (dist < 150) {
          final pushDir = (pos - touchPos) / dist;
          pos += pushDir * (150 - dist) * 0.2;
        }
      }
      final paint = Paint()..color = p.color..style = PaintingStyle.fill;
      canvas.drawCircle(pos, p.size, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// =========================================================
//  ORBITING SHIELD ICON
// =========================================================
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
  void dispose() { _controller.dispose(); super.dispose(); }

  Widget _buildOrbitingDot(double angle, double phase, double tiltZ) {
    return Transform(
      transform: Matrix4.identity()..rotateZ(tiltZ)..translate((widget.size * 0.8) * math.cos(angle * 2 + phase), (widget.size * 0.4) * math.sin(angle * 2 + phase)),
      child: Container(
        width: 4, height: 4,
        decoration: BoxDecoration(color: const Color(0xFFFFD700), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.6), blurRadius: 5)]),
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
              Transform(
                transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
                alignment: Alignment.center,
                child: Container(
                  width: widget.size, height: widget.size,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F4C81), borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: const Color(0xFF0F4C81).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Center(child: Icon(Icons.shield_outlined, color: Colors.white, size: widget.size * 0.6)),
                ),
              ),
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

// =========================================================
//  INTERACTIVE ACTION CARD
// =========================================================
class InteractiveActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;
  final int entranceDelay;

  const InteractiveActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
    this.entranceDelay = 0,
  });

  @override
  State<InteractiveActionCard> createState() => _InteractiveActionCardState();
}

class _InteractiveActionCardState extends State<InteractiveActionCard> with TickerProviderStateMixin {
  late AnimationController _shineController;

  // STATE: For Tilt and Press
  double _rotateY = 0;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2500)
    )..repeat();
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  void _updateRotation(Offset globalPosition) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Offset localPos = box.globalToLocal(globalPosition);
    final double xPct = (localPos.dx / box.size.width) - 0.5;

    setState(() => _rotateY = (xPct * 1.0).clamp(-0.5, 0.5));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      child: MouseRegion(
        onHover: (e) => _updateRotation(e.position),
        onExit: (_) => setState(() => _rotateY = 0),
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) {
            setState(() => _isPressed = true);
            _updateRotation(e.position);
          },
          onPointerMove: (e) => _updateRotation(e.position),
          onPointerUp: (_) {
            setState(() { _isPressed = false; _rotateY = 0; });
            widget.onTap();
          },
          onPointerCancel: (_) => setState(() { _isPressed = false; _rotateY = 0; }),

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: widget.isPrimary ? ShadcnTheme.primaryGradient : null,
              color: widget.isPrimary ? null : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: widget.isPrimary ? null : Border.all(color: Colors.white),
              boxShadow: [
                BoxShadow(
                  color: (widget.isPrimary ? ShadcnTheme.primary : Colors.black).withOpacity(0.15),
                  blurRadius: _isPressed ? 5 : 20,
                  spreadRadius: 0,
                  offset: _isPressed ? const Offset(0, 2) : const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                if (widget.isPrimary)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedBuilder(
                        animation: _shineController,
                        builder: (context, child) {
                          final double offset = _shineController.value * 3 - 1;
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(offset - 0.5, -1),
                                end: Alignment(offset + 0.5, 1),
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0)
                                ],
                                stops: const [0.3, 0.5, 0.7],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeOut,
                        transform: Matrix4.identity()..setEntry(3, 2, 0.002)..rotateY(_rotateY),
                        transformAlignment: Alignment.center,
                        child: SizedBox(
                          width: 64, height: 64,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              _buildWave(delay: 0),
                              _buildWave(delay: 1000),
                              Container(
                                width: 64, height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: widget.isPrimary
                                      ? LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.3)])
                                      : LinearGradient(colors: [ShadcnTheme.primary.withOpacity(0.05), ShadcnTheme.primary.withOpacity(0.15)]),
                                  border: Border.all(color: widget.isPrimary ? Colors.white.withOpacity(0.4) : ShadcnTheme.primary.withOpacity(0.2)),
                                  boxShadow: [BoxShadow(color: (widget.isPrimary ? Colors.black : ShadcnTheme.primary).withOpacity(0.2), blurRadius: 15, offset: Offset(-_rotateY * 20, 0))],
                                ),
                                child: Center(child: Icon(widget.icon, color: widget.isPrimary ? Colors.white : ShadcnTheme.primary, size: 32)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.title, style: ShadcnTheme.h2.copyWith(color: widget.isPrimary ? Colors.white : ShadcnTheme.primary, fontSize: 20))
                                .animate().fade(delay: (widget.entranceDelay + 200).ms).slideX(begin: 0.1),
                            Text(widget.subtitle, style: ShadcnTheme.small.copyWith(color: widget.isPrimary ? Colors.white70 : ShadcnTheme.mutedForeground))
                                .animate().fade(delay: (widget.entranceDelay + 300).ms).slideX(begin: 0.1),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: widget.isPrimary ? Colors.white70 : ShadcnTheme.primary.withOpacity(0.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(duration: 500.ms, delay: widget.entranceDelay.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildWave({required int delay}) {
    final Color waveColor = widget.isPrimary ? Colors.white.withOpacity(0.3) : ShadcnTheme.primary.withOpacity(0.2);
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: waveColor, width: 1)),
    ).animate(onPlay: (c) => c.repeat(), delay: delay.ms).scale(begin: const Offset(1, 1), end: const Offset(2.2, 2.2), duration: 2.5.seconds).fadeOut(duration: 2.5.seconds);
  }
}