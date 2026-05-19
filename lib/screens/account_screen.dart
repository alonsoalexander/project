import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imat/model/imat/shopping_item.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:intl/intl.dart';
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mitt konto', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xl),

              // ── Top row ───────────────────────────────────────────────────
              LayoutBuilder(builder: (context, constraints) {
                final twoCol = constraints.maxWidth > 600;
                final cards = [
                  Card(
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
                  ),
                  Card(
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
                  ),
                ];

                return twoCol
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: cards[0]),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(child: cards[1]),
                        ],
                      )
                    : Column(children: [
                        cards[0],
                        const SizedBox(height: AppSpacing.lg),
                        cards[1],
                      ]);
              }),

              const SizedBox(height: AppSpacing.xl),

              // ── Order history ─────────────────────────────────────────────
              Card(
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
                        ...orders.map((order) {
                          final dateStr = DateFormat('d MMMM yyyy', 'sv_SE').format(order.date);
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Order #${order.orderNumber}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(fontWeight: FontWeight.w600)),
                                          Text(dateStr,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                      color: AppColors.mutedForeground)),
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
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  order.items.map((i) => i.product.name).take(4).join(', ') +
                                      (order.items.length > 4 ? '...' : ''),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppColors.mutedForeground),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Text(
                                      '${order.getTotal().toStringAsFixed(0)} kr',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(color: AppColors.primary),
                                    ),
                                    const Spacer(),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        final cartImat = context.read<ImatDataHandler>();
                                        for (final item in order.items) {
                                          cartImat.shoppingCartAdd(
                                            ShoppingItem(item.product, amount: item.amount),
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
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
