import 'package:flutter/material.dart';
import '../theme/app_theme.dart';


// ==========================================
// 1. ACCORDION
// ==========================================
class ShadcnAccordionItem extends StatefulWidget {
  final String title;
  final Widget content;
  final bool initialOpen;

  const ShadcnAccordionItem({
    super.key,
    required this.title,
    required this.content,
    this.initialOpen = false,
  });

  @override
  State<ShadcnAccordionItem> createState() => _ShadcnAccordionItemState();
}

class _ShadcnAccordionItemState extends State<ShadcnAccordionItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late bool _isOpen;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.initialOpen;
    _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));
    if (_isOpen) _controller.value = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ShadcnTheme.border)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isOpen = !_isOpen;
                if (_isOpen) _controller.forward(); else _controller.reverse();
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.title, style: ShadcnTheme.textStyle.copyWith(fontWeight: FontWeight.w500)),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
                    child: const Icon(Icons.keyboard_arrow_down, size: 16, color: ShadcnTheme.mutedForeground),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _heightFactor,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DefaultTextStyle(style: ShadcnTheme.textStyle, child: widget.content),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. ALERT DIALOG
// ==========================================
Future<T?> showShadcnAlertDialog<T>({
  required BuildContext context,
  required String title,
  required String description,
  required VoidCallback onContinue,
  VoidCallback? onCancel,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Dismiss",
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, _, __) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 512),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ShadcnTheme.background,
            borderRadius: BorderRadius.circular(ShadcnTheme.radiusLg), // 24.0
            border: Border.all(color: ShadcnTheme.border),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: ShadcnTheme.textStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(description, style: ShadcnTheme.textStyle.copyWith(color: ShadcnTheme.mutedForeground)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      if (onCancel != null) onCancel();
                      Navigator.pop(ctx);
                    },
                    style: TextButton.styleFrom(foregroundColor: ShadcnTheme.foreground),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      onContinue();
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ShadcnTheme.primary,
                      foregroundColor: ShadcnTheme.primaryForeground,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShadcnTheme.radiusDefault)),
                    ),
                    child: const Text("Continue"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    transitionBuilder: (_, anim, __, child) => Transform.scale(
      scale: 0.95 + (0.05 * Curves.easeOut.transform(anim.value)),
      child: Opacity(opacity: anim.value, child: child),
    ),
  );
}

// ==========================================
// 3. ALERT (Static)
// ==========================================
class ShadcnAlert extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool destructive;

  const ShadcnAlert({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? ShadcnTheme.destructive : ShadcnTheme.foreground;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: destructive ? ShadcnTheme.destructive.withOpacity(0.05) : Colors.white,
        border: Border.all(color: destructive ? ShadcnTheme.destructive.withOpacity(0.5) : ShadcnTheme.border),
        borderRadius: BorderRadius.circular(ShadcnTheme.radiusDefault), // 16.0
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ShadcnTheme.textStyle.copyWith(fontWeight: FontWeight.w500, color: color)),
                const SizedBox(height: 4),
                Text(description, style: ShadcnTheme.textStyle.copyWith(color: destructive ? color.withOpacity(0.9) : ShadcnTheme.mutedForeground)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. ASPECT RATIO
// ==========================================
class ShadcnAspectRatio extends StatelessWidget {
  final double ratio;
  final Widget child;
  const ShadcnAspectRatio({super.key, required this.ratio, required this.child});

  @override
  Widget build(BuildContext context) => AspectRatio(aspectRatio: ratio, child: child);
}

// ==========================================
// 5. AVATAR
// ==========================================
class ShadcnAvatar extends StatelessWidget {
  final String? src;
  final String fallback;
  final double size;

  const ShadcnAvatar({super.key, this.src, required this.fallback, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: ShadcnTheme.muted),
      child: src != null
          ? Image.network(src!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildFallback())
          : _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Text(
        fallback,
        style: ShadcnTheme.textStyle.copyWith(fontWeight: FontWeight.w500, color: ShadcnTheme.mutedForeground),
      ),
    );
  }
}

// ==========================================
// 6. BADGE
// ==========================================
class ShadcnBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool outline;

  const ShadcnBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.outline = false,
  });

  factory ShadcnBadge.secondary({required String label}) {
    return ShadcnBadge(
        label: label,
        backgroundColor: ShadcnTheme.secondary,
        foregroundColor: ShadcnTheme.secondaryForeground
    );
  }

  factory ShadcnBadge.destructive({required String label}) {
    return ShadcnBadge(
      label: label,
      backgroundColor: ShadcnTheme.destructive,
      foregroundColor: ShadcnTheme.destructiveForeground,
    );
  }

  factory ShadcnBadge.outline({required String label}) {
    return ShadcnBadge(label: label, outline: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: outline ? Colors.transparent : (backgroundColor ?? ShadcnTheme.primary),
        border: outline ? Border.all(color: ShadcnTheme.border) : null,
        borderRadius: BorderRadius.circular(ShadcnTheme.radiusSm), // 8.0
      ),
      child: Text(
        label,
        style: ShadcnTheme.textStyle.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: outline ? ShadcnTheme.foreground : (foregroundColor ?? ShadcnTheme.primaryForeground),
        ),
      ),
    );
  }
}