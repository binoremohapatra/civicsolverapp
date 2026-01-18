import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/background_effects.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/magnetic_button.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final VoidCallback onRegisterSuccess;
  final VoidCallback onBackToLogin;

  const RegisterScreen({
    super.key,
    required this.onRegisterSuccess,
    required this.onBackToLogin
  });

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // ✅ FIXED: Now sends Name, Email, and Password
  Future<void> _handleRegister() async {
    // 1. Validation
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Call Real Backend via Provider
      // ✅ UPDATE: Added _nameController.text.trim() as the first argument
      await ref.read(authProvider.notifier).register(
        _nameController.text.trim(),      // The Name
        _emailController.text.trim(),     // The Email
        _passwordController.text.trim(),  // The Password
      );

      // 3. Success -> Navigate
      if (!mounted) return;
      widget.onRegisterSuccess();

    } catch (e) {
      // 4. Failure -> Show Error
      if (!mounted) return;
      final errorMsg = e.toString().replaceAll('Exception:', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration Failed: $errorMsg"),
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
          const CanvasParticles(),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Join CivicSolver",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0F4C81)),
                  ).animate().fadeIn().slideY(begin: -0.2),

                  const SizedBox(height: 8),

                  const Text(
                    "Create your secure citizen identity",
                    style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 40),

                  GlassCard(
                    intensity: 'strong',
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        _buildGlassInput(_nameController, "Full Name", Icons.person_outline),
                        const SizedBox(height: 16),
                        _buildGlassInput(_emailController, "Email Address", Icons.email_outlined),
                        const SizedBox(height: 16),
                        _buildGlassInput(_passwordController, "Create Password", Icons.lock_outline, obscureText: true),

                        const SizedBox(height: 32),

                        MagneticButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF10B981)]),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))
                              ],
                            ),
                            child: _isLoading
                                ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                                : const Text(
                              "Create Account",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95)),

                  const SizedBox(height: 24),

                  TextButton(
                    onPressed: widget.onBackToLogin, // Calls callback
                    child: RichText(
                      text: const TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: Color(0xFF64748B)),
                        children: [
                          TextSpan(
                            text: "Login",
                            style: TextStyle(color: Color(0xFF0F4C81), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
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