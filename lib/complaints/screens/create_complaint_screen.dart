import 'dart:io'; // Added for File
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Added for Image Picker
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/magnetic_button.dart';
import '../../widgets/background_effects.dart';

class CreateComplaintScreen extends StatefulWidget {
  final VoidCallback onBack;
  // Updated signature to accept dynamic to include File path or null
  final ValueChanged<Map<String, dynamic>> onSubmit;

  const CreateComplaintScreen({
    super.key,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  State<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends State<CreateComplaintScreen> with TickerProviderStateMixin {
  // Form State
  String _title = "";
  String _description = "";
  String _location = "";
  String _category = "";
  File? _selectedImage; // Added Image State
  bool _isSubmitting = false;
  bool _showHints = false;

  // Animation Controllers
  late AnimationController _rotationController;
  late AnimationController _shimmerController;
  late AnimationController _progressController;

  // Focus Nodes
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _locationFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();

  // Image Picker
  final ImagePicker _picker = ImagePicker();

  // Progress tracking
  double _titleProgress = 0.0;
  double _descProgress = 0.0;
  double _overallProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      upperBound: 1.0,
    );

    void update() => setState(() {});
    _categoryFocus.addListener(update);
    _titleFocus.addListener(update);
    _locationFocus.addListener(update);
    _descFocus.addListener(update);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _shimmerController.dispose();
    _progressController.dispose();
    _categoryFocus.dispose();
    _titleFocus.dispose();
    _locationFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  // --- Image Picking Logic ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _calculateProgress(); // Recalculate progress on image add
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Attach Evidence", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81))),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceButton(Icons.camera_alt_outlined, "Camera", () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                }),
                _buildSourceButton(Icons.photo_library_outlined, "Gallery", () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0F4C81).withOpacity(0.1)),
            ),
            child: Icon(icon, size: 30, color: const Color(0xFF0F4C81)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  void _updateProgress(String field, String value) {
    setState(() {
      if (field == 'title') {
        _title = value;
        _titleProgress = (value.length / 50).clamp(0.0, 1.0);
      } else if (field == 'description') {
        _description = value;
        _descProgress = (value.length / 200).clamp(0.0, 1.0);
      } else if (field == 'location') {
        _location = value;
      } else if (field == 'category') {
        _category = value;
      }
      _calculateProgress();
    });
  }

  void _calculateProgress() {
    int filledCount = 0;
    if (_title.isNotEmpty) filledCount++;
    if (_description.isNotEmpty) filledCount++;
    if (_location.isNotEmpty) filledCount++;
    if (_category.isNotEmpty) filledCount++;

    // Image is optional but recommended, let's keep progress based on text fields for mandatory 100%
    // Or we can make it a bonus. For now, sticking to the 4 mandatory fields.
    _overallProgress = filledCount / 4;

    _progressController.animateTo(_overallProgress, curve: Curves.easeOut);
  }

  void _submit() async {
    if (_title.isNotEmpty && _description.isNotEmpty && _location.isNotEmpty && _category.isNotEmpty) {
      setState(() => _isSubmitting = true);
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      widget.onSubmit({
        "title": _title,
        "description": _description,
        "location": _location,
        "category": _category,
        "imagePath": _selectedImage?.path ?? "", // Pass image path
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = const Color(0xFF0F4C81);
    final tealColor = const Color(0xFF4FD1C5);
    final slateText = const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Stack(
        children: [
          const LiquidBackground(),
          const CanvasParticles(),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.8),
                  radius: 1.5,
                  colors: [tealColor.withOpacity(0.1), Colors.transparent],
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
                  // --- BACK BUTTON ---
                  MagneticButton(
                    onPressed: widget.onBack,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.9)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, size: 20, color: slateText),
                          const SizedBox(width: 8),
                          Text("Back to Dashboard", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- HEADER CARD ---
                  GlassCard(
                    intensity: 'strong',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  _build3DIcon(primaryBlue, tealColor),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: ShaderMask(
                                            shaderCallback: (bounds) => LinearGradient(
                                              colors: [primaryBlue, const Color(0xFF0D9488)],
                                            ).createShader(bounds),
                                            child: const Text(
                                              "New Complaint",
                                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Submit your civic concern",
                                          style: TextStyle(color: slateText, fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),
                            _buildProgressRing(primaryBlue, tealColor),
                          ],
                        ),

                        const SizedBox(height: 24),

                        GestureDetector(
                          onTap: () => setState(() => _showHints = !_showHints),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)]),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: primaryBlue.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.info_outline, size: 16, color: primaryBlue),
                                const SizedBox(width: 8),
                                Text(
                                  _showHints ? "Hide Smart Hints" : "Show Smart Hints",
                                  style: TextStyle(color: primaryBlue, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- PREMIUM BANNER ---
                  _buildPremiumBanner(),

                  const SizedBox(height: 32),

                  // --- FORM ---
                  GlassCard(
                    intensity: 'strong',
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildAnimatedFieldWrapper(
                          label: "Category",
                          isRequired: true,
                          isCompleted: _category.isNotEmpty,
                          showHint: _showHints && _category.isEmpty,
                          hintText: "Choose the category that best matches for faster routing",
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _categoryFocus.hasFocus ? tealColor : primaryBlue.withOpacity(0.2), width: 2),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _category.isEmpty ? null : _category,
                                hint: Text("Select a category...", style: TextStyle(color: slateText)),
                                isExpanded: true,
                                icon: Icon(Icons.keyboard_arrow_down, color: slateText),
                                focusNode: _categoryFocus,
                                items: const [
                                  DropdownMenuItem(value: "infrastructure", child: Text("🏗️ Infrastructure & Roads")),
                                  DropdownMenuItem(value: "sanitation", child: Text("🗑️ Sanitation & Waste")),
                                  DropdownMenuItem(value: "public-safety", child: Text("🚨 Public Safety")),
                                  DropdownMenuItem(value: "utilities", child: Text("⚡ Utilities & Services")),
                                  DropdownMenuItem(value: "environment", child: Text("🌳 Environment")),
                                ],
                                onChanged: (val) => _updateProgress('category', val!),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        _buildAnimatedFieldWrapper(
                          label: "Complaint Title",
                          isRequired: true,
                          isCompleted: _title.isNotEmpty,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildTextField(
                                value: _title,
                                onChanged: (val) => _updateProgress('title', val),
                                focusNode: _titleFocus,
                                hint: "Brief, clear summary...",
                                maxLength: 100,
                              ),
                              const SizedBox(height: 8),
                              _buildMiniProgressBar(_titleProgress, tealColor, primaryBlue, "${_title.length}/100"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        _buildAnimatedFieldWrapper(
                          label: "Location",
                          isRequired: true,
                          isCompleted: _location.isNotEmpty,
                          child: _buildTextField(
                            value: _location,
                            onChanged: (val) => _updateProgress('location', val),
                            focusNode: _locationFocus,
                            hint: "Street address or landmark...",
                            icon: Icons.location_on_outlined,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- NEW: PHOTO ADD OPTION ---
                        _buildAnimatedFieldWrapper(
                          label: "Evidence Photo",
                          isRequired: false, // Optional
                          isCompleted: _selectedImage != null,
                          showHint: _showHints && _selectedImage == null,
                          hintText: "Photos increase resolution speed by 40%",
                          child: GestureDetector(
                            onTap: _showImageSourceModal,
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: primaryBlue.withOpacity(0.2),
                                    width: 2,
                                    style: BorderStyle.solid
                                ),
                              ),
                              child: _selectedImage != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(_selectedImage!, fit: BoxFit.cover),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() => _selectedImage = null);
                                          _calculateProgress();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.edit, color: Colors.white, size: 12),
                                            SizedBox(width: 4),
                                            Text("Change", style: TextStyle(color: Colors.white, fontSize: 10)),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                                  : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, size: 32, color: primaryBlue.withOpacity(0.5)),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Tap to upload photo",
                                    style: TextStyle(
                                      color: primaryBlue.withOpacity(0.5),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                        // -----------------------------

                        _buildAnimatedFieldWrapper(
                          label: "Detailed Description",
                          isRequired: true,
                          isCompleted: _description.isNotEmpty,
                          showHint: _showHints && _description.isEmpty,
                          hintText: "Be specific & objective",
                          child: Column(
                            children: [
                              _buildTextField(
                                value: _description,
                                onChanged: (val) => _updateProgress('description', val),
                                focusNode: _descFocus,
                                hint: "Provide comprehensive details...",
                                maxLines: 6,
                                maxLength: 1000,
                              ),
                              const SizedBox(height: 8),
                              _buildMiniProgressBar(_descProgress, tealColor, primaryBlue, "${_description.length}/1000"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        _buildSubmitButton(primaryBlue),

                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shield_outlined, size: 16, color: primaryBlue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "End-to-end encrypted • Blockchain verified",
                                style: TextStyle(color: slateText, fontWeight: FontWeight.w500, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  // --- WIDGET BUILDERS ---

  Widget _build3DIcon(Color primary, Color accent) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        double angle = _rotationController.value * 2 * math.pi;
        return SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform(
                transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
                alignment: Alignment.center,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primary, const Color(0xFF1E40AF), primary],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: primary.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
                    ],
                  ),
                  child: const Center(child: Icon(Icons.description_outlined, color: Colors.white, size: 30)),
                ),
              ),
              _buildOrbitingDot(angle, 0, accent),
              _buildOrbitingDot(angle, 2 * math.pi / 3, accent),
              _buildOrbitingDot(angle, 4 * math.pi / 3, accent),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrbitingDot(double angle, double offset, Color color) {
    double r = 40.0;
    return Transform.translate(
      offset: Offset(r * math.cos(angle + offset), r * math.sin(angle + offset)),
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 4)],
        ),
      ),
    );
  }

  Widget _buildProgressRing(Color primary, Color accent) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 60, height: 60,
            child: CircularProgressIndicator(value: 1.0, strokeWidth: 6, valueColor: AlwaysStoppedAnimation(const Color(0xFFE2E8F0))),
          ),
          SizedBox(
            width: 60, height: 60,
            child: AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return CustomPaint(
                  painter: GradientArcPainter(
                    progress: _progressController.value,
                    gradient: LinearGradient(colors: [accent, primary, const Color(0xFF10B981)]),
                    width: 6,
                  ),
                );
              },
            ),
          ),
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              bool isComplete = _progressController.value >= 1.0;
              return isComplete
                  ? Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Color(0xFF6EE7B7), Color(0xFF10B981)]),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              )
                  : Text("${(_progressController.value * 100).toInt()}%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primary));
            },
          ),
        ],
      ),
    );
  }

  // --- PREMIUM BANNER ---
  Widget _buildPremiumBanner() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            // Premium Amber/Gold Gradient Background
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFFBEB).withOpacity(0.95), // Warm White
                const Color(0xFFFEF3C7).withOpacity(0.8),  // Soft Amber
              ],
            ),
            border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: StripedPatternPainter(
                      offset: _shimmerController.value * 40,
                      opacity: 0.05,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 2),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 1.0 + (0.05 * math.sin(value * math.pi * 2)),
                              child: const Icon(Icons.security, color: Color(0xFFD97706), size: 30),
                            );
                          },
                          onEnd: () {},
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    "Immutable Protocol",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      color: Color(0xFF92400E),
                                      letterSpacing: -0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFEF3C7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Transform.rotate(
                                    angle: _shimmerController.value * 2 * math.pi,
                                    child: const Icon(Icons.bolt, color: Color(0xFFD97706), size: 16),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              "Complaints are permanently recorded on the blockchain. Once submitted, they cannot be edited.",
                              style: TextStyle(
                                color: Color(0xFFB45309),
                                height: 1.5,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            const SizedBox(height: 16),

                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildPremiumTag(Icons.lock_outline, "256-bit Encrypted"),
                                _buildPremiumTag(Icons.verified_outlined, "Blockchain Verified"),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFD97706)),
          const SizedBox(width: 6),
          Text(
              text,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFB45309),
                  fontWeight: FontWeight.w700
              )
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFieldWrapper({
    required String label, required bool isRequired, required bool isCompleted,
    required Widget child, bool showHint = false, String hintText = "",
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            if (isRequired) const Text(" *", style: TextStyle(color: Colors.red)),
            if (isCompleted) ...[const SizedBox(width: 8), const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18)]
          ],
        ),
        const SizedBox(height: 12),
        child,
        if (showHint)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF0F4C81).withOpacity(0.2)),
            ),
            child: Row(children: [const Icon(Icons.auto_awesome, color: Color(0xFF0F4C81), size: 16), const SizedBox(width: 8), Expanded(child: Text(hintText, style: const TextStyle(color: Color(0xFF0F4C81), fontSize: 13, fontWeight: FontWeight.w600)))]),
          ),
      ],
    );
  }

  Widget _buildTextField({required String value, required ValueChanged<String> onChanged, required FocusNode focusNode, required String hint, IconData? icon, int maxLines = 1, int? maxLength}) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF0F4C81).withOpacity(0.2), width: 2),
            boxShadow: [if (focusNode.hasFocus) BoxShadow(color: const Color(0xFF4FD1C5).withOpacity(0.3), blurRadius: 8, spreadRadius: 2)],
          ),
          child: TextFormField(
            initialValue: value, focusNode: focusNode, onChanged: onChanged, maxLines: maxLines, maxLength: maxLength,
            style: const TextStyle(fontSize: 16, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: hint, hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF0F4C81)) : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20), border: InputBorder.none, counterText: "",
            ),
          ),
        ),
        Positioned(
          bottom: 0, left: 16, right: 16,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300), height: 3, width: double.infinity,
            transform: Matrix4.identity()..scale(focusNode.hasFocus ? 1.0 : 0.0, 1.0), transformAlignment: Alignment.center,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4FD1C5), Color(0xFF0F4C81), Color(0xFF4FD1C5)]), borderRadius: BorderRadius.circular(2)),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniProgressBar(double progress, Color startColor, Color endColor, String countText) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 6, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(3)),
            alignment: Alignment.centerLeft,
            child: AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 300), widthFactor: progress == 0 ? 0.01 : progress,
              child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [startColor, endColor]), borderRadius: BorderRadius.circular(3))),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(countText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildSubmitButton(Color primaryBlue) {
    bool isValid = _overallProgress == 1.0;
    return MagneticButton(
      onPressed: isValid && !_isSubmitting ? _submit : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), width: double.infinity, height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isValid && !_isSubmitting ? LinearGradient(colors: [primaryBlue, const Color(0xFF1E40AF), primaryBlue]) : const LinearGradient(colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)]),
          boxShadow: isValid && !_isSubmitting ? [BoxShadow(color: primaryBlue.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))] : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isValid && !_isSubmitting)
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) => Positioned.fill(
                    child: FractionallySizedBox(widthFactor: 0.5, alignment: Alignment((_shimmerController.value * 4) - 2, 0), child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.white.withOpacity(0.3), Colors.transparent])))),
                  ),
                ),
              _isSubmitting
                  ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: primaryBlue, strokeWidth: 3)), const SizedBox(width: 12), Text("Securing Complaint...", style: TextStyle(color: primaryBlue, fontSize: 18, fontWeight: FontWeight.bold))])
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.send, color: isValid ? Colors.white : const Color(0xFF94A3B8)), const SizedBox(width: 12), Text("Submit Official Complaint", style: TextStyle(color: isValid ? Colors.white : const Color(0xFF94A3B8), fontSize: 18, fontWeight: FontWeight.bold)), if (isValid) ...[const SizedBox(width: 8), const Icon(Icons.arrow_forward, color: Colors.white, size: 20)]]),
            ],
          ),
        ),
      ),
    );
  }
}

class GradientArcPainter extends CustomPainter {
  final double progress;
  final Gradient gradient;
  final double width;
  GradientArcPainter({required this.progress, required this.gradient, required this.width});
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = width..strokeCap = StrokeCap.round..shader = gradient.createShader(rect);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, paint);
  }
  @override
  bool shouldRepaint(covariant GradientArcPainter oldDelegate) => oldDelegate.progress != progress;
}

class StripedPatternPainter extends CustomPainter {
  final double offset;
  final double opacity;

  StripedPatternPainter({required this.offset, this.opacity = 0.15});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFFBBF24).withOpacity(opacity)..strokeWidth = 10;
    for (double i = -size.height; i < size.width; i += 20) {
      canvas.drawLine(Offset(i + offset % 20, 0), Offset(i + offset % 20 + size.height, size.height), paint);
    }
  }
  @override
  bool shouldRepaint(covariant StripedPatternPainter oldDelegate) => oldDelegate.offset != offset;
}