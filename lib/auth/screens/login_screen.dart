import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/background_effects.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/magnetic_button.dart';
import 'splash_screen.dart'; // Imports OrbitingShieldIcon
import '../providers/auth_provider.dart'; // ✅ Added Import

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback onLogin;    // Defined here
  final VoidCallback onRegister; // Defined here

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onRegister
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // ✅ UPDATED: Real Login Logic
  Future<void> _handleLogin() async {
    // 1. Validation
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Call Real Backend via Provider
      await ref.read(authProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 3. Success -> Navigate
      if (!mounted) return;
      widget.onLogin();

    } catch (e) {
      // 4. Failure -> Show Error
      if (!mounted) return;
      final errorMsg = e.toString().replaceAll('Exception:', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login Failed: $errorMsg"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Stack(
        children: [
          const LiquidBackground(),
          const CanvasParticles(mouseInteractive: true),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Hero(
                    tag: 'app-logo',
                    child: OrbitingShieldIcon(size: 80),
                  ),

                  const SizedBox(height: 40),

                  GlassCard(
                    intensity: 'strong',
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Welcome Back",
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enter your secure credentials",
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        _buildGlassInput(_emailController, "Email Address", Icons.email_outlined),
                        const SizedBox(height: 16),
                        _buildGlassInput(_passwordController, "Password", Icons.lock_outline, obscureText: true),

                        const SizedBox(height: 32),

                        MagneticButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF0F4C81), Color(0xFF1E40AF)]),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF0F4C81).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))
                              ],
                            ),
                            child: _isLoading
                                ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                                : const Text(
                              "Sign In",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: TextStyle(color: Colors.grey[600])),
                      GestureDetector(
                        onTap: widget.onRegister, // Calls callback
                        child: const Text(
                          "Create Account",
                          style: TextStyle(color: Color(0xFF0F4C81), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassInput(TextEditingController controller, String hint, IconData icon, {bool obscureText = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}