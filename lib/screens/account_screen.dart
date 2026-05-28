import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imat/model/imat/shopping_item.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final imat = context.watch<ImatDataHandler>();
    final customer = imat.getCustomer();
    final orders = imat.orders;
    final totalSpent = orders.fold(0.0, (s, o) => s + o.getTotal());
    final hasCustomer = customer.firstName.isNotEmpty || customer.email.isNotEmpty;

    final infoCard = Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mina uppgifter',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.lg),
            if (hasCustomer) ...[
              if (customer.fullName.isNotEmpty)
                _infoRow(context, 'Namn', customer.fullName),
              if (customer.email.isNotEmpty)
                _infoRow(context, 'E-post', customer.email),
              if (customer.phoneNumber.isNotEmpty)
                _infoRow(context, 'Telefon', customer.phoneNumber),
              if (customer.address.isNotEmpty)
                _infoRow(context, 'Adress', customer.address),
              if (customer.postCode.isNotEmpty || customer.postAddress.isNotEmpty)
                _infoRow(context, 'Ort',
                    '${customer.postCode} ${customer.postAddress}'.trim()),
            ] else
              Text(
                'Inga uppgifter sparade än',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.mutedForeground),
              ),
          ],
        ),
      ),
    );

    final statsCard = Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistik',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.lg),
            _statRow(context, 'Totalt antal köp:', '${orders.length}'),
            const SizedBox(height: AppSpacing.md),
            _statRow(context, 'Total handlad summa:',
                '${totalSpent.toStringAsFixed(0)} kr'),
          ],
        ),
      ),
    );

    final historyCard = Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Köphistorik',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.lg),
            if (orders.isEmpty)
              Text(
                'Inga tidigare beställningar',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.mutedForeground),
              )
            else
              ...orders.map((order) => _OrderCard(order: order)),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mitt konto', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: AppSpacing.xl),

          // ── Two-column dashboard layout ────────────────────────────────────
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Köphistorik (narrower)
                  Expanded(
                    flex: 5,
                    child: historyCard,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  // Right: Mina uppgifter + Statistik stacked
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        infoCard,
                        const SizedBox(height: AppSpacing.lg),
                        statsCard,
                      ],
                    ),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                historyCard,
                const SizedBox(height: AppSpacing.lg),
                infoCard,
                const SizedBox(height: AppSpacing.lg),
                statsCard,
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── Order card with expandable product list ───────────────────────────────────

class _OrderCard extends StatefulWidget {
  final dynamic order;

  const _OrderCard({required this.order});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final dateStr = _formatDate(order.date as DateTime);
    final items = order.items as List;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadius.large,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: order number + date + badge ─────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.orderNumber}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      dateStr,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: AppRadius.small,
                ),
                child: const Text(
                  'Levererad',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),

          // ── Product list ─────────────────────────────────────────────────
          if (items.isNotEmpty) _ProductRow(item: items.first),
          if (_expanded)
            ...items.skip(1).map((item) => _ProductRow(item: item)),

          if (items.length > 1) ...[
            const SizedBox(height: AppSpacing.xs),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Text(
                    _expanded
                        ? 'Visa färre'
                        : 'Visa alla ${items.length} produkter',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),

          // ── Total + reorder ──────────────────────────────────────────────
          Row(
            children: [
              Text(
                '${(order.getTotal() as double).toStringAsFixed(0)} kr',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppColors.primary),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {
                  final cartImat = context.read<ImatDataHandler>();
                  for (final item in order.items as List) {
                    cartImat.shoppingCartAdd(
                      ShoppingItem(item.product, amount: item.amount as double),
                    );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Varorna har lagts till i varukorgen'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.go('/products');
                },
                icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                label: const Text('Beställ igen'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Single product row ────────────────────────────────────────────────────────

class _ProductRow extends StatelessWidget {
  final dynamic item;

  const _ProductRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final name = item.product.name as String;
    final amount = (item.amount as num).toDouble();
    final price = (item.product.price as num).toDouble();
    final total = amount * price;
    final amountStr = amount == amount.truncateToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(1);
    final totalStr =
        '${total == total.truncateToDouble() ? total.toInt() : total.toStringAsFixed(2)} kr';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            '$amountStr ×',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.mutedForeground),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            totalStr,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

const _monthNames = [
  '', 'januari', 'februari', 'mars', 'april', 'maj', 'juni',
  'juli', 'augusti', 'september', 'oktober', 'november', 'december',
];

String _formatDate(DateTime d) => '${d.day} ${_monthNames[d.month]} ${d.year}';

Widget _infoRow(BuildContext context, String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.mutedForeground)),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );

Widget _statRow(BuildContext context, String label, String value) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.mutedForeground)),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.muted,
            borderRadius: AppRadius.extraLarge,
          ),
          child: Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
