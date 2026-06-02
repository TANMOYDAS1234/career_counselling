import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/gradient_button.dart';
import 'auth_controller.dart';
import 'widgets/auth_shell.dart';
import 'widgets/labeled_field.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authControllerProvider.notifier).signup(
          _email.text.trim(),
          _password.text,
          name: _name.text,
        );
    if (ok && mounted) context.go(Routes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return AuthShell(
      panelTitle: 'Start Your Journey',
      panelSubtitle:
          'Join thousands of students discovering their perfect career path with AI-powered guidance.',
      benefits: const [
        'Free AI-powered career assessment',
        'Personalized learning roadmaps',
        'Access to career resources and insights',
      ],
      formTitle: 'Create Account',
      formSubtitle: 'Start your career discovery journey',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (auth.error != null) AuthErrorBanner(message: auth.error!),
            LabeledField(
              label: 'Full Name',
              controller: _name,
              hint: 'John Doe',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
            ),
            const SizedBox(height: AppSpacing.s2),
            LabeledField(
              label: 'Email Address',
              controller: _email,
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: AppSpacing.s2),
            LabeledField(
              label: 'Password',
              controller: _password,
              hint: '••••••••',
              obscure: true,
              helperText: 'Must be at least 8 characters with numbers and letters',
              validator: (v) =>
                  (v == null || v.length < 8) ? 'Use at least 8 characters' : null,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.s3),
            GradientButton(
              label: auth.loading ? 'Creating Account...' : 'Create Account',
              loading: auth.loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
      footer: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              const Text('Already have an account? ', style: TextStyle(color: AppColors.neutral600)),
              GestureDetector(
                onTap: () => context.go(Routes.login),
                child: const Text('Sign In',
                    style: TextStyle(color: AppColors.secondary600, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s1),
          const Text(
            'By signing up, you agree to our Terms of Service and Privacy Policy',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.neutral400, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
