import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';

// Maps the right-side cart sidebar from Root.tsx.
// Visible only on /products and /checkout (same condition as React).
// Shows cart items, quantity controls, total, and Checkout button.

class CartSidebar extends StatelessWidget {
  const CartSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;

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
                Text(
                  'Din varukorg',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Spacer(),
                if (cart.isNotEmpty)
                  TextButton(
                    onPressed: cartProvider.clearCart,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.destructive,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Töm korg',
                        style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Items ─────────────────────────────────────────────────────────
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🛒',
                            style: TextStyle(fontSize: 40)),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Varukorgen är tom',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.mutedForeground,
                                  ),
                        ),
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
                    itemCount: cart.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return _CartItemRow(
                        item: item,
                        onIncrease: () => cartProvider.addToCart(
                          item.product,
                          isOrganic: item.isOrganic,
                        ),
                        onDecrease: () => cartProvider.updateQuantity(
                          item.product.id,
                          item.quantity - 1,
                          isOrganic: item.isOrganic,
                        ),
                        onRemove: () => cartProvider.removeFromCart(
                          item.product.id,
                          isOrganic: item.isOrganic,
                        ),
                      );
                    },
                  ),
          ),

          // ── Footer: total + checkout ──────────────────────────────────────
          if (cart.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Totalt',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        '${cartProvider.getCartTotal().toStringAsFixed(2)} kr',
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: AppColors.primary,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/checkout'),
                      child: const Text('Till kassan →'),
                    ),
                  ),
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
  final dynamic item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemRow({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Emoji image
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: AppRadius.small,
          ),
          child: Center(
            child: Text(item.product.image,
                style: const TextStyle(fontSize: 22)),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Name + organic badge
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              if (item.isOrganic)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'EKO',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Quantity controls
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _QuantityButton(icon: Icons.remove, onTap: onDecrease),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '${item.quantity}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            _QuantityButton(icon: Icons.add, onTap: onIncrease),
          ],
        ),

        const SizedBox(width: AppSpacing.sm),

        // Line total
        SizedBox(
          width: 56,
          child: Text(
            '${item.lineTotal.toStringAsFixed(0)} kr',
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

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

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
