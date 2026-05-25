import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imat/model/imat/customer.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 1;
  bool _orderPlaced = false;

  // Step 1 – Address
  final _addressCtrl   = TextEditingController();
  final _postCodeCtrl  = TextEditingController();
  final _cityCtrl      = TextEditingController();

  // Step 2 – Birthdate
  final _birthdateCtrl = TextEditingController();

  // Step 3 – Personal info + card
  final _firstNameCtrl  = TextEditingController();
  final _lastNameCtrl   = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _cardNumberCtrl = TextEditingController();
  final _expiryCtrl     = TextEditingController();
  final _cvcCtrl        = TextEditingController();

  // Step 4 – Delivery
  DateTime? _deliveryDate;
  String?   _deliveryTimeSlot;

  static const _timeSlots = [
    '08:00 – 12:00',
    '12:00 – 17:00',
    '17:00 – 21:00',
  ];

  @override
  void initState() {
    super.initState();
    final c = context.read<ImatDataHandler>().getCustomer();
    _firstNameCtrl.text = c.firstName;
    _lastNameCtrl.text  = c.lastName;
    _emailCtrl.text     = c.email;
    _phoneCtrl.text     = c.phoneNumber;
    _addressCtrl.text   = c.address;
    _postCodeCtrl.text  = c.postCode;
    _cityCtrl.text      = c.postAddress;
  }

  @override
  void dispose() {
    for (final c in [
      _addressCtrl, _postCodeCtrl, _cityCtrl, _birthdateCtrl,
      _firstNameCtrl, _lastNameCtrl, _emailCtrl, _phoneCtrl,
      _cardNumberCtrl, _expiryCtrl, _cvcCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.destructive,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _step1() {
    if (_addressCtrl.text.trim().isEmpty) {
      _showError('Vänligen fyll i leveransadress');
      return;
    }
    setState(() => _currentStep = 2);
  }

  void _step2() {
    if (_birthdateCtrl.text.trim().isEmpty) {
      _showError('Vänligen fyll i födelsedatum');
      return;
    }
    setState(() => _currentStep = 3);
  }

  void _step3() {
    if (_firstNameCtrl.text.trim().isEmpty || _lastNameCtrl.text.trim().isEmpty) {
      _showError('Vänligen fyll i namn');
      return;
    }
    if (_cardNumberCtrl.text.trim().isEmpty) {
      _showError('Vänligen fyll i kortnummer');
      return;
    }
    if (_expiryCtrl.text.trim().isEmpty) {
      _showError('Vänligen fyll i utgångsdatum');
      return;
    }
    if (_cvcCtrl.text.trim().isEmpty) {
      _showError('Vänligen fyll i CVC');
      return;
    }
    setState(() => _currentStep = 4);
  }

  void _step4() {
    if (_deliveryDate == null) {
      _showError('Vänligen välj ett leveransdatum');
      return;
    }
    if (_deliveryTimeSlot == null) {
      _showError('Vänligen välj en leveranstid');
      return;
    }
    setState(() => _currentStep = 5);
  }

  Future<void> _step5() async {
    final imat = context.read<ImatDataHandler>();
    imat.setCustomer(Customer(
      _firstNameCtrl.text.trim(),
      _lastNameCtrl.text.trim(),
      _phoneCtrl.text.trim(),
      '',
      _emailCtrl.text.trim(),
      _addressCtrl.text.trim(),
      _postCodeCtrl.text.trim(),
      _cityCtrl.text.trim(),
    ));
    await imat.placeOrder();
    if (!mounted) return;
    setState(() {
      _currentStep = 6;
      _orderPlaced = true;
    });
  }

  String get _deliverySummary {
    if (_deliveryDate == null || _deliveryTimeSlot == null) return '';
    final d = _deliveryDate!;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}  $_deliveryTimeSlot';
  }

  @override
  Widget build(BuildContext context) {
    final imat  = context.watch<ImatDataHandler>();
    final items = imat.cartItems;

    if (items.isEmpty && !_orderPlaced) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🛒', style: TextStyle(fontSize: 64)),
              const SizedBox(height: AppSpacing.lg),
              Text('Din kundvagn är tom',
                  style: Theme.of(context).textTheme.displaySmall),
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
              Text('Kassa', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xl),

              // ── Steg 1: Adress ──────────────────────────────────────────────
              _Step(
                number: 1,
                title: 'Vart ska vi leverera?',
                current: _currentStep,
                onEdit: () => setState(() => _currentStep = 1),
                summary: _addressCtrl.text.isNotEmpty
                    ? '${_addressCtrl.text}, ${_postCodeCtrl.text} ${_cityCtrl.text}'
                    : '',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Adress'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(hintText: 'Storgatan 1'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Postnummer'),
                              const SizedBox(height: AppSpacing.sm),
                              TextField(
                                controller: _postCodeCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(hintText: '123 45'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Stad'),
                              const SizedBox(height: AppSpacing.sm),
                              TextField(
                                controller: _cityCtrl,
                                decoration: const InputDecoration(hintText: 'Stockholm'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(onPressed: _step1, child: const Text('Fortsätt')),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Steg 2: Födelsedatum ────────────────────────────────────────
              _Step(
                number: 2,
                title: 'Födelsedatum',
                current: _currentStep,
                onEdit: () => setState(() => _currentStep = 2),
                summary: _birthdateCtrl.text,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Ditt födelsedatum'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _birthdateCtrl,
                      keyboardType: TextInputType.datetime,
                      decoration: const InputDecoration(hintText: 'ÅÅÅÅ-MM-DD'),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(onPressed: _step2, child: const Text('Fortsätt')),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Steg 3: Dina uppgifter + kort ───────────────────────────────
              _Step(
                number: 3,
                title: 'Dina uppgifter',
                current: _currentStep,
                onEdit: () => setState(() => _currentStep = 3),
                summary: '${_firstNameCtrl.text} ${_lastNameCtrl.text}'.trim(),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Förnamn'),
                              const SizedBox(height: AppSpacing.sm),
                              TextField(controller: _firstNameCtrl,
                                  decoration: const InputDecoration(hintText: 'Förnamn')),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Efternamn'),
                              const SizedBox(height: AppSpacing.sm),
                              TextField(controller: _lastNameCtrl,
                                  decoration: const InputDecoration(hintText: 'Efternamn')),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _label('E-post'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'din@email.se'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _label('Telefon'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(hintText: '070-123 45 67'),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    _label('Kortuppgifter'),
                    const SizedBox(height: AppSpacing.md),

                    _label('Kortnummer'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _cardNumberCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '1234 5678 9012 3456'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Utgångsdatum'),
                              const SizedBox(height: AppSpacing.sm),
                              TextField(
                                controller: _expiryCtrl,
                                keyboardType: TextInputType.datetime,
                                decoration: const InputDecoration(hintText: 'MM/ÅÅ'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('CVC'),
                              const SizedBox(height: AppSpacing.sm),
                              TextField(
                                controller: _cvcCtrl,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                decoration: const InputDecoration(hintText: '123'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(onPressed: _step3, child: const Text('Fortsätt')),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Steg 4: Leverans ────────────────────────────────────────────
              _Step(
                number: 4,
                title: 'Leverans',
                current: _currentStep,
                onEdit: () => setState(() => _currentStep = 4),
                summary: _deliverySummary,
                content: _DeliveryPicker(
                  selectedDate: _deliveryDate,
                  selectedSlot: _deliveryTimeSlot,
                  timeSlots: _timeSlots,
                  onDateSelected: (d) => setState(() => _deliveryDate = d),
                  onSlotSelected: (s) => setState(() => _deliveryTimeSlot = s),
                  onContinue: _step4,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Steg 5: Bekräfta beställning ────────────────────────────────
              _Step(
                number: 5,
                title: 'Bekräfta beställning',
                current: _currentStep,
                onEdit: () => setState(() => _currentStep = 5),
                summary: '',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              Text(item.product.name,
                                  style: Theme.of(context).textTheme.bodyMedium),
                              const Text(' × '),
                              Text('${item.amount.round()}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Text('${item.total.toStringAsFixed(0)} kr',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )),
                    const Divider(height: AppSpacing.xl),
                    if (_deliverySummary.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.local_shipping_outlined, size: 16,
                              color: AppColors.mutedForeground),
                          const SizedBox(width: AppSpacing.sm),
                          Text(_deliverySummary,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.mutedForeground)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Totalt',
                            style: Theme.of(context).textTheme.headlineMedium),
                        Text(
                          '${imat.shoppingCartTotal().toStringAsFixed(2)} kr',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _step5,
                        child: const Text('Genomför beställning'),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Success ─────────────────────────────────────────────────────
              if (_currentStep == 6) ...[
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      children: [
                        const Text('✅', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: AppSpacing.lg),
                        Text('Tack för din beställning!',
                            style: Theme.of(context).textTheme.displaySmall,
                            textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Vi levererar $_deliverySummary.',
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

// ─── Delivery date + time picker ─────────────────────────────────────────────

class _DeliveryPicker extends StatelessWidget {
  final DateTime? selectedDate;
  final String?   selectedSlot;
  final List<String> timeSlots;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<String>   onSlotSelected;
  final VoidCallback onContinue;

  const _DeliveryPicker({
    required this.selectedDate,
    required this.selectedSlot,
    required this.timeSlots,
    required this.onDateSelected,
    required this.onSlotSelected,
    required this.onContinue,
  });

  static const _weekdayNames = ['Mån', 'Tis', 'Ons', 'Tor', 'Fre', 'Lör', 'Sön'];
  static const _monthNames   = [
    '', 'jan', 'feb', 'mar', 'apr', 'maj', 'jun',
    'jul', 'aug', 'sep', 'okt', 'nov', 'dec'
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dates = List.generate(7, (i) => today.add(Duration(days: i + 1)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Välj leveransdag'),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, i) {
              final d = dates[i];
              final selected = selectedDate != null &&
                  selectedDate!.day == d.day &&
                  selectedDate!.month == d.month;
              final weekday = _weekdayNames[d.weekday - 1];
              final month   = _monthNames[d.month];
              return GestureDetector(
                onTap: () => onDateSelected(d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 60,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.surface,
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                      width: selected ? 2 : 1,
                    ),
                    borderRadius: AppRadius.medium,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekday,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.primaryForeground
                              : AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${d.day}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.primaryForeground
                              : AppColors.foreground,
                        ),
                      ),
                      Text(
                        month,
                        style: TextStyle(
                          fontSize: 11,
                          color: selected
                              ? AppColors.primaryForeground
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
        _label('Välj tid på dagen'),
        const SizedBox(height: AppSpacing.md),
        Column(
          children: timeSlots.map((slot) {
            final selected = selectedSlot == slot;
            return GestureDetector(
              onTap: () => onSlotSelected(slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: selected ? 2 : 1,
                  ),
                  borderRadius: AppRadius.medium,
                ),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: selected ? AppColors.primary : AppColors.mutedForeground,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      slot,
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        color: selected ? AppColors.primary : AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.lg),
        ElevatedButton(onPressed: onContinue, child: const Text('Fortsätt')),
      ],
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _label(String text) => Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    );

// ─── Step card ────────────────────────────────────────────────────────────────

class _Step extends StatelessWidget {
  final int number;
  final String title;
  final int current;
  final VoidCallback onEdit;
  final String summary;
  final Widget content;

  const _Step({
    required this.number,
    required this.title,
    required this.current,
    required this.onEdit,
    required this.summary,
    required this.content,
  });

  bool get isActive => current == number;
  bool get isDone   => current > number;

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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive || isDone ? AppColors.primary : AppColors.muted,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 18, color: AppColors.primaryForeground)
                  : Text(
                      '$number',
                      style: TextStyle(
                        color: isActive
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
                            ?.copyWith(fontSize: 16)),
                    const Spacer(),
                    if (isDone)
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 14),
                        label: const Text('Ändra', style: TextStyle(fontSize: 13)),
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
                  content,
                ] else if (isDone && summary.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(summary,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.mutedForeground)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
