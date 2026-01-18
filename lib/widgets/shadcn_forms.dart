import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

import 'shadcn_controls.dart'; // Needed for Button styles if used internally

// ==========================================
// 13. CHECKBOX
// ==========================================
class ShadcnCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  const ShadcnCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: value ? ShadcnTheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: value ? ShadcnTheme.primary : ShadcnTheme.foreground,
                width: 1,
              ),
            ),
            child: value
                ? const Icon(Icons.check, size: 12, color: ShadcnTheme.primaryForeground)
                : null,
          ),
          if (label != null) ...[
            const SizedBox(width: 8),
            Text(label!, style: ShadcnTheme.textStyle.copyWith(fontWeight: FontWeight.w500)),
          ]
        ],
      ),
    );
  }
}

// ==========================================
// 14. INPUT (Text Field)
// ==========================================
class ShadcnInput extends StatelessWidget {
  final String? placeholder;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  const ShadcnInput({
    super.key,
    this.placeholder,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      maxLines: maxLines,
      style: ShadcnTheme.textStyle,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: ShadcnTheme.textStyle.copyWith(color: ShadcnTheme.mutedForeground),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShadcnTheme.radiusDefault),
          borderSide: const BorderSide(color: ShadcnTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShadcnTheme.radiusDefault),
          borderSide: const BorderSide(color: ShadcnTheme.ring, width: 2),
        ),
      ),
    );
  }
}

// ==========================================
// 15. LABEL
// ==========================================
class ShadcnLabel extends StatelessWidget {
  final String text;
  final Widget? child;
  final bool error;

  const ShadcnLabel({super.key, required this.text, this.child, this.error = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: ShadcnTheme.textStyle.copyWith(
            fontWeight: FontWeight.w500,
            color: error ? ShadcnTheme.destructive : ShadcnTheme.foreground,
          ),
        ),
        if (child != null) ...[
          const SizedBox(height: 8),
          child!,
        ],
      ],
    );
  }
}

// ==========================================
// 16. RADIO GROUP
// ==========================================
class ShadcnRadioGroup<T> extends StatelessWidget {
  final T groupValue;
  final ValueChanged<T> onChanged;
  final Map<T, String> items; // Value -> Label

  const ShadcnRadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.entries.map((entry) {
        final isSelected = entry.key == groupValue;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GestureDetector(
            onTap: () => onChanged(entry.key),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ShadcnTheme.primary),
                  ),
                  child: isSelected
                      ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: ShadcnTheme.primary,
                      ),
                    ),
                  )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(entry.value, style: ShadcnTheme.textStyle),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ==========================================
// 17. SELECT (Dropdown)
// ==========================================
class ShadcnSelect<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String placeholder;
  final String Function(T)? labelBuilder;

  const ShadcnSelect({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.placeholder = "Select...",
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ShadcnTheme.radiusDefault),
        border: Border.all(color: ShadcnTheme.border),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: ShadcnTheme.mutedForeground),
          hint: Text(placeholder, style: ShadcnTheme.textStyle.copyWith(color: ShadcnTheme.mutedForeground)),
          style: ShadcnTheme.textStyle,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(labelBuilder?.call(item) ?? item.toString()),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ==========================================
// 18. SLIDER
// ==========================================
class ShadcnSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;

  const ShadcnSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: ShadcnTheme.primary,
        inactiveTrackColor: ShadcnTheme.secondary.withOpacity(0.3),
        thumbColor: Colors.white,
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 2),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }
}

// ==========================================
// 19. SWITCH
// ==========================================
class ShadcnSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ShadcnSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: value ? ShadcnTheme.primary : ShadcnTheme.input,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 20. TEXTAREA
// ==========================================
class ShadcnTextarea extends StatelessWidget {
  final String? placeholder;
  final TextEditingController? controller;

  const ShadcnTextarea({super.key, this.placeholder, this.controller});

  @override
  Widget build(BuildContext context) {
    return ShadcnInput(
      placeholder: placeholder,
      controller: controller,
      maxLines: 4,
    );
  }
}

// ==========================================
// 21. TOGGLE
// ==========================================
class ShadcnToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget child;

  const ShadcnToggle({super.key, required this.value, required this.onChanged, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: value ? ShadcnTheme.muted : Colors.transparent,
          borderRadius: BorderRadius.circular(ShadcnTheme.radiusSm),
        ),
        child: DefaultTextStyle(
          style: TextStyle(
              color: value ? ShadcnTheme.foreground : ShadcnTheme.mutedForeground,
              fontWeight: FontWeight.w500
          ),
          child: child,
        ),
      ),
    );
  }
}