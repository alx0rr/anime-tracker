import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

InputDecoration inputDec(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textFaint),
      filled: true,
      fillColor: AppColors.surfaceHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.outline)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.outline)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.accent, width: 1.5)),
    );

const kTagColors = AppColors.tagPalette;
