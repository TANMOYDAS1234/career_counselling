import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_controller.dart';
import '../i18n/language_switcher.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import 'brand.dart';

/// Sticky top bar for authenticated screens: brand + profile chip
/// (the web Navbar, adapted to mobile).
class EduBotAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const EduBotAppBar({super.key, this.showProfile = true});

  final bool showProfile;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final initials = _initials(user?.name ?? user?.email ?? '');

    return SafeArea(
      bottom: false,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(bottom: BorderSide(color: AppColors.neutral200)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(onTap: () => context.go(Routes.recommendations), child: const BrandLogo()),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LanguageSwitcher(compact: true),
                if (showProfile && user != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.push(Routes.profile),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.primary200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(gradient: AppGradients.primary, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text(initials,
                            style: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.primary700),
                    ],
                  ),
                ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final letters = parts.map((p) => p[0]).take(2).join();
    return letters.toUpperCase();
  }
}
