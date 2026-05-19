import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/user_data.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';

// Maps Checkout.tsx — 5-step progressive form
// Step 1: Leveransadress
// Step 2: Födelsedatum
// Step 3: Skapa konto (namn, email, lösenord)
// Step 4: Bekräfta (review + submit)
// Step 5: Bekräftelse (order success)

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 1;

  final _addressCtrl = TextEditingController();
  final _birthdateCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userData = context.read<CartProvider>().userData;
    if (userData != null) {
      _nameCtrl.text = userData.name;
      _emailCtrl.text = userData.email;
      _addressCtrl.text = userData.address;
    }
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _birthdateCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.destructive,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
      ),
    );
  }

  void _step1Continue() {
    if (_addressCtrl.text.trim().isEmpty) {
      _showError('Vänligen fyll i leveransadress');
      return;
    }
    setState(() => _currentStep = 2);
  }

  void _step2Continue() {
    if (_birthdateCtrl.text.trim().isEmpty) {
      _showError('Vänligen fyll i födelsedatum');
      return;
    }
    setState(() => _currentStep = 3);
  }

  void _step3Continue() {
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _passwordCtrl.text.trim().isEmpty) {
      _showError('Vänligen fyll i alla fält');
      return;
    }
    setState(() => _currentStep = 4);
  }

  Future<void> _step4Continue() async {
    final userData = UserData(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: '',
      address: _addressCtrl.text.trim(),
      city: '',
      postalCode: '',
      paymentMethod: 'card',
    );
    await context.read<CartProvider>().createOrder(userData);
    if (!mounted) return;
    setState(() => _currentStep = 5);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Beställning genomförd! 🎉'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    if (cartProvider.cart.isEmpty && _currentStep != 5) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🛒', style: TextStyle(fontSize: 64)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Din kundvagn är tom',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => context.go('/products'),
                child: const Text('Börja handla'),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kassa',
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xl),

              // Steps
              _CheckoutStep(
                stepNumber: 1,
                title: 'Vart ska vi leverera?',
                currentStep: _currentStep,
                onEdit: () => setState(() => _currentStep = 1),
                completedSummary: _addressCtrl.text,
                activeContent: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Adress'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Storgatan 1, 123 45 Stockholm',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: _step1Continue,
                      child: const Text('Fortsätt'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              _CheckoutStep(
                stepNumber: 2,
                title: 'Födelsedatum',
                currentStep: _currentStep,
                onEdit: () => setState(() => _currentStep = 2),
                completedSummary: _birthdateCtrl.text,
                activeContent: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Ditt födelsedatum'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _birthdateCtrl,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(
                        hintText: 'ÅÅÅÅ-MM-DD',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: _step2Continue,
                      child: const Text('Fortsätt'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              _CheckoutStep(
                stepNumber: 3,
                title: 'Skapa konto',
                currentStep: _currentStep,
                onEdit: () => setState(() => _currentStep = 3),
                completedSummary: _nameCtrl.text.isNotEmpty
                    ? '${_nameCtrl.text} · ${_emailCtrl.text}'
                    : '',
                activeContent: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Namn'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _nameCtrl,
                      decoration:
                          const InputDecoration(hintText: 'Förnamn Efternamn'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _fieldLabel('E-post'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          const InputDecoration(hintText: 'din@email.se'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _fieldLabel('Lösenord'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration:
                          const InputDecoration(hintText: '••••••••'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: _step3Continue,
                      child: const Text('Fortsätt'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              _CheckoutStep(
                stepNumber: 4,
                title: 'Bekräfta beställning',
                currentStep: _currentStep,
                onEdit: () => setState(() => _currentStep = 4),
                completedSummary: '',
                activeContent: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order summary
                    ...cartProvider.cart.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              Text(item.product.image,
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  '${item.product.name}${item.isOrganic ? " (EKO)" : ""} × ${item.quantity}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                '${item.lineTotal.toStringAsFixed(0)} kr',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )),
                    const Divider(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Totalt',
                            style: Theme.of(context).textTheme.headlineMedium),
                        Text(
                          '${cartProvider.getCartTotal().toStringAsFixed(2)} kr',
                          style:
                              Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppColors.primary,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _step4Continue,
                        child: const Text('Genomför beställning'),
                      ),
                    ),
                  ],
                ),
              ),

              // Step 5: Success
              if (_currentStep == 5) ...[
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      children: [
                        const Text('✅', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Tack för din beställning!',
                          style: Theme.of(context).textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Vi förbereder din order och levererar snart.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.mutedForeground),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        ElevatedButton(
                          onPressed: () => context.go('/'),
                          child: const Text('Tillbaka till startsidan'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Step Card ─────────────────────────────────────────────────────────────────

class _CheckoutStep extends StatelessWidget {
  final int stepNumber;
  final String title;
  final int currentStep;
  final VoidCallback onEdit;
  final String completedSummary;
  final Widget activeContent;

  const _CheckoutStep({
    required this.stepNumber,
    required this.title,
    required this.currentStep,
    required this.onEdit,
    required this.completedSummary,
    required this.activeContent,
  });

  bool get isActive => currentStep == stepNumber;
  bool get isCompleted => currentStep > stepNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
          width: isActive ? 2 : 1,
        ),
        borderRadius: AppRadius.large,
        color: AppColors.surface,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive || isCompleted
                  ? AppColors.primary
                  : AppColors.muted,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check,
                      size: 18, color: AppColors.primaryForeground)
                  : Text(
                      '$stepNumber',
                      style: TextStyle(
                        color: isActive || isCompleted
                            ? AppColors.primaryForeground
                            : AppColors.mutedForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: AppSpacing.lg),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontSize: 17)),
                    const Spacer(),
                    if (isCompleted)
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 14),
                        label: const Text('Ändra',
                            style: TextStyle(fontSize: 13)),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
                if (isActive) ...[
                  const SizedBox(height: AppSpacing.lg),
                  activeContent,
                ] else if (isCompleted && completedSummary.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    completedSummary,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _fieldLabel(String text) => Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.foreground,
      ),
    );
