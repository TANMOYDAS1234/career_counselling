import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../auth/widgets/labeled_field.dart';
import '../../auth/widgets/auth_shell.dart' show AuthErrorBanner;
import '../onboarding_controller.dart';
import 'option_card.dart';

const _classLevels = [
  ('9', 'Class 9'),
  ('10', 'Class 10'),
  ('11', 'Class 11'),
  ('12', 'Class 12'),
  ('graduated', 'Graduated'),
];

const _boards = [
  ('cbse', 'CBSE'),
  ('icse', 'ICSE'),
  ('state', 'State Board'),
  ('ib', 'IB'),
  ('other', 'Other'),
];

/// Stage 0 — collects name, class, board, district, parent mobile.
class BasicInfoStep extends ConsumerStatefulWidget {
  const BasicInfoStep({super.key});

  @override
  ConsumerState<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends ConsumerState<BasicInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _district = TextEditingController();
  final _mobile = TextEditingController();
  String _classLevel = '';
  String _board = '';
  bool _consent = false;
  bool _showConsentError = false;

  @override
  void initState() {
    super.initState();
    final basic = ref.read(onboardingControllerProvider).basic;
    _name.text = basic.name;
    _district.text = basic.district;
    _mobile.text = basic.parentMobile;
    _classLevel = basic.classLevel;
    _board = basic.board;
  }

  @override
  void dispose() {
    _name.dispose();
    _district.dispose();
    _mobile.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState!.validate();
    final selectionsOk = _classLevel.isNotEmpty && _board.isNotEmpty;
    setState(() => _showConsentError = !_consent);
    if (!formOk || !selectionsOk || !_consent) {
      if (!selectionsOk) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your class and board.')),
        );
      }
      return;
    }
    final controller = ref.read(onboardingControllerProvider.notifier);
    controller.updateBasic(ref.read(onboardingControllerProvider).basic.copyWith(
          name: _name.text.trim(),
          classLevel: _classLevel,
          board: _board,
          district: _district.text.trim(),
          parentMobile: _mobile.text.trim(),
        ));
    await controller.submitBasicInfo();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(onboardingControllerProvider.select((s) => s.basicLoading));
    final error = ref.watch(onboardingControllerProvider.select((s) => s.error));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pageH),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tell us about you', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            const Text('A few basics before we begin the assessment',
                style: TextStyle(color: AppColors.neutral600)),
            const SizedBox(height: AppSpacing.s3),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (error != null) AuthErrorBanner(message: error),
                  LabeledField(
                    label: 'Full Name',
                    controller: _name,
                    hint: 'Your name',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  const _FieldLabel('Current Class'),
                  _ChipWrap(
                    options: _classLevels,
                    selected: _classLevel,
                    onSelect: (v) => setState(() => _classLevel = v),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  const _FieldLabel('Education Board'),
                  _ChipWrap(
                    options: _boards,
                    selected: _board,
                    onSelect: (v) => setState(() => _board = v),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  LabeledField(
                    label: 'District',
                    controller: _district,
                    hint: 'e.g., Kolkata',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your district' : null,
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  LabeledField(
                    label: 'Parent / Guardian Mobile',
                    controller: _mobile,
                    hint: '10-digit number',
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        (v == null || v.trim().length != 10) ? 'Enter a 10-digit number' : null,
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  _ConsentRow(
                    value: _consent,
                    showError: _showConsentError,
                    onChanged: (v) => setState(() {
                      _consent = v;
                      if (v) _showConsentError = false;
                    }),
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  GradientButton(
                    label: 'Start Assessment',
                    trailingIcon: Icons.arrow_forward_rounded,
                    loading: loading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.neutral800)),
      );
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.options, required this.selected, required this.onSelect});
  final List<(String, String)> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s1,
      runSpacing: AppSpacing.s1,
      children: [
        for (final (value, label) in options)
          SizedBox(
            width: 104,
            child: ChoiceChipCard(
              label: label,
              selected: selected == value,
              onTap: () => onSelect(value),
            ),
          ),
      ],
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({required this.value, required this.onChanged, required this.showError});
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: AppColors.primary600,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: AppSpacing.s1),
            const Expanded(
              child: Text(
                'I confirm a parent/guardian consents to this assessment.',
                style: TextStyle(fontSize: 13, color: AppColors.neutral600),
              ),
            ),
          ],
        ),
        if (showError)
          const Padding(
            padding: EdgeInsets.only(left: 32, top: 2),
            child: Text('Consent is required to continue.',
                style: TextStyle(fontSize: 12, color: AppColors.destructive)),
          ),
      ],
    );
  }
}
