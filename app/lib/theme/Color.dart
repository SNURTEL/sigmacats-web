import 'package:flutter/material.dart';

"""
This file defines color schemes (light and dark) for the application
"""

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF006494),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFCBE6FF),
  onPrimaryContainer: Color(0xFF001E30),
  secondary: Color(0xFF50606F),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFD4E4F6),
  onSecondaryContainer: Color(0xFF0C1D29),
  tertiary: Color(0xFF65587B),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFEBDCFF),
  onTertiaryContainer: Color(0xFF211634),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFCFCFF),
  onBackground: Color(0xFF1A1C1E),
  surface: Color(0xFFFCFCFF),
  onSurface: Color(0xFF1A1C1E),
  surfaceVariant: Color(0xFFDDE3EA),
  onSurfaceVariant: Color(0xFF41474D),
  outline: Color(0xFF72787E),
  onInverseSurface: Color(0xFFF0F0F3),
  inverseSurface: Color(0xFF2E3133),
  inversePrimary: Color(0xFF8FCDFF),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF006494),
  outlineVariant: Color(0xFFC1C7CE),
  scrim: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF8FCDFF),
  onPrimary: Color(0xFF00344F),
  primaryContainer: Color(0xFF004B71),
  onPrimaryContainer: Color(0xFFCBE6FF),
  secondary: Color(0xFFB8C8D9),
  onSecondary: Color(0xFF22323F),
  secondaryContainer: Color(0xFF394956),
  onSecondaryContainer: Color(0xFFD4E4F6),
  tertiary: Color(0xFFD0BFE8),
  onTertiary: Color(0xFF362B4A),
  tertiaryContainer: Color(0xFF4D4162),
  onTertiaryContainer: Color(0xFFEBDCFF),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF1A1C1E),
  onBackground: Color(0xFFE2E2E5),
  surface: Color(0xFF1A1C1E),
  onSurface: Color(0xFFE2E2E5),
  surfaceVariant: Color(0xFF41474D),
  onSurfaceVariant: Color(0xFFC1C7CE),
  outline: Color(0xFF8B9198),
  onInverseSurface: Color(0xFF1A1C1E),
  inverseSurface: Color(0xFFE2E2E5),
  inversePrimary: Color(0xFF006494),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF8FCDFF),
  outlineVariant: Color(0xFF41474D),
  scrim: Color(0xFF000000),
);