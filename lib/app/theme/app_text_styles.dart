import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  // Sans (UI)
  static TextStyle get sans => GoogleFonts.inter(
    letterSpacing: -0.005 * 14,
  );

  // Serif (hero / display)
  static TextStyle get serif => GoogleFonts.fraunces(
    fontWeight: FontWeight.w500,
    letterSpacing: -0.02 * 30,
  );

  // Mono (url / meta)
  static TextStyle get mono => GoogleFonts.jetBrainsMono();

  // Display / Hero
  static TextStyle get displaySerif => GoogleFonts.fraunces(
    fontSize: 30,
    fontWeight: FontWeight.w500,
    height: 1.1,
    letterSpacing: -0.02 * 30,
  );

  static TextStyle get displaySans => GoogleFonts.inter(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.02 * 30,
  );

  // Heading (sans)
  static TextStyle get heading1 => GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.01 * 26,
  );

  static TextStyle get heading2 => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.01 * 22,
  );

  static TextStyle get heading3 => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // Title
  static TextStyle get titleL => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static TextStyle get titleM => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  // Body
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static TextStyle get label => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // Label uppercase — small caps style used for section labels
  static TextStyle get labelUpper => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.07 * 11,
  );

  // Meta (monospace — URLs, step counters, OG parse hints)
  static TextStyle get metaMono => GoogleFonts.jetBrainsMono(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static TextStyle get metaMonoSmall => GoogleFonts.jetBrainsMono(
    fontSize: 10.5,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );
}
