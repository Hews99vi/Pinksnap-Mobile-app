import 'package:flutter/material.dart';

/// Professional Design System for Admin Panel (Web)
/// Following enterprise SaaS and modern dashboard standards
class AdminDesignConstants {
  // ============================================================================
  // COLOR PALETTE - Professional & Enterprise Grade
  // ============================================================================
  
  // Primary Colors
  static const Color primaryBlue = Color(0xFF1e40af); // Professional teal/blue
  static const Color primaryBlueDark = Color(0xFF1e3a8a);
  static const Color primaryBlueLight = Color(0xFF3b82f6);
  
  // Secondary/Neutral Grays
  static const Color gray50 = Color(0xFFf9fafb);
  static const Color gray100 = Color(0xFFf3f4f6);
  static const Color gray200 = Color(0xFFe5e7eb);
  static const Color gray300 = Color(0xFFd1d5db);
  static const Color gray400 = Color(0xFF9ca3af);
  static const Color gray500 = Color(0xFF6b7280);
  static const Color gray600 = Color(0xFF4b5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1f2937);
  static const Color gray900 = Color(0xFF111827);
  
  // Accent Colors
  static const Color accentGreen = Color(0xFF10b981); // Emerald
  static const Color accentGreenLight = Color(0xFF34d399);
  static const Color accentGreenDark = Color(0xFF059669);
  
  // Semantic Colors
  static const Color dangerRed = Color(0xFFef4444);
  static const Color dangerRedLight = Color(0xFFfef2f2);
  static const Color warningAmber = Color(0xFFf59e0b);
  static const Color warningAmberLight = Color(0xFFfef3c7);
  static const Color infoBlue = Color(0xFF3b82f6);
  static const Color infoBlueLite = Color(0xFFdbeafe);
  static const Color successGreen = Color(0xFF10b981);
  static const Color successGreenLight = Color(0xFFd1fae5);
  
  // Background Colors
  static const Color backgroundWhite = Color(0xFFffffff);
  static const Color backgroundOffWhite = Color(0xFFf9fafb);
  static const Color backgroundLightGray = Color(0xFFf3f4f6);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6b7280);
  static const Color textTertiary = Color(0xFF9ca3af);
  static const Color textOnDark = Color(0xFFf3f4f6);
  
  // Header/Sidebar Colors
  static const Color headerDark = Color(0xFF0f172a); // Navy charcoal
  static const Color sidebarDark = Color(0xFF1f2937);
  static const Color sidebarHover = Color(0xFF374151);
  static const Color sidebarActive = Color(0xFF1e40af);
  
  // ============================================================================
  // TYPOGRAPHY
  // ============================================================================
  
  static const String fontFamily = 'Poppins'; // Clean, modern font
  
  // Font Sizes
  static const double fontSizeXs = 12.0;
  static const double fontSizeSm = 14.0;
  static const double fontSizeBase = 16.0;
  static const double fontSizeLg = 18.0;
  static const double fontSizeXl = 20.0;
  static const double fontSize2xl = 24.0;
  static const double fontSize3xl = 30.0;
  static const double fontSize4xl = 36.0;
  static const double fontSize5xl = 48.0;
  
  // Font Weights
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemibold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  
  // Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;
  
  // Text Styles
  static TextStyle get headlineXl => const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize4xl,
    fontWeight: fontWeightBold,
    color: textPrimary,
    height: lineHeightTight,
  );
  
  static TextStyle get headlineLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize3xl,
    fontWeight: fontWeightBold,
    color: textPrimary,
    height: lineHeightTight,
  );
  
  static TextStyle get headlineMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize2xl,
    fontWeight: fontWeightSemibold,
    color: textPrimary,
    height: lineHeightTight,
  );
  
  static TextStyle get headlineSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeXl,
    fontWeight: fontWeightSemibold,
    color: textPrimary,
    height: lineHeightTight,
  );
  
  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeBase,
    fontWeight: fontWeightRegular,
    color: textPrimary,
    height: lineHeightNormal,
  );
  
  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeSm,
    fontWeight: fontWeightRegular,
    color: textPrimary,
    height: lineHeightNormal,
  );
  
  static TextStyle get bodySmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeXs,
    fontWeight: fontWeightRegular,
    color: textSecondary,
    height: lineHeightNormal,
  );
  
  static TextStyle get labelLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeBase,
    fontWeight: fontWeightMedium,
    color: textPrimary,
  );
  
  static TextStyle get labelMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeSm,
    fontWeight: fontWeightMedium,
    color: textSecondary,
  );
  
  static TextStyle get labelSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeXs,
    fontWeight: fontWeightMedium,
    color: textTertiary,
  );
  
  // ============================================================================
  // SPACING - 8px Grid System
  // ============================================================================
  
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;
  
  // Common Spacing Patterns
  static const EdgeInsets paddingCard = EdgeInsets.all(spacing16);
  static const EdgeInsets paddingSection = EdgeInsets.all(spacing24);
  static const EdgeInsets paddingPage = EdgeInsets.all(spacing32);
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(
    horizontal: spacing24,
    vertical: spacing12,
  );
  
  // ============================================================================
  // BORDER RADIUS
  // ============================================================================
  
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusFull = 999.0;
  
  static BorderRadius get borderRadiusSmall => BorderRadius.circular(radiusSmall);
  static BorderRadius get borderRadiusMedium => BorderRadius.circular(radiusMedium);
  static BorderRadius get borderRadiusLarge => BorderRadius.circular(radiusLarge);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);
  
  // ============================================================================
  // SHADOWS
  // ============================================================================
  
  static List<BoxShadow> get shadowSmall => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> get shadowMedium => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get shadowLarge => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  static List<BoxShadow> get shadowHover => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
  
  // ============================================================================
  // ELEVATION / LAYERS
  // ============================================================================
  
  static const double elevationCard = 2.0;
  static const double elevationModal = 8.0;
  static const double elevationDropdown = 6.0;
  
  // ============================================================================
  // BREAKPOINTS for Responsive Design
  // ============================================================================
  
  static const double breakpointMobile = 768.0;
  static const double breakpointTablet = 1024.0;
  static const double breakpointDesktop = 1280.0;
  static const double breakpointWide = 1536.0;
  
  // Sidebar Widths
  static const double sidebarWidthExpanded = 240.0;
  static const double sidebarWidthCollapsed = 64.0;
  
  // ============================================================================
  // ANIMATION / TRANSITIONS
  // ============================================================================
  
  static const Duration transitionFast = Duration(milliseconds: 150);
  static const Duration transitionMedium = Duration(milliseconds: 200);
  static const Duration transitionSlow = Duration(milliseconds: 300);
  
  static const Curve transitionCurve = Curves.easeInOut;
  
  // ============================================================================
  // INTERACTIVE STATES
  // ============================================================================
  
  static Color getHoverColor(Color baseColor) {
    return Color.lerp(baseColor, Colors.white, 0.1) ?? baseColor;
  }
  
  static Color getActiveColor(Color baseColor) {
    return Color.lerp(baseColor, Colors.black, 0.1) ?? baseColor;
  }
  
  // Focus Ring
  static BoxDecoration get focusDecoration => BoxDecoration(
    border: Border.all(color: primaryBlue, width: 2),
    borderRadius: borderRadiusMedium,
  );
  
  // ============================================================================
  // ICON SIZES
  // ============================================================================
  
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXl = 32.0;
  static const double iconSize2xl = 48.0;
}
