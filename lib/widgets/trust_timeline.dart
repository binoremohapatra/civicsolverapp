import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ✅ CRITICAL IMPORT: This links the widget to your model class
import '../complaints/models/complaint_model.dart';


class TrustTimeline extends StatelessWidget {
  // We use List<StatusUpdate>? to handle cases where history might be null
  final List<StatusUpdate>? updates;

  const TrustTimeline({super.key, required this.updates});

  @override
  Widget build(BuildContext context) {
    // Safety check: if updates is null, treat it as empty
    final safeUpdates = updates ?? [];

    if (safeUpdates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "No updates recorded yet.",
            style: GoogleFonts.inter(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: safeUpdates.length,
      itemBuilder: (context, index) {
        final update = safeUpdates[index];
        final isLast = index == safeUpdates.length - 1;
        final isFirst = index == 0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Timeline Graphics ---
            Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isFirst ? const Color(0xFF0F4C81) : Colors.grey.shade300,
                    shape: BoxShape.circle,
                    border: isFirst
                        ? Border.all(color: const Color(0xFF0F4C81).withOpacity(0.3), width: 4)
                        : null,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60, // Minimum height to connect dots
                    color: Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // --- Text Content ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatStatus(update.status),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a').format(update.timestamp),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    // Only show note if it exists and isn't empty
                    if (update.note != null && update.note!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          update.note!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF334155),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatStatus(String rawStatus) {
    if (rawStatus.isEmpty) return "Unknown";
    // Convert "IN_PROGRESS" -> "In Progress"
    return rawStatus
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1)}'
        : '')
        .join(' ');
  }
}