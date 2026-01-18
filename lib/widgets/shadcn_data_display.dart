import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

import 'shadcn_controls.dart'; // For Button styles

// ==========================================
// 31. PAGINATION
// ==========================================
class ShadcnPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const ShadcnPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShadcnButton(
          text: "Previous",
          ghost: true,
          onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        const SizedBox(width: 8),
        Text("Page $currentPage of $totalPages", style: ShadcnTheme.textStyle),
        const SizedBox(width: 8),
        ShadcnButton(
          text: "Next",
          ghost: true,
          onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
        ),
      ],
    );
  }
}

// ==========================================
// 32. PROGRESS
// ==========================================
class ShadcnProgress extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double? height;

  const ShadcnProgress({super.key, required this.value, this.height = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: ShadcnTheme.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: constraints.maxWidth * value.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                color: ShadcnTheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// 33. SEPARATOR (Re-included for completeness)
// ==========================================
class ShadcnSeparator extends StatelessWidget {
  final bool vertical;
  const ShadcnSeparator({super.key, this.vertical = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: vertical ? 1 : double.infinity,
      height: vertical ? double.infinity : 1,
      color: ShadcnTheme.border,
    );
  }
}

// ==========================================
// 34. SKELETON (Re-included for completeness)
// ==========================================
class ShadcnSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const ShadcnSkeleton({super.key, required this.width, required this.height, this.radius = 4});

  @override
  State<ShadcnSkeleton> createState() => _ShadcnSkeletonState();
}

class _ShadcnSkeletonState extends State<ShadcnSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (ctx, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          color: Color.lerp(ShadcnTheme.muted, Colors.grey.shade300, _controller.value),
        ),
      ),
    );
  }
}

// ==========================================
// 35. TABLE
// ==========================================
class ShadcnTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  final Map<int, double>? columnWidths; // Optional custom widths

  const ShadcnTable({super.key, required this.headers, required this.rows, this.columnWidths});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ShadcnTheme.border),
        borderRadius: BorderRadius.circular(ShadcnTheme.radiusDefault),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: ShadcnTheme.border)),
              color: ShadcnTheme.muted,
            ),
            child: Row(
              children: headers.asMap().entries.map((entry) {
                final width = columnWidths?[entry.key];
                return width != null
                    ? SizedBox(width: width, child: Text(entry.value, style: ShadcnTheme.small))
                    : Expanded(child: Text(entry.value, style: ShadcnTheme.small));
              }).toList(),
            ),
          ),
          // Rows
          ...rows.map((row) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: ShadcnTheme.border)),
            ),
            child: Row(
              children: row.asMap().entries.map((entry) {
                final width = columnWidths?[entry.key];
                return width != null
                    ? SizedBox(width: width, child: Text(entry.value, style: ShadcnTheme.textStyle))
                    : Expanded(child: Text(entry.value, style: ShadcnTheme.textStyle));
              }).toList(),
            ),
          )),
        ],
      ),
    );
  }
}