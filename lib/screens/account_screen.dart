import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';

// Maps Account.tsx — user profile card + stats card + order history

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final userData = cartProvider.userData;
    final orders = cartProvider.orders;
    final totalSpent = orders.fold(0.0, (s, o) => s + o.total);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mitt konto',
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xl),

              // ── Top row: Mina uppgifter + Statistik ───────────────────────
              LayoutBuilder(builder: (context, constraints) {
                final twoCol = constraints.maxWidth > 600;
                final cards = [
                  // Mina uppgifter
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mina uppgifter',
                              style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: AppSpacing.lg),
                          if (userData != null) ...[
                            _infoRow(context, 'Namn', userData.name),
                            _infoRow(context, 'E-post', userData.email),
                            if (userData.phone.isNotEmpty)
                              _infoRow(context, 'Telefon', userData.phone),
                            _infoRow(context, 'Adress', userData.address),
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

                  // Statistik
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
                          _statRow(
                            context,
                            'Total handlad summa:',
                            '${totalSpent.toStringAsFixed(0)} kr',
                          ),
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
                    : Column(
                        children: [
                          cards[0],
                          const SizedBox(height: AppSpacing.lg),
                          cards[1],
                        ],
                      );
              }),

              const SizedBox(height: AppSpacing.xl),

              // ── Köphistorik ───────────────────────────────────────────────
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
                          final dateStr = DateFormat('d MMMM yyyy', 'sv_SE')
                              .format(order.date);
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Order #${order.id}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                    fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            dateStr,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    color: AppColors.mutedForeground),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xs,
                                      ),
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

                                // Items preview
                                Wrap(
                                  spacing: AppSpacing.sm,
                                  children: order.items
                                      .take(4)
                                      .map((item) => Text(
                                            item.product.image,
                                            style: const TextStyle(fontSize: 22),
                                          ))
                                      .toList(),
                                ),

                                const SizedBox(height: AppSpacing.md),

                                Row(
                                  children: [
                                    Text(
                                      '${order.total.toStringAsFixed(0)} kr',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(color: AppColors.primary),
                                    ),
                                    const Spacer(),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        final cartProv = context.read<CartProvider>();
                                        for (final item in order.items) {
                                          for (int i = 0; i < item.quantity; i++) {
                                            cartProv.addToCart(
                                              item.product,
                                              isOrganic: item.isOrganic,
                                            );
                                          }
                                        }
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Varorna har lagts till i kundvagnen',
                                            ),
                                            backgroundColor: AppColors.primary,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                        context.go('/products');
                                      },
                                      icon: const Icon(
                                          Icons.shopping_cart_outlined,
                                          size: 16),
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
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.muted,
            borderRadius: AppRadius.extraLarge,
          ),
          child: Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
