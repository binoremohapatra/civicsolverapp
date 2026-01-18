import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';


// ==========================================
// 7. BUTTON (Re-included for completeness)
// ==========================================
class ShadcnButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool ghost;
  final bool outline;
  final bool secondary;
  final bool destructive;
  final Widget? icon;

  const ShadcnButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.ghost = false,
    this.outline = false,
    this.secondary = false,
    this.destructive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = ShadcnTheme.primary;
    Color fg = ShadcnTheme.primaryForeground;
    BorderSide side = BorderSide.none;

    if (destructive) {
      bg = ShadcnTheme.destructive;
      fg = ShadcnTheme.destructiveForeground;
    } else if (secondary) {
      bg = ShadcnTheme.secondary;
      fg = ShadcnTheme.secondaryForeground;
    } else if (outline) {
      bg = Colors.transparent;
      fg = ShadcnTheme.foreground;
      side = const BorderSide(color: ShadcnTheme.border);
    } else if (ghost) {
      bg = Colors.transparent;
      fg = ShadcnTheme.foreground;
    }

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShadcnTheme.radiusDefault),
          side: side,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 8)],
          Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ==========================================
// 8. BREADCRUMB
// ==========================================
class ShadcnBreadcrumb extends StatelessWidget {
  final List<String> items;
  final ValueChanged<int>? onTap;

  const ShadcnBreadcrumb({super.key, required this.items, this.onTap});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (int i = 0; i < items.length; i++) {
      final isLast = i == items.length - 1;
      children.add(
        InkWell(
          onTap: isLast ? null : () => onTap?.call(i),
          child: Text(
            items[i],
            style: ShadcnTheme.textStyle.copyWith(
              color: isLast ? ShadcnTheme.foreground : ShadcnTheme.mutedForeground,
              fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      );
      if (!isLast) {
        children.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.chevron_right, size: 14, color: ShadcnTheme.mutedForeground),
        ));
      }
    }
    return Row(children: children);
  }
}

// ==========================================
// 9. CALENDAR (Simple Month View)
// ==========================================
class ShadcnCalendar extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const ShadcnCalendar({super.key, required this.selectedDate, required this.onDateSelected});

  @override
  State<ShadcnCalendar> createState() => _ShadcnCalendarState();
}

class _ShadcnCalendarState extends State<ShadcnCalendar> {
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ShadcnTheme.card,
        borderRadius: BorderRadius.circular(ShadcnTheme.radiusDefault),
        border: Border.all(color: ShadcnTheme.border),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildDaysGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 16),
          onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
        ),
        Text(DateFormat('MMMM yyyy').format(_focusedMonth), style: ShadcnTheme.textStyle.copyWith(fontWeight: FontWeight.w600)),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 16),
          onPressed: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
        ),
      ],
    );
  }

  Widget _buildDaysGrid() {
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final offset = firstDay.weekday - 1; // Mon=0

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 2, crossAxisSpacing: 2),
      itemCount: daysInMonth + offset,
      itemBuilder: (context, index) {
        if (index < offset) return const SizedBox();
        final day = index - offset + 1;
        final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
        final isSelected = widget.selectedDate != null && DateUtils.isSameDay(date, widget.selectedDate);
        final isToday = DateUtils.isSameDay(date, DateTime.now());

        return GestureDetector(
          onTap: () => widget.onDateSelected(date),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? ShadcnTheme.primary : (isToday ? ShadcnTheme.accent : Colors.transparent),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "$day",
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? ShadcnTheme.primaryForeground : (isToday ? ShadcnTheme.accentForeground : ShadcnTheme.foreground),
              ),
            ),
          ),
        );
      },
    );
  }
}