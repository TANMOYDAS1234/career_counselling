import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/translated_text.dart';
import '../../core/providers/core_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/gradient_button.dart';
import 'auth_controller.dart';
import 'widgets/auth_shell.dart';
import 'widgets/labeled_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .login(_email.text.trim(), _password.text);
    if (!ok || !mounted) return;

    final hasRecommendations =
        ref.read(localStorageProvider).getRecommendationsRaw() != null;
    context.go(hasRecommendations ? Routes.recommendations : Routes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return AuthShell(
      panelTitle: 'Welcome Back!',
      panelSubtitle:
          'Continue your journey to discovering the perfect career path with AI-powered guidance.',
      benefits: const [
        'Personalized career recommendations',
        '90-day learning roadmaps',
        'Industry insights and expert advice',
      ],
      formTitle: 'Sign In',
      formSubtitle: 'Access your career guidance dashboard',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (auth.error != null) AuthErrorBanner(message: auth.error!),
            LabeledField(
              label: 'Email Address',
              controller: _email,
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: AppSpacing.s2),
            LabeledField(
              label: 'Password',
              controller: _password,
              hint: '••••••••',
              obscure: true,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter your password' : null,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.s3),
            GradientButton(
              label: auth.loading ? 'Signing in...' : 'Sign In',
              loading: auth.loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
      footer: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            const TranslatedText("Don't have an account? ", style: TextStyle(color: AppColors.neutral600)),
            GestureDetector(
              onTap: () => context.go(Routes.signup),
              child: const TranslatedText('Sign Up',
                  style: TextStyle(color: AppColors.primary700, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
