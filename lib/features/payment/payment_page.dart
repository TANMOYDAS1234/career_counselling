import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../core/i18n/translated_text.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_service.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/edubot_app_bar.dart';
import '../../core/widgets/gradient_button.dart';
import '../auth/auth_controller.dart';

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

const _amountPaise = 58900; // ₹589.00

/// Payment screen — real Razorpay checkout (test mode). Creates an order on the
/// backend, opens Razorpay, then verifies the signature server-side before
/// unlocking the job-detail page.
class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key, required this.jobIndex});

  final String jobIndex;

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  late final Razorpay _razorpay;
  bool _busy = false;
  String? _currentOrderId;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  ApiService get _api => ref.read(apiServiceProvider);

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: TranslatedText(msg), backgroundColor: error ? AppColors.destructive : null),
    );
  }

  Future<void> _startPayment() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final order = await _api.createRazorpayOrder(amount: _amountPaise);
      if (order == null) {
        _toast('Could not start payment. Please try again later.', error: true);
        setState(() => _busy = false);
        return;
      }
      _currentOrderId = order['orderId'] as String;
      final email = ref.read(authControllerProvider).user?.email ?? '';
      _razorpay.open({
        'key': order['keyId'],
        'order_id': order['orderId'],
        'amount': order['amount'],
        'currency': order['currency'] ?? 'INR',
        'name': 'EduBot',
        'description': 'Career Guidance Premium',
        'prefill': {'email': email},
        'theme': {'color': '#4F46E5'},
      });
      // _busy stays true until a Razorpay callback fires.
    } on ApiException catch (e) {
      _toast(e.message, error: true);
      setState(() => _busy = false);
    } catch (_) {
      _toast('Could not start payment.', error: true);
      setState(() => _busy = false);
    }
  }

  Future<void> _onSuccess(PaymentSuccessResponse r) async {
    // Verify the signature on the server before unlocking.
    try {
      final ok = await _api.verifyPayment(
        orderId: r.orderId ?? _currentOrderId ?? '',
        paymentId: r.paymentId ?? '',
        signature: r.signature ?? '',
      );
      if (!mounted) return;
      if (ok) {
        _toast('Payment successful ✓');
        context.go('${Routes.role}/job-${widget.jobIndex}');
      } else {
        _toast('Payment could not be verified. If money was deducted it will be refunded.', error: true);
        setState(() => _busy = false);
      }
    } catch (_) {
      if (mounted) {
        _toast('Could not verify payment.', error: true);
        setState(() => _busy = false);
      }
    }
  }

  void _onError(PaymentFailureResponse r) {
    if (!mounted) return;
    final msg = (r.message != null && r.message!.isNotEmpty) ? r.message! : 'Payment cancelled.';
    _toast(msg, error: true);
    setState(() => _busy = false);
  }

  void _onExternalWallet(ExternalWalletResponse r) {
    _toast('Selected wallet: ${r.walletName ?? ''}');
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
              label: const TranslatedText('Back'),
              style: TextButton.styleFrom(foregroundColor: AppColors.neutral600, alignment: Alignment.centerLeft),
            ),
            TranslatedText('Checkout', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            const TranslatedText('Complete your purchase to unlock career insights',
                style: TextStyle(color: AppColors.neutral600)),
            const SizedBox(height: AppSpacing.s3),
            _OrderSummary(),
            const SizedBox(height: AppSpacing.s2),
            _IncludedCard(),
            const SizedBox(height: AppSpacing.s3),
            GradientButton(
              label: _busy ? 'Processing…' : 'Pay ₹589 securely',
              leadingIcon: Icons.lock_outline_rounded,
              loading: _busy,
              onPressed: _busy ? null : _startPayment,
            ),
            const SizedBox(height: AppSpacing.s2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.neutral500),
                const SizedBox(width: 6),
                Flexible(
                  child: TranslatedText('Secured by Razorpay · test mode',
                      style: const TextStyle(fontSize: 12, color: AppColors.neutral500)),
                ),
              ],
            ),
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
          TranslatedText('Career Guidance Premium', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const TranslatedText('Unlock detailed career insights and roadmaps',
              style: TextStyle(fontSize: 13, color: AppColors.neutral600)),
          const Divider(height: AppSpacing.s3),
          const _Line('Subtotal', '₹499'),
          const SizedBox(height: 6),
          const _Line('Tax (18%)', '₹90'),
          const Divider(height: AppSpacing.s3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const TranslatedText('Total', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              TranslatedText('₹589',
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
          TranslatedText(label, style: const TextStyle(fontSize: 13, color: AppColors.neutral600)),
          TranslatedText(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
          TranslatedText("What's Included:", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.s1),
          for (final item in _included)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_rounded, size: 16, color: AppColors.primary600),
                  const SizedBox(width: 8),
                  Expanded(child: TranslatedText(item, style: const TextStyle(fontSize: 14, color: AppColors.neutral700))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
