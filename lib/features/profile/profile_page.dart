import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/api_service.dart';
import '../../core/providers/core_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/edubot_app_bar.dart';
import '../../core/widgets/gradient_button.dart';
import '../auth/auth_controller.dart';
import '../auth/widgets/labeled_field.dart';

/// Most-recently viewed job role, for the "Continue where you left off" card.
final recentRoleProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final username = ref.read(authControllerProvider).user?.email ??
      ref.read(localStorageProvider).username ??
      '';
  if (username.isEmpty) return null;
  return ref.read(apiServiceProvider).getRecentJobRole(username);
});

/// `/profile` — view & edit name, password and avatar; show last-viewed role.
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _name = TextEditingController();
  final _currentPw = TextEditingController();
  final _newPw = TextEditingController();
  final _confirmPw = TextEditingController();

  bool _savingProfile = false;
  bool _savingPassword = false;
  String? _pendingImage; // base64 data URL not yet saved

  @override
  void initState() {
    super.initState();
    _name.text = ref.read(authControllerProvider).user?.name ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _currentPw.dispose();
    _newPw.dispose();
    _confirmPw.dispose();
    super.dispose();
  }

  String get _username =>
      ref.read(authControllerProvider).user?.email ??
      ref.read(localStorageProvider).username ??
      '';

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? AppColors.destructive : null),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() => _pendingImage = 'data:image/jpeg;base64,${base64Encode(bytes)}');
    } catch (_) {
      _toast('Could not open the image picker.', error: true);
    }
  }

  Future<void> _saveProfile() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      _toast('Name cannot be empty.', error: true);
      return;
    }
    setState(() => _savingProfile = true);
    final api = ref.read(apiServiceProvider);
    try {
      final res = await api.updateProfile({
        'username': _username,
        'name': name,
        if (_pendingImage != null) 'profileImage': _pendingImage,
      });
      if (res['success'] == true) {
        await ref.read(authControllerProvider.notifier).applyProfile(
              name: name,
              profileImage: _pendingImage,
            );
        setState(() => _pendingImage = null);
        _toast('Profile updated.');
      } else {
        _toast((res['message'] as String?) ?? 'Could not update profile.', error: true);
      }
    } on ApiException catch (e) {
      _toast(e.message, error: true);
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _savePassword() async {
    if (_currentPw.text.isEmpty || _newPw.text.isEmpty) {
      _toast('Enter your current and new password.', error: true);
      return;
    }
    if (_newPw.text.length < 4) {
      _toast('New password is too short.', error: true);
      return;
    }
    if (_newPw.text != _confirmPw.text) {
      _toast('New passwords do not match.', error: true);
      return;
    }
    setState(() => _savingPassword = true);
    final api = ref.read(apiServiceProvider);
    try {
      final res = await api.updateProfile({
        'username': _username,
        'currentPassword': _currentPw.text,
        'newPassword': _newPw.text,
      });
      if (res['success'] == true) {
        _currentPw.clear();
        _newPw.clear();
        _confirmPw.clear();
        _toast('Password changed.');
      } else {
        _toast((res['message'] as String?) ?? 'Could not change password.', error: true);
      }
    } on ApiException catch (e) {
      _toast(e.message, error: true);
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final recent = ref.watch(recentRoleProvider);

    return Scaffold(
      appBar: const EduBotAppBar(showProfile: false),
      body: AppBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.pageH, AppSpacing.s3, AppSpacing.pageH, AppSpacing.s5),
            children: [
              // ── Avatar + identity ────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    _Avatar(
                      imageData: _pendingImage ?? user?.profileImage,
                      fallback: (user?.name ?? user?.email ?? '?'),
                      onEdit: _pickImage,
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(user?.name ?? '',
                        style: GoogleFonts.poppins(
                            fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
                    Text(user?.email ?? '',
                        style: const TextStyle(fontSize: 13, color: AppColors.neutral500)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s3),

              // ── Edit profile ─────────────────────────────────────────
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Profile',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
                    const SizedBox(height: AppSpacing.s2),
                    LabeledField(label: 'Display name', controller: _name, hint: 'Your name'),
                    const SizedBox(height: AppSpacing.s2),
                    GradientButton(
                      label: 'Save changes',
                      loading: _savingProfile,
                      onPressed: _savingProfile ? null : _saveProfile,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s3),

              // ── Last viewed role ─────────────────────────────────────
              recent.maybeWhen(
                data: (role) => role == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s3),
                        child: _LastRoleCard(role: role),
                      ),
                orElse: () => const SizedBox.shrink(),
              ),

              // ── Change password ──────────────────────────────────────
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Change password',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
                    const SizedBox(height: AppSpacing.s2),
                    LabeledField(label: 'Current password', controller: _currentPw, obscure: true),
                    const SizedBox(height: AppSpacing.s1),
                    LabeledField(label: 'New password', controller: _newPw, obscure: true),
                    const SizedBox(height: AppSpacing.s1),
                    LabeledField(label: 'Confirm new password', controller: _confirmPw, obscure: true),
                    const SizedBox(height: AppSpacing.s2),
                    GradientButton(
                      label: 'Update password',
                      gradient: AppGradients.secondary,
                      loading: _savingPassword,
                      onPressed: _savingPassword ? null : _savePassword,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s3),

              // ── Logout ───────────────────────────────────────────────
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) context.go(Routes.landing);
                },
                icon: const Icon(Icons.logout_rounded, color: AppColors.destructive),
                label: const Text('Log out', style: TextStyle(color: AppColors.destructive)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: AppColors.destructiveBorder),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageData, required this.fallback, required this.onEdit});

  final String? imageData;
  final String fallback;
  final VoidCallback onEdit;

  Uint8List? _decode(String? data) {
    if (data == null || data.isEmpty) return null;
    try {
      final raw = data.contains(',') ? data.substring(data.indexOf(',') + 1) : data;
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.map((p) => p[0]).take(2).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _decode(imageData);
    return Stack(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(gradient: AppGradients.primary, shape: BoxShape.circle),
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          child: bytes != null
              ? Image.memory(bytes, width: 96, height: 96, fit: BoxFit.cover)
              : Text(_initials(fallback),
                  style: GoogleFonts.poppins(
                      fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.white)),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.neutral200),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6)],
              ),
              child: const Icon(Icons.camera_alt_rounded, size: 18, color: AppColors.primary600),
            ),
          ),
        ),
      ],
    );
  }
}

class _LastRoleCard extends StatelessWidget {
  const _LastRoleCard({required this.role});

  final Map<String, dynamic> role;

  @override
  Widget build(BuildContext context) {
    final title = (role['roleTitle'] ?? 'Career') as String;
    final roleId = (role['roleId'] ?? '') as String;
    final sections = role['sectionsCount'];
    return AppCard(
      onTap: roleId.isEmpty ? null : () => context.push('${Routes.role}/$roleId'),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(Icons.work_history_rounded, color: AppColors.primary600),
          ),
          const SizedBox(width: AppSpacing.s2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Last viewed role',
                    style: TextStyle(fontSize: 12, color: AppColors.neutral500)),
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.neutral900)),
                if (sections != null)
                  Text('$sections/11 sections generated',
                      style: const TextStyle(fontSize: 12, color: AppColors.neutral500)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.neutral400),
        ],
      ),
    );
  }
}
