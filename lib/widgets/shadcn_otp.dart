import 'package:flutter/material.dart';
import '../theme/app_theme.dart'; // Make sure this import path is correct for your project

class ShadcnOTPInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;

  const ShadcnOTPInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
  });

  @override
  State<ShadcnOTPInput> createState() => _ShadcnOTPInputState();
}

class _ShadcnOTPInputState extends State<ShadcnOTPInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next field
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field filled
        _focusNodes[index].unfocus();
        String code = _controllers.map((c) => c.text).join();
        widget.onCompleted(code);
      }
    } else if (value.isEmpty && index > 0) {
      // Backspace logic: move to previous field
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIXED: Added FittedBox to prevent overflow on smaller screens
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Important for FittedBox to work correctly
        children: List.generate(widget.length, (index) {
          return Container(
            width: 45,
            height: 55,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              // Fallback style if ShadcnTheme.h3 is not found/null
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Default Slate-200
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0F172A), width: 2), // Slate-900
                ),
              ),
              onChanged: (val) => _onChanged(val, index),
            ),
          );
        }),
      ),
    );
  }
}