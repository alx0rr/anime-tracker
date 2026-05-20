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
  0xFF7C3AED, 0xFF2563EB, 0xFF16A34A, 0xFFDC2626,
  0xFFEA580C, 0xFFDB2777, 0xFF0891B2, 0xFFD97706,
];