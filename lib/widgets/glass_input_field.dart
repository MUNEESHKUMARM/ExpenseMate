import 'package:flutter/material.dart';

/// Reusable Liquid Glass text field.
/// Styled with subtle translucency, luminous focused border stroke,
/// clear label typography, and prefix icon styling.
class GlassInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isLight;
  final Color textColor;
  final Color dimColor;
  final Color? accentColor;
  final ValueChanged<String>? onChanged;

  const GlassInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
    required this.isLight,
    required this.textColor,
    required this.dimColor,
    this.accentColor,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final activeAccent = accentColor ?? const Color(0xFF7C4DFF);
    final baseColor = isLight ? Colors.black : Colors.white;
    final fillColor = baseColor.withValues(alpha: isLight ? 0.03 : 0.05);
    final borderColor = baseColor.withValues(alpha: isLight ? 0.06 : 0.08);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: dimColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: dimColor.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        prefixIcon: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: activeAccent, size: 20),
        ),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: activeAccent, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.8),
        ),
      ),
    );
  }
}
