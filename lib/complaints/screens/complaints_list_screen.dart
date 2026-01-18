import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

// --- THEME & WIDGET IMPORTS ---
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/magnetic_button.dart';
import '../../widgets/background_effects.dart';

// --- PROVIDER IMPORT ---
import '../providers/complaint_provider.dart';

class ComplaintsListScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final Function(Map<String, dynamic>) onComplaintTap;

  const ComplaintsListScreen({
    super.key,
    required this.onBack,
    required this.onComplaintTap,
  });

  @override
  ConsumerState<ComplaintsListScreen> createState() =>
      _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends ConsumerState<ComplaintsListScreen>
    with TickerProviderStateMixin {
  final primaryBlue = const Color(0xFF0F4C81);
  final tealColor = const Color(0xFF4FD1C5);
  final successGreen = const Color(0xFF10B981);
  final amberColor = const Color(0xFFF59E0B);
  final slateText = const Color(0xFF64748B);

  late AnimationController _entranceController;

  // 0 = Active, 1 = History
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // ✅ FORCE FETCH WHEN SCREEN OPENS
    Future.microtask(() {
      ref.read(complaintProvider.notifier).fetchComplaints();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final complaintState = ref.watch(complaintProvider);

    final allComplaints =
    complaintState.complaints.map((c) => c.toJson()).toList();

    final activeComplaints = allComplaints.where((c) {
      final status = c['status']?.toString().toLowerCase().trim() ?? 'open';
      return status != 'resolved' && status != 'closed';
    }).toList();

    final historyComplaints = allComplaints.where((c) {
      final status = c['status']?.toString().toLowerCase().trim() ?? 'open';
      return status == 'resolved' || status == 'closed';
    }).toList();

    final currentList =
    _selectedTab == 0 ? activeComplaints : historyComplaints;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Stack(
        children: [
          const LiquidBackground(),
          const CanvasParticles(mouseInteractive: true),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),

                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: _buildTabSwitcher(),
                )
                    .animate(controller: _entranceController)
                    .fade(duration: 400.ms)
                    .slideY(begin: -0.2, end: 0),

                Expanded(
                  child: complaintState.isLoading && currentList.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : currentList.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(complaintProvider.notifier)
                          .fetchComplaints();
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                          24, 0, 24, 24),
                      itemCount: currentList.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildComplaintCard(
                            currentList[index], index);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ================= TAB SWITCHER =================

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTabButton("Active Cases", 0),
          _buildTabButton("Past History", 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : slateText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ================= EMPTY STATE =================

  Widget _buildEmptyState() {
    final isHistory = _selectedTab == 1;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isHistory ? Icons.history : Icons.check_circle_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            isHistory ? "No past history" : "All caught up!",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= APP BAR =================

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MagneticButton(
            onPressed: () {
              ref.read(complaintProvider.notifier).fetchComplaints();
              widget.onBack();
            },
            child: Icon(Icons.arrow_back, color: primaryBlue),
          ),
          Text(
            "My Complaints",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: primaryBlue,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ================= COMPLAINT CARD =================

  Widget _buildComplaintCard(
      Map<String, dynamic> complaint, int index) {
    final status =
        complaint['status']?.toString().toLowerCase().trim() ?? 'open';

    Color statusColor = primaryBlue;
    if (status == 'resolved' || status == 'closed') {
      statusColor = successGreen;
    } else if (status == 'in_progress') {
      statusColor = amberColor;
    }

    final dateStr = complaint['createdAt'] != null
        ? DateFormat('MMM d, y')
        .format(DateTime.parse(complaint['createdAt']))
        : "Recently";

    return MagneticButton(
      onPressed: () async {
        await widget.onComplaintTap(complaint);
        await ref
            .read(complaintProvider.notifier)
            .fetchComplaints();
      },
      child: GlassCard(
        intensity: 'medium',
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              complaint['title'] ?? "Untitled Complaint",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              complaint['description'] ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: statusColor),
                ),
                const Spacer(),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fade(duration: 600.ms, delay: (index * 80).ms)
        .slideX(begin: 0.1, end: 0);
  }
}
