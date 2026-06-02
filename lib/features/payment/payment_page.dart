import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/edubot_app_bar.dart';
import '../../core/widgets/gradient_button.dart';
import '../auth/widgets/labeled_field.dart';

const _included = [
  'Detailed career pathway',
  'Skills & learning resources',
  '90-day roadmap',
  'Top institutes list',
  'Scholarship information',
  'Job market analysis',
  'Salary growth insights',
  'Industry expert advice',
];

/// Prototype payment screen (no real processing) — mirrors the web `Payment`.
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.jobIndex});

  final String jobIndex;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _card = TextEditingController();
  final _name = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();

  @override
  void dispose() {
    _card.dispose();
    _name.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  void _pay() {
    // Prototype only — go straight to the unlocked role detail.
    context.go('${Routes.role}/job-${widget.jobIndex}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EduBotAppBar(),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageH),
          children: [
            TextButton.icon(
              onPressed: () => context.canPop() ? context.pop() : context.go(Routes.recommendations),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back'),
              style: TextButton.styleFrom(foregroundColor: AppColors.neutral600, alignment: Alignment.centerLeft),
            ),
            Text('Payment Details', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            const Text('Complete your purchase to unlock career insights',
                style: TextStyle(color: AppColors.neutral600)),
            const SizedBox(height: AppSpacing.s3),
            _OrderSummary(),
            const SizedBox(height: AppSpacing.s2),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabeledField(
                    label: 'Card Number',
                    controller: _card,
                    hint: '1234 5678 9012 3456',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  LabeledField(label: 'Cardholder Name', controller: _name, hint: 'John Doe'),
                  const SizedBox(height: AppSpacing.s2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: LabeledField(
                          label: 'Expiry',
                          controller: _expiry,
                          hint: 'MM/YY',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s2),
                      Expanded(
                        child: LabeledField(
                          label: 'CVV',
                          controller: _cvv,
                          hint: '123',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.neutral600),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('Your payment information is secure and encrypted',
                              style: TextStyle(fontSize: 12, color: AppColors.neutral600)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s3),
                  GradientButton(label: 'Pay Now', onPressed: _pay),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s2),
            _IncludedCard(),
            const SizedBox(height: AppSpacing.s4),
          ],
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Career Guidance Premium', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text('Unlock detailed career insights and roadmaps',
              style: TextStyle(fontSize: 13, color: AppColors.neutral600)),
          const Divider(height: AppSpacing.s3),
          const _Line('Subtotal', '₹499'),
          const SizedBox(height: 6),
          const _Line('Tax (18%)', '₹90'),
          const Divider(height: AppSpacing.s3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              Text('₹589',
                  style: TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.primary600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.neutral600)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      );
}

class _IncludedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary50, AppColors.secondary50]),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What's Included:", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s1),
          for (final item in _included)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_rounded, size: 16, color: AppColors.primary600),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: const TextStyle(fontSize: 14, color: AppColors.neutral700))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
