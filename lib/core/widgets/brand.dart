import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../i18n/translated_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_spacing.dart';

/// "EduBot" wordmark with the brain icon in a gradient tile — the web Navbar
/// brand. [onLight] renders the wordmark in the gradient text style; otherwise
/// it renders white (for use on a gradient background).
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 32, this.fontSize = 22, this.onLight = true});

  final double size;
  final double fontSize;
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    final wordmark = Text(
      'EduBot',
      style: GoogleFonts.poppins(fontSize: fontSize, fontWeight: FontWeight.w700, color: AppColors.white),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(Icons.psychology_alt_rounded, color: AppColors.white, size: size * 0.6),
        ),
        const SizedBox(width: AppSpacing.s1),
        if (onLight)
          ShaderMask(
            shaderCallback: (bounds) => AppGradients.heroText.createShader(bounds),
            child: wordmark,
          )
        else
          wordmark,
      ],
    );
  }
}

/// Soft gradient pill badge with a sparkle icon, e.g. "AI-Powered Career Guidance".
class GradientPill extends StatelessWidget {
  const GradientPill({super.key, required this.text, this.icon = Icons.auto_awesome});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppGradients.softPill,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary700),
          const SizedBox(width: 6),
          Flexible(
            child: TranslatedText(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
