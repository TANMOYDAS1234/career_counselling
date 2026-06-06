import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../i18n/translated_text.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_spacing.dart';

/// The primary CTA button used across the app:
/// `bg-gradient-to-r from-indigo-600 to-purple-600` with rounded corners,
/// optional leading/trailing icon, a loading state, and a tactile press
/// (scale-down + haptic) so taps feel responsive.
class GradientButton extends StatefulWidget {
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
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;

    final content = widget.loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: widget.labelColor),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leadingIcon != null) ...[
                Icon(widget.leadingIcon, size: 20, color: widget.labelColor),
                const SizedBox(width: AppSpacing.s1),
              ],
              Flexible(
                child: TranslatedText(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: widget.labelColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              if (widget.trailingIcon != null) ...[
                const SizedBox(width: AppSpacing.s1),
                Icon(widget.trailingIcon, size: 20, color: widget.labelColor),
              ],
            ],
          );

    final visual = AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 90),
      child: Opacity(
        opacity: enabled ? 1 : 0.6,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: widget.gradient ?? AppGradients.primaryButton,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary600.withValues(alpha: _pressed ? 0.15 : 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(height: widget.height, child: Center(child: content)),
        ),
      ),
    );

    final tappable = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              widget.onPressed!();
            }
          : null,
      child: visual,
    );

    return widget.expand ? SizedBox(width: double.infinity, child: tappable) : tappable;
  }
}
