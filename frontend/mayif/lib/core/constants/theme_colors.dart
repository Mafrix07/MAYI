import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Extension BuildContext pour des couleurs adaptées au thème actif.
/// Utilisation : context.primaryText, context.secondaryText, etc.
extension ThemeColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get primaryText =>
      isDarkMode ? AppColors.textPrimary : AppColors.lightTextPrimary;

  Color get secondaryText =>
      isDarkMode ? AppColors.textSecondary : AppColors.lightTextSecondary;

  Color get hintText =>
      isDarkMode ? AppColors.textHint : AppColors.lightTextHint;

  Color get cardBackground =>
      isDarkMode ? AppColors.backgroundCard : AppColors.lightBackgroundCard;

  Color get midBackground =>
      isDarkMode ? AppColors.backgroundMid : AppColors.lightBackgroundMid;
}
