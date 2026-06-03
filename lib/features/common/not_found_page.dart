import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/gradient_button.dart';

/// Themed 404 screen (go_router `errorBuilder`), mirroring the web NotFound page.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandLogo(),
                  const SizedBox(height: AppSpacing.s5),
                  ShaderMask(
                    shaderCallback: (b) => AppGradients.heroText.createShader(b),
                    child: Text('404',
                        style: GoogleFonts.poppins(
                            fontSize: 72, fontWeight: FontWeight.w800, color: AppColors.white)),
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  Text('Page not found',
                      style: GoogleFonts.poppins(
                          fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
                  const SizedBox(height: AppSpacing.s1),
                  const Text(
                    "The page you're looking for doesn't exist or has moved.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.neutral500),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  GradientButton(
                    label: 'Back to home',
                    expand: false,
                    leadingIcon: Icons.home_rounded,
                    onPressed: () => context.go(Routes.landing),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
