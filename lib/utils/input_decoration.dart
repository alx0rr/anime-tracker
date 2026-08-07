import 'package:flutter/material.dart';

InputDecoration inputDec(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24),
      filled: true,
      fillColor: const Color(0xFF252540),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF7C3AED), width: 1.5)),
    );

const kTagColors = [
  0xFF7C3AED, 0xFF9333EA, 0xFFC084FC, 0xFF2563EB, 0xFF0284C7,
  0xFF0891B2, 0xFF06B6D4, 0xFF16A34A, 0xFF10B981, 0xFF84CC16,
  0xFFD97706, 0xFFEAB308, 0xFFEA580C, 0xFFF97316, 0xFFDC2626,
  0xFFE11D48, 0xFFDB2777, 0xFFEC4899, 0xFFF43F5E, 0xFF475569,
];