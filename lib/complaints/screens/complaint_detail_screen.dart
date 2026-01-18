import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// --- THEME & WIDGET IMPORTS ---
// Ensure these paths match your project structure
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/magnetic_button.dart';
import '../../widgets/background_effects.dart';

// --- CONSTANTS & PROVIDERS ---
import '../../core/constants/api_constants.dart';
import '../providers/complaint_provider.dart';

class ComplaintDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> complaint;
  final VoidCallback onBack;

  const ComplaintDetailScreen({
    super.key,
    required this.complaint,
    required this.onBack,
  });

  @override
  ConsumerState<ComplaintDetailScreen> createState() =>
      _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState
    extends ConsumerState<ComplaintDetailScreen>
    with TickerProviderStateMixin {
  // ================= ANIMATION CONTROLLERS =================
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _entranceController;
  late AnimationController _successController;
  late AnimationController _starController;
  late AnimationController _wiggleController;
  late AnimationController _waveController;
  late AnimationController _tapGlowController;

  // ================= OTP STATE =================
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isRequestingOtp = false;
  bool _isConfirming = false;

  // ================= OTHER STATE =================
  bool _closureConfirmed = false;
  bool _isAppealing = false;

  // ✅ LOCAL STATUS: To update UI instantly after actions
  late String _currentStatus;

  // ================= COLORS =================
  final primaryBlue = const Color(0xFF0F4C81);
  final tealColor = const Color(0xFF4FD1C5);
  final successGreen = const Color(0xFF10B981);
  final amberColor = const Color(0xFFF59E0B);
  final slateText = const Color(0xFF64748B);
  final darkText = const Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();

    // Initialize local status from the passed data
    _currentStatus = widget.complaint['status']?.toString() ?? 'OPEN';

    _rotationController =
    AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat();

    _pulseController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _shimmerController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();

    _entranceController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

    _successController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _starController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);

    _wiggleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);

    _waveController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();

    _tapGlowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _entranceController.dispose();
    _successController.dispose();
    _starController.dispose();
    _wiggleController.dispose();
    _waveController.dispose();
    _tapGlowController.dispose();
    super.dispose();
  }

  // ================= API LOGIC =================

  Future<void> _handleRequestOtp() async {
    setState(() => _isRequestingOtp = true);
    try {
      final id = widget.complaint['id'].toString();
      await ref.read(complaintProvider.notifier).requestOtp(id);

      if (mounted) {
        setState(() {
          _otpSent = true;
          _isRequestingOtp = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🔐 OTP sent to your registered mobile")),
        );
      }
    } catch (e) {
      setState(() => _isRequestingOtp = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("OTP Error: $e")));
    }
  }

  Future<void> _handleVerifyAndClose() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter 6-digit OTP")),
      );
      return;
    }

    setState(() => _isConfirming = true);
    try {
      final id = widget.complaint['id'].toString();
      await ref
          .read(complaintProvider.notifier)
          .closeComplaint(id, _otpController.text);

      if (mounted) {
        setState(() {
          _isConfirming = false;
          _closureConfirmed = true;
          _currentStatus = 'CLOSED'; // Force update status
        });
        _successController.forward();
      }
    } catch (_) {
      setState(() => _isConfirming = false);
      _otpController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Invalid or expired OTP")),
      );
    }
  }

  Future<void> _handleAppeal() async {
    setState(() => _isAppealing = true);
    try {
      final id = widget.complaint['id'].toString();
      await ref.read(complaintProvider.notifier).appealComplaint(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Appeal submitted successfully")),
        );
        setState(() {
          _isAppealing = false;
        });
      }
    } catch (e) {
      setState(() => _isAppealing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Appeal failed: $e")),
      );
    }
  }

  // ================= HELPER: FIND LOCATION =================
  String _findLocationData() {
    final data = widget.complaint;

    // List of keys to check in order of likelihood
    final keysToCheck = [
      'location',
      'Location',
      'address',
      'Address',
      'landmark',
      'incidentLocation'
    ];

    for (var key in keysToCheck) {
      if (data[key] != null) {
        String val = data[key].toString().trim();
        if (val.isNotEmpty && val.toLowerCase() != "null") {
          return val;
        }
      }
    }

    return "No Location Provided";
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    String dateStr = "Recently";
    try {
      if (widget.complaint['createdAt'] != null) {
        final dt = DateTime.parse(widget.complaint['createdAt'].toString());
        dateStr = DateFormat('MMM d, y').format(dt);
      }
    } catch (_) {}

    // ✅ FIXED: Using the smart helper logic
    String locationDisplay = _findLocationData();
    bool isLocationValid = locationDisplay != "No Location Provided";

    // ✅ STATUS LOGIC
    final statusRaw = _currentStatus.toLowerCase().replaceAll('-', '_');
    final showAppealOption = statusRaw == 'in_progress' ||
        statusRaw == 'resolved' ||
        statusRaw == 'closed';
    final showClosurePanel = statusRaw == 'resolved' && !_closureConfirmed;
    final showSuccess = statusRaw == 'closed' || _closureConfirmed;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Stack(
        children: [
          const LiquidBackground(),
          const CanvasParticles(mouseInteractive: true),
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [tealColor.withOpacity(0.05), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== BACK BUTTON =====
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.5),
                      end: Offset.zero,
                    ).animate(_entranceController),
                    child: FadeTransition(
                      opacity: _entranceController,
                      child: MagneticButton(
                        onPressed: widget.onBack,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.9), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back,
                                  size: 20, color: slateText),
                              const SizedBox(width: 8),
                              Text(
                                "Back to Dashboard",
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ===== HERO CARD (Title, Status, ID) =====
                  FadeTransition(
                    opacity: _entranceController,
                    child: GlassCard(
                      intensity: 'strong',
                      tiltEffect: true,
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _build3DHeaderIcon(),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                            colors: [
                                              primaryBlue,
                                              const Color(0xFF0D9488)
                                            ],
                                          ).createShader(bounds),
                                      child: const Text(
                                        "Case Details",
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 8,
                                      crossAxisAlignment:
                                      WrapCrossAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.shield_outlined,
                                                size: 16, color: slateText),
                                            const SizedBox(width: 6),
                                            Text(
                                              "#${widget.complaint['id']}",
                                              style: TextStyle(
                                                color: primaryBlue,
                                                fontFamily: 'monospace',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFE0F2FE),
                                                Color(0xFFBAE6FD)
                                              ],
                                            ),
                                            borderRadius:
                                            BorderRadius.circular(20),
                                            border: Border.all(
                                                color: primaryBlue
                                                    .withOpacity(0.2)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                  Icons
                                                      .remove_red_eye_outlined,
                                                  size: 12,
                                                  color: primaryBlue),
                                              const SizedBox(width: 4),
                                              Text(
                                                "Transparency Mode",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: primaryBlue,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: _buildAnimatedStatusBadge()),
                          const SizedBox(height: 32),
                          _buildProgressBar(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ===== UPDATED INFO CARD =====
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _entranceController,
                        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
                      ),
                    ),
                    child: FadeTransition(
                      opacity: _entranceController,
                      child: GlassCard(
                        intensity: 'strong',
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.complaint['title']?.toString() ??
                                  'No Title',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: primaryBlue,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 📍 NEW UPDATED LOCATION CARD 📍
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: !isLocationValid
                                    ? Colors.red.withOpacity(0.05)
                                    : primaryBlue.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: !isLocationValid
                                      ? Colors.red.withOpacity(0.1)
                                      : primaryBlue.withOpacity(0.1),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 5,
                                        )
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      color: !isLocationValid
                                          ? Colors.redAccent
                                          : const Color(0xFFEA4335),
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "INCIDENT LOCATION",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: slateText,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          locationDisplay,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: darkText,
                                            fontWeight: FontWeight.w600,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Date & Category Row
                            Row(
                              children: [
                                _buildMetaCard(
                                    Icons.file_copy_outlined,
                                    "Category",
                                    widget.complaint['category'] ?? 'General'),
                                const SizedBox(width: 16),
                                _buildMetaCard(
                                    Icons.access_time, "Submitted", dateStr),
                              ],
                            ),

                            const SizedBox(height: 24),

                            Text(
                              "Description",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: slateText),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.complaint['description'] ??
                                  'No Description',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: darkText,
                              ),
                            ),

                            if (widget.complaint['imagePath'] != null &&
                                widget.complaint['imagePath']
                                    .toString()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 24),
                              Text(
                                "Attached Evidence",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: slateText),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  "${ApiConstants.baseUrl}/uploads/${widget.complaint['imagePath']}",
                                  height: 220,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        height: 220,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.broken_image),
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ===== TIMELINE SECTION =====
                  _buildTimelineSection(),

                  // Appeal Section
                  if (showAppealOption) _buildAppealSection(),

                  // Closure Panel (OTP)
                  if (showClosurePanel) _buildClosureSection(),

                  // Success State
                  if (showSuccess) _buildSuccessState(),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HERO HELPERS =================

  Widget _build3DHeaderIcon() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        final angle = _rotationController.value * 2 * math.pi;
        final scale = 1.0 + (_pulseController.value * 0.05);

        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: Container(
                    width: 60,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryBlue, const Color(0xFF1E40AF)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedStatusBadge() {
    final status = _currentStatus.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: tealColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tealColor.withOpacity(0.3)),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          color: tealColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Case Progress",
                style:
                TextStyle(color: slateText, fontWeight: FontWeight.w600)),
            Text(
              "${(_progressPercentage * 100).toInt()}%",
              style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: _progressPercentage,
          backgroundColor: Colors.grey[200],
          color: tealColor,
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildMetaCard(IconData icon, String label, String value) {
    return Expanded(
      child: GlassCard(
        intensity: 'light',
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: slateText),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(fontSize: 12, color: slateText)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ================= TIMELINE DATA =================

  List<Map<String, dynamic>> get _timeline {
    final steps = [
      {
        'id': 'submitted',
        'title': 'Complaint Submitted',
        'defaultDesc': 'Complaint received in system'
      },
      {
        'id': 'assigned',
        'title': 'Assigned to Department',
        'defaultDesc': 'Case assigned to specialized team'
      },
      {
        'id': 'in_progress',
        'title': 'Investigation Started',
        'defaultDesc': 'Field investigation initiated'
      },
      {
        'id': 'resolved',
        'title': 'Marked as Resolved',
        'defaultDesc': 'Issue addressed and verified'
      },
    ];

    String currentStatus = _currentStatus
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    if (currentStatus == 'open') currentStatus = 'submitted';
    if (currentStatus == 'closed') currentStatus = 'resolved';

    int currentIndex = steps.indexWhere((s) => s['id'] == currentStatus);
    if (currentIndex == -1) currentIndex = 0;

    final rawHistory =
        widget.complaint['statusHistory'] as List<dynamic>? ?? [];
    final historyIterable = rawHistory.cast<Map<String, dynamic>?>();

    return List.generate(steps.length, (index) {
      final step = steps[index];
      final stepId = step['id'];

      final isCompleted = index <= currentIndex;
      final isActive = index == currentIndex;

      final historyItem = historyIterable.firstWhere(
            (h) =>
        (h?['status'] ?? '').toString().toLowerCase().replaceAll('-', '_') ==
            stepId,
        orElse: () => null,
      );

      return {
        "id": stepId,
        "title": step['title'],
        "completed": isCompleted,
        "active": isActive,
        "isFuture": !isCompleted,
        "timestamp": historyItem != null && historyItem['createdAt'] != null
            ? DateFormat('MMM d, h:mm a')
            .format(DateTime.parse(historyItem['createdAt'].toString()))
            : null,
        "role": historyItem?['actorRole'] ?? (isCompleted ? 'System' : ''),
        "actor": historyItem?['actor'] ?? (isCompleted ? 'Automated' : ''),
        "description": historyItem?['note'] ?? step['defaultDesc'],
      };
    });
  }

  double get _progressPercentage {
    String status = _currentStatus.toUpperCase();

    if (status == 'RESOLVED' || status == 'CLOSED') return 1.0;
    if (status == 'IN_PROGRESS' || status == 'INVESTIGATION') {
      return 0.6;
    }
    if (status == 'ASSIGNED') return 0.3;
    return 0.1;
  }

  // ================= TIMELINE UI =================

  Widget _buildTimelineSection() {
    final timelineData = _timeline;

    return GlassCard(
      intensity: 'strong',
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _wiggleController,
                builder: (context, child) {
                  double angle =
                      math.sin(_wiggleController.value * 2 * math.pi) * 0.2;
                  return Transform.rotate(
                    angle: angle,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [primaryBlue, const Color(0xFF1E40AF)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.security,
                          color: Colors.white, size: 20),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Trust Timeline",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F4C81)),
                    ),
                    Text(
                      "Live blockchain updates",
                      style: TextStyle(color: slateText, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: timelineData.length,
            itemBuilder: (context, index) {
              final item = timelineData[index];
              final isLast = index == timelineData.length - 1;
              final isCompleted = item['completed'];
              final isActive = item['active'];
              final isFuture = item['isFuture'];
              final isResolvedStep = item['id'] == 'resolved';

              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: _entranceController,
                  curve: Interval(index * 0.15, 1.0, curve: Curves.easeOut),
                ),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-0.1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: _entranceController,
                      curve: Interval(index * 0.15, 1.0,
                          curve: Curves.easeOut))),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 44,
                          child: Column(
                            children: [
                              isActive
                                  ? _buildRadiatingActiveNode(
                                  showStar: isResolvedStep)
                                  : _buildStaticNode(isCompleted, isFuture),
                              if (!isLast)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    margin:
                                    const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isFuture
                                          ? Colors.grey.shade200
                                          : tealColor.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Opacity(
                              opacity: isFuture ? 0.6 : 1.0,
                              child: GlassCard(
                                intensity: isFuture
                                    ? 'light'
                                    : (isActive ? 'medium' : 'light'),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            item['title'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: isFuture
                                                    ? Colors.grey
                                                    : primaryBlue),
                                          ),
                                        ),
                                        if (item['timestamp'] != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color:
                                              primaryBlue.withOpacity(0.05),
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              item['timestamp'],
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: primaryBlue),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item['description'],
                                      style: TextStyle(
                                          color: isFuture
                                              ? Colors.grey.shade400
                                              : slateText,
                                          fontSize: 13,
                                          height: 1.4),
                                    ),
                                    if (!isFuture &&
                                        item['actor'].isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(Icons.person_outline,
                                              size: 14,
                                              color: primaryBlue
                                                  .withOpacity(0.7)),
                                          const SizedBox(width: 6),
                                          Text(
                                            "${item['actor']} • ${item['role']}",
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: slateText),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (isActive) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: successGreen.withOpacity(0.1),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                          border: Border.all(
                                              color: successGreen
                                                  .withOpacity(0.2)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 8,
                                              height: 8,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: successGreen,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              isResolvedStep
                                                  ? "Resolution Verified"
                                                  : "Processing",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: successGreen),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= TIMELINE HELPERS =================

  Widget _buildRadiatingActiveNode({bool showStar = false}) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return Stack(
                children: List.generate(3, (i) {
                  double value = (_waveController.value + (i * 0.33)) % 1.0;
                  double scale = 1.0 + (value * 1.0);
                  double opacity = (1.0 - value).clamp(0.0, 1.0);

                  return Center(
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: successGreen.withOpacity(opacity),
                              width: 2),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: successGreen,
              boxShadow: [
                BoxShadow(
                    color: successGreen.withOpacity(0.4), blurRadius: 10)
              ],
            ),
            child: const Icon(Icons.check, size: 18, color: Colors.white),
          ),
          if (showStar)
            Positioned(
              top: -4,
              right: -4,
              child: AnimatedBuilder(
                animation:
                Listenable.merge([_starController, _pulseController]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.5),
                    child: Transform.rotate(
                      angle: _starController.value * math.pi * 2,
                      child: Icon(Icons.star, color: amberColor, size: 20),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStaticNode(bool isCompleted, bool isFuture) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFuture ? Colors.white : tealColor,
        border: Border.all(
            color: isFuture ? Colors.grey.shade300 : Colors.transparent,
            width: 2),
        boxShadow: isCompleted
            ? [BoxShadow(color: tealColor.withOpacity(0.4), blurRadius: 8)]
            : [],
      ),
      child: Icon(
        isFuture ? Icons.circle_outlined : Icons.check,
        size: 16,
        color: isFuture ? Colors.grey.shade300 : Colors.white,
      ),
    );
  }

  // ✅ DEDICATED APPEAL SECTION (OUTSIDE CLOSURE PANEL)
  Widget _buildAppealSection() {
    return Column(
      children: [
        const SizedBox(height: 32),
        GlassCard(
          intensity: 'strong',
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: primaryBlue, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    "Not satisfied?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "You may appeal this complaint for senior review.",
                style: TextStyle(color: slateText),
              ),
              const SizedBox(height: 20),
              MagneticButton(
                onPressed: _isAppealing ? null : _handleAppeal,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: primaryBlue, width: 2),
                  ),
                  child: _isAppealing
                      ? const Center(child: CircularProgressIndicator())
                      : Text(
                    "Submit Appeal",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= CLOSURE / OTP PANEL =================

  // ✅ CLEANED OF APPEAL LOGIC
  Widget _buildClosureSection() {
    return Column(
      children: [
        const SizedBox(height: 32),
        GlassCard(
          intensity: 'strong',
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _rotationController,
                    builder: (ctx, child) => Transform.rotate(
                      angle:
                      math.sin(_rotationController.value * 2 * math.pi) * 0.1,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [tealColor, const Color(0xFF0D9488)]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: tealColor.withOpacity(0.4), blurRadius: 10)
                          ],
                        ),
                        child: const Icon(Icons.lock_outline,
                            color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                "Citizen Control Panel",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: primaryBlue),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.auto_awesome,
                                size: 18, color: Color(0xFF4FD1C5)),
                          ],
                        ),
                        Text(
                          "Verify resolution securely via OTP",
                          style: TextStyle(color: slateText, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child:
                !_otpSent ? _buildRequestOtpStep() : _buildVerifyOtpStep(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  // ================= OTP STEPS =================

  Widget _buildRequestOtpStep() {
    return Column(
      key: const ValueKey('requestOtp'),
      children: [
        Text(
          "Confirm your satisfaction by requesting a secure OTP sent to your registered mobile.",
          style: TextStyle(color: slateText),
        ),
        const SizedBox(height: 24),
        MagneticButton(
          onPressed: _isRequestingOtp ? null : _handleRequestOtp,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [primaryBlue, const Color(0xFF1E40AF)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: primaryBlue.withOpacity(0.4), blurRadius: 20)
              ],
            ),
            child: _isRequestingOtp
                ? const Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white)))
                : const Text(
              "Request OTP",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyOtpStep() {
    return Column(
      key: const ValueKey('verifyOtp'),
      children: [
        Text(
          "Enter the 6-digit OTP",
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, letterSpacing: 12),
          decoration: InputDecoration(
            counterText: "",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: "000000",
          ),
        ),
        const SizedBox(height: 24),
        MagneticButton(
          onPressed: _isConfirming ? null : _handleVerifyAndClose,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [successGreen, const Color(0xFF059669)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _isConfirming
                ? const Center(
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white)))
                : const Text(
              "Verify & Close Case",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() {
            _otpSent = false;
            _otpController.clear();
          }),
          child: Text("Resend OTP", style: TextStyle(color: slateText)),
        )
      ],
    );
  }

  // ================= SUCCESS STATE =================

  Widget _buildSuccessState() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: SuccessParticlesPainter(animation: _successController),
          ),
        ),
        AnimatedBuilder(
          animation: _successController,
          builder: (context, child) {
            final scale = Curves.elasticOut
                .transform(_successController.value.clamp(0.0, 1.0));
            return Transform.scale(
              scale: scale,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GlassCard(
                    intensity: 'strong',
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 64,
                            color: successGreen,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Closure Confirmed",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF064E3B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Your complaint has been securely closed.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF065F46),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: widget.onBack,
                          child: const Text("Return to Dashboard"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
} // <<< END OF STATE CLASS

// ================= PAINTERS & ANIMATION HELPERS =================

class GlowingCornersPainter extends CustomPainter {
  final Color color;
  final double progress;

  GlowingCornersPainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = color.withOpacity(progress * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final length = 25.0 * progress;

    // Top Left
    canvas.drawLine(Offset(0, length), Offset(0, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(length, 0), paint);

    // Top Right
    canvas.drawLine(
        Offset(size.width - length, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);

    // Bottom Left
    canvas.drawLine(
        Offset(0, size.height - length), Offset(0, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(length, size.height), paint);

    // Bottom Right
    canvas.drawLine(Offset(size.width - length, size.height),
        Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height - length),
        Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant GlowingCornersPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ================= SUCCESS PARTICLES =================

class SuccessParticlesPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Particle> particles = [];
  final math.Random random = math.Random();

  SuccessParticlesPainter({required this.animation})
      : super(repaint: animation) {
    // Initialize particles once
    for (int i = 0; i < 50; i++) {
      particles.add(
        Particle(
          angle: random.nextDouble() * 2 * math.pi,
          distance: random.nextDouble() * 200 + 50,
          color: [
            Colors.green,
            Colors.teal,
            Colors.amber,
            Colors.blue,
          ][random.nextInt(4)],
          size: random.nextDouble() * 8 + 2,
        ),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final progress = animation.value;
    if (progress == 0) return;

    for (final p in particles) {
      // Radial movement
      final dx = math.cos(p.angle) * p.distance * progress;
      final dy = math.sin(p.angle) * p.distance * progress;

      // Smooth fade-out
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      final paint = Paint()..color = p.color.withOpacity(opacity);

      canvas.drawCircle(
        center + Offset(dx, dy),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ================= PARTICLE MODEL =================

class Particle {
  double angle;
  double distance;
  double size;
  Color color;

  Particle({
    required this.angle,
    required this.distance,
    required this.color,
    required this.size,
  });
}