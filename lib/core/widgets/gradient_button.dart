import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../i18n/translated_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_spacing.dart';

/// The primary CTA button used across the app:
/// `bg-gradient-to-r from-indigo-600 to-purple-600` with rounded corners,
/// optional leading/trailing icon, and a loading state.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.gradient,
    this.trailingIcon,
    this.leadingIcon,
    this.loading = false,
    this.expand = true,
    this.height = 52,
    this.labelColor = AppColors.white,
  });

  final String label;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final IconData? trailingIcon;
  final IconData? leadingIcon;
  final bool loading;
  final bool expand;
  final double height;

  /// Color for the label/icons (use a dark color when [gradient] is light).
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final button = Opacity(
      opacity: enabled ? 1 : 0.6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient ?? AppGradients.primaryButton,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary600.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            onTap: enabled ? onPressed : null,
            child: SizedBox(
              height: height,
              child: Center(
                child: loading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: labelColor),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (leadingIcon != null) ...[
                            Icon(leadingIcon, size: 20, color: labelColor),
                            const SizedBox(width: AppSpacing.s1),
                          ],
                          Flexible(
                            child: TranslatedText(
                              label,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: labelColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (trailingIcon != null) ...[
                            const SizedBox(width: AppSpacing.s1),
                            Icon(trailingIcon, size: 20, color: labelColor),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
