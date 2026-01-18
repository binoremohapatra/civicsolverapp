import 'package:flutter/material.dart';
import '../theme/app_theme.dart'; // Adjust if your theme is in lib/theme.dart

// ===========================================================================
// 1. BUTTONS
// ===========================================================================

class ShadcnButton extends StatefulWidget {
  final String? text;
  final Widget? icon;
  final VoidCallback? onPressed;
  final bool useGradient;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool outline;
  final bool ghost;
  final bool widthFull;
  final double? height;

  const ShadcnButton({
    super.key,
    this.text,
    this.icon,
    required this.onPressed,
    this.useGradient = false,
    this.backgroundColor,
    this.foregroundColor,
    this.outline = false,
    this.ghost = false,
    this.widthFull = false,
    this.height,
  });

  factory ShadcnButton.primary({required String text, required VoidCallback onPressed, Widget? icon}) {
    return ShadcnButton(text: text, icon: icon, onPressed: onPressed);
  }

  factory ShadcnButton.secondary({required String text, required VoidCallback onPressed, Widget? icon}) {
    return ShadcnButton(
      text: text,
      icon: icon,
      onPressed: onPressed,
      backgroundColor: ShadcnTheme.secondary,
      foregroundColor: ShadcnTheme.secondaryForeground,
    );
  }

  factory ShadcnButton.destructive({required String text, required VoidCallback onPressed, Widget? icon}) {
    return ShadcnButton(
      text: text,
      icon: icon,
      onPressed: onPressed,
      backgroundColor: ShadcnTheme.destructive,
      foregroundColor: ShadcnTheme.destructiveForeground,
    );
  }

  factory ShadcnButton.outline({required String text, required VoidCallback onPressed, Widget? icon}) {
    return ShadcnButton(text: text, icon: icon, onPressed: onPressed, outline: true);
  }

  factory ShadcnButton.ghost({required String text, required VoidCallback onPressed, Widget? icon}) {
    return ShadcnButton(text: text, icon: icon, onPressed: onPressed, ghost: true);
  }

  factory ShadcnButton.gradient({required String text, required VoidCallback onPressed}) {
    return ShadcnButton(text: text, onPressed: onPressed, useGradient: true, foregroundColor: Colors.white);
  }

  @override
  State<ShadcnButton> createState() => _ShadcnButtonState();
}

class _ShadcnButtonState extends State<ShadcnButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor = widget.backgroundColor ?? ShadcnTheme.primary;
    Color fgColor = widget.foregroundColor ?? ShadcnTheme.primaryForeground;
    Border? border;

    if (widget.outline) {
      bgColor = Colors.transparent;
      fgColor = ShadcnTheme.foreground;
      border = Border.all(color: ShadcnTheme.border);
    } else if (widget.ghost) {
      bgColor = Colors.transparent;
      fgColor = ShadcnTheme.foreground;
    }

    // Hover effect logic
    if (_isHovered) {
      if (widget.outline || widget.ghost) {
        bgColor = ShadcnTheme.muted; // Faded hover background
      }
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onPressed == null ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: widget.onPressed == null ? 0.5 : (_isHovered && !widget.ghost && !widget.outline ? 0.9 : 1.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.widthFull ? double.infinity : null,
            height: widget.height ?? 44,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: widget.useGradient ? null : bgColor,
              gradient: widget.useGradient ? ShadcnTheme.primaryGradient : null,
              borderRadius: BorderRadius.circular(ShadcnTheme.radiusDefault),
              border: border,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  IconTheme(data: IconThemeData(size: 18, color: fgColor), child: widget.icon!),
                  if (widget.text != null) const SizedBox(width: 8),
                ],
                if (widget.text != null)
                  Text(
                    widget.text!,
                    style: ShadcnTheme.textStyle.copyWith(color: fgColor, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// 2. BADGE
// ===========================================================================

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: outline ? Colors.transparent : (backgroundColor ?? ShadcnTheme.primary),
        border: outline ? Border.all(color: ShadcnTheme.border) : null,
        borderRadius: BorderRadius.circular(ShadcnTheme.radiusSm),
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

// ===========================================================================
// 3. AVATAR
// ===========================================================================

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

// ===========================================================================
// 4. SEPARATOR
// ===========================================================================

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