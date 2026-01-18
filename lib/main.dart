import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- THEME & WIDGETS ---
import 'theme/app_theme.dart';
import 'widgets/glass_card.dart';
import 'widgets/background_effects.dart';

// --- SCREEN IMPORTS ---
import 'auth/screens/login_screen.dart';
import 'auth/screens/register_screen.dart';
import 'auth/screens/splash_screen.dart';
import 'complaints/providers/complaint_provider.dart';
import 'complaints/screens/complaint_detail_screen.dart' hide complaintProvider;
import 'complaints/screens/complaints_list_screen.dart';
import 'complaints/screens/create_complaint_screen.dart' hide ComplaintDetailScreen;
import 'dashboard/screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set transparent status bar for the "Glass" look
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(
    const ProviderScope(child: CivicSolverApp()),
  );
}

class CivicSolverApp extends StatelessWidget {
  const CivicSolverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CivicSolver',
      debugShowCheckedModeBanner: false,
      theme: ShadcnTheme.materialTheme,
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends ConsumerStatefulWidget {
  const MainNavigator({super.key});

  @override
  ConsumerState<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends ConsumerState<MainNavigator> {
  final _storage = const FlutterSecureStorage();

  // --- Navigation State ---
  String _currentScreen = 'splash';
  String _previousScreen = 'dashboard';

  bool _isCheckingAuth = true;
  bool _showSuccessOverlay = false;

  // --- Data State ---
  Map<String, dynamic> _selectedComplaint = {};

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  // --- 1. AUTH CHECK ---
  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    String? token = await _storage.read(key: 'jwt_token');

    if (mounted) {
      setState(() {
        if (token != null) {
          _currentScreen = 'dashboard';
          // Pre-fetch complaints so the dashboard isn't empty
          ref.read(complaintProvider.notifier).fetchComplaints();
        } else {
          _currentScreen = 'login';
        }
        _isCheckingAuth = false;
      });
    }
  }

  // --- 2. ACTION HANDLERS ---

  Future<void> _handleLoginSuccess() async {
    setState(() => _currentScreen = 'dashboard');
    ref.read(complaintProvider.notifier).fetchComplaints();
  }

  Future<void> _handleLogout() async {
    await _storage.delete(key: 'jwt_token');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logged out successfully")),
      );
      setState(() => _currentScreen = 'login');
    }
  }

  // ✅ FIXED: Now extracts Location & Category and passes as Named Parameters
  Future<void> _handleComplaintSubmit(Map<String, dynamic> data) async {
    setState(() => _showSuccessOverlay = true);
    try {
      final title = data['title'];
      final description = data['description'];
      final category = data['category'] ?? "General";         // ✅ New
      final location = data['location'] ?? "Manual Location"; // ✅ New
      final imagePath = data['imagePath'];

      File? imageFile;
      if (imagePath != null && imagePath.toString().isNotEmpty) {
        imageFile = File(imagePath);
      }

      // ✅ Updated Call matching the new Provider signature
      await ref.read(complaintProvider.notifier).createComplaint(
        title: title,
        description: description,
        category: category,
        location: location,
        image: imageFile,
      );

      // Refresh immediately
      await ref.read(complaintProvider.notifier).fetchComplaints();

    } catch (e) {
      setState(() => _showSuccessOverlay = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Submission failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- 3. UI BUILDER ---

  @override
  Widget build(BuildContext context) {
    final complaintState = ref.watch(complaintProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Stack(
        children: [
          // Main Screen Switcher
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _buildScreen(complaintState),
          ),

          // Global Success Overlay (for Creation)
          if (_showSuccessOverlay)
            _buildSuccessOverlay(complaintState),
        ],
      ),
    );
  }

  Widget _buildScreen(ComplaintState state) {
    if (_isCheckingAuth) {
      return SplashScreen(
        key: const ValueKey('splash'),
        onComplete: () {},
      );
    }

    switch (_currentScreen) {
    // --- AUTHENTICATION ---
      case 'login':
        return LoginScreen(
          key: const ValueKey('login'),
          onLogin: _handleLoginSuccess,
          onRegister: () => setState(() => _currentScreen = 'register'),
        );

      case 'register':
        return RegisterScreen(
          key: const ValueKey('register'),
          onRegisterSuccess: _handleLoginSuccess,
          onBackToLogin: () => setState(() => _currentScreen = 'login'),
        );

    // --- CREATION ---
      case 'create':
        return CreateComplaintScreen(
          key: const ValueKey('create'),
          onBack: () => setState(() => _currentScreen = 'dashboard'),
          onSubmit: _handleComplaintSubmit,
        );

    // --- DETAILS ---
      case 'detail':
        return ComplaintDetailScreen(
          key: const ValueKey('detail'),
          complaint: _selectedComplaint,
          onBack: () async {
            // ✅ FIX: Wait for DB sync then refresh
            await Future.delayed(const Duration(milliseconds: 500));
            await ref.read(complaintProvider.notifier).fetchComplaints();
            setState(() => _currentScreen = _previousScreen);
          },
        );

    // --- HISTORY LIST ---
      case 'history':
        return ComplaintsListScreen(
          key: const ValueKey('history'),
          onBack: () => setState(() => _currentScreen = 'dashboard'),
          onComplaintTap: (complaintMap) {
            setState(() {
              _previousScreen = 'history';
              _selectedComplaint = complaintMap;
              _currentScreen = 'detail';
            });
          },
        );

    // --- DASHBOARD (Default) ---
      case 'dashboard':
      default:
        final allComplaints = state.complaints.map((c) => c.toJson()).toList();
        return DashboardScreen(
          key: const ValueKey('dashboard'),
          complaints: allComplaints,

          onCreateComplaint: () => setState(() => _currentScreen = 'create'),

          onViewDetails: () {
            if (state.complaints.isNotEmpty) {
              setState(() {
                _previousScreen = 'dashboard';
                _selectedComplaint = state.complaints.first.toJson();
                _currentScreen = 'detail';
              });
            } else {
              setState(() => _currentScreen = 'history');
            }
          },

          onViewAllComplaints: () => setState(() => _currentScreen = 'history'),

          onLogout: _handleLogout,
        );
    }
  }

  // --- OVERLAYS ---

  Widget _buildSuccessOverlay(ComplaintState state) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: const Color(0xFF0F4C81).withOpacity(0.4),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: GlassCard(
                    intensity: 'strong',
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0xFF10B981).withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5
                                )
                              ]
                          ),
                          child: const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 64),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          "Complaint Secured",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F4C81),
                              height: 1.1
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Successfully encrypted and recorded on the Civic Blockchain.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 16,
                              height: 1.5
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showSuccessOverlay = false;
                                if (state.complaints.isNotEmpty) {
                                  _previousScreen = 'dashboard';
                                  // Pick the most recent one (assuming list is sorted desc)
                                  _selectedComplaint = state.complaints.first.toJson();
                                  _currentScreen = 'detail';
                                } else {
                                  _currentScreen = 'dashboard';
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F4C81),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: const Text(
                                "View Case Details",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}