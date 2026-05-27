import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imat/model/imat/shopping_item.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/model/internet_handler.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';

class CartSidebar extends StatelessWidget {
  const CartSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final imat = context.watch<ImatDataHandler>();
    final items = imat.cartItems;
    final onCheckout = GoRouterState.of(context).uri.path == '/checkout';

    return Container(
      width: 320,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_outlined,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Din varukorg',
                    style: Theme.of(context).textTheme.headlineMedium),
                const Spacer(),
                if (items.isNotEmpty)
                  TextButton(
                    onPressed: imat.shoppingCartClear,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.destructive,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Töm korg', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Items ─────────────────────────────────────────────────────────
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🛒', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: AppSpacing.md),
                        Text('Varukorgen är tom',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.mutedForeground,
                                )),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: () => context.go('/products'),
                          child: const Text('Börja handla →'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) => _CartItemRow(
                      item: items[i],
                      imat: imat,
                    ),
                  ),
          ),

          // ── Footer ────────────────────────────────────────────────────────
          if (items.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Totalt',
                          style: Theme.of(context).textTheme.headlineMedium),
                      Text(
                        '${imat.shoppingCartTotal().toStringAsFixed(2)} kr',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  if (!onCheckout) ...[
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/checkout'),
                        child: const Text('Till kassan →'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final ShoppingItem item;
  final ImatDataHandler imat;

  const _CartItemRow({required this.item, required this.imat});

  @override
  Widget build(BuildContext context) {
    final img = InternetHandler.cachedImage(item.product.productId, fit: BoxFit.cover);

    return Row(
      children: [
        // Product image
        ClipRRect(
          borderRadius: AppRadius.small,
          child: SizedBox(
            width: 40,
            height: 40,
            child: img ??
                Container(
                  color: AppColors.accent,
                  child: Image.asset('assets/images/placeholder.png',
                      fit: BoxFit.cover),
                ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Name
        Expanded(
          child: Text(
            item.product.name,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Quantity controls
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _QtyBtn(
              icon: Icons.remove,
              onTap: () => imat.shoppingCartUpdate(item, delta: -1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text('${item.amount.round()}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
            _QtyBtn(
              icon: Icons.add,
              onTap: () => imat.shoppingCartUpdate(item, delta: 1),
            ),
          ],
        ),

        const SizedBox(width: AppSpacing.sm),

        // Line total
        SizedBox(
          width: 56,
          child: Text(
            '${item.total.toStringAsFixed(0)} kr',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
          ),
        ),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14, color: AppColors.foreground),
      ),
    );
  }
}
