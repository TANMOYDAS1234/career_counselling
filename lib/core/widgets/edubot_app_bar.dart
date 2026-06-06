import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_controller.dart';
import '../../models/app_user.dart';
import '../i18n/language_switcher.dart';
import '../i18n/translated_text.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'brand.dart';
import 'user_avatar.dart';

/// Long-press the avatar to peek at the profile without leaving the screen.
void _showProfilePreview(BuildContext context, AppUser user) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserAvatar(imageData: user.profileImage, fallback: user.name ?? user.email, size: 84, fontSize: 30),
            const SizedBox(height: AppSpacing.s2),
            Text(user.name ?? user.email,
                style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 2),
            Text(user.email, style: const TextStyle(color: AppColors.neutral500), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.s3),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  context.push(Routes.profile);
                },
                icon: const Icon(Icons.person_outline_rounded, size: 18),
                label: const TranslatedText('View full profile'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

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
                    onLongPress: () => _showProfilePreview(context, user),
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
                      UserAvatar(
                        imageData: user.profileImage,
                        fallback: user.name ?? user.email,
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
}
