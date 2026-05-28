import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:imat/model/imat/product.dart';
import 'package:imat/model/imat/shopping_item.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/model/internet_handler.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';

// Product IDs and their sale prices for Veckans klipp
const _dealPrices = {
  2:  19.0,
  7:  10.0,
  6:  15.0,
  1:  14.0,
  15: 29.0,
  20: 18.0,
};

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final imat = context.watch<ImatDataHandler>();

    final deals = _dealPrices.keys
        .map((id) => imat.getProduct(id))
        .whereType<Product>()
        .toList();

    return Column(
      children: [
        // ── Hero section ──────────────────────────────────────────────────────
        _HeroSection(),

        // ── Veckans klipp ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Gradient header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF16A34A), Color(0xFFDC2626)],
                    ),
                  ),
                  child: Text(
                    'Veckans klipp',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),

                // Deal cards grid
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: imat.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(AppSpacing.xxxl),
                          child: CircularProgressIndicator(),
                        )
                      : LayoutBuilder(builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 800
                              ? 6
                              : constraints.maxWidth > 500
                                  ? 3
                                  : 2;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: AppSpacing.md,
                              mainAxisSpacing: AppSpacing.md,
                              childAspectRatio: 0.58,
                            ),
                            itemCount: deals.length,
                            itemBuilder: (context, index) {
                              final product = deals[index];
                              final salePrice = _dealPrices[product.productId]!;
                              return _DealCard(
                                product: product,
                                salePrice: salePrice,
                              );
                            },
                          );
                        }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/feature-image.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Image error: $error');
              return Container(color: Colors.red);
            },
          ),
          Container(color: Colors.black.withValues(alpha: 0.6)),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxxl,
                  vertical: AppSpacing.xxl,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Välkommen till iMat',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: AppColors.foreground,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Handla färska varor direkt hem till dig.\nEnkel betalning, snabb leverans.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.foreground.withValues(alpha: 0.8),
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/products'),
                      icon: const Icon(Icons.arrow_forward, size: 28),
                      label: const Text(
                        'Börja handla',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 20,
                        ),
                        elevation: 18,
                        shadowColor: AppColors.primary.withValues(alpha: 0.55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DealCard extends StatefulWidget {
  final Product product;
  final double salePrice;

  const _DealCard({required this.product, required this.salePrice});

  @override
  State<_DealCard> createState() => _DealCardState();
}

class _DealCardState extends State<_DealCard> {
  int _localQty = 1;

  void _decrement(ImatDataHandler imat, ShoppingItem? cartItem) {
    if (cartItem != null) {
      imat.shoppingCartUpdate(cartItem, delta: -1);
    } else {
      if (_localQty > 1) setState(() => _localQty--);
    }
  }

  void _increment(ImatDataHandler imat, ShoppingItem? cartItem) {
    if (cartItem != null) {
      imat.shoppingCartUpdate(cartItem, delta: 1);
    } else {
      setState(() => _localQty++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imat = context.watch<ImatDataHandler>();
    final img = InternetHandler.cachedImage(widget.product.productId);
    final cartItem = imat.cartItems.cast<ShoppingItem?>().firstWhere(
      (i) => i?.product.productId == widget.product.productId,
      orElse: () => null,
    );
    final inCart = cartItem != null;
    final displayQty = inCart ? cartItem.amount.round() : _localQty;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                img ??
                    Container(
                      color: AppColors.accent,
                      child: Image.asset(
                        'assets/images/placeholder.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Kampanj',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.product.price.toStringAsFixed(widget.product.price.truncateToDouble() == widget.product.price ? 0 : 2)} kr/${widget.product.unit}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.mutedForeground,
                        ),
                  ),
                  Text(
                    '${widget.salePrice.toStringAsFixed(widget.salePrice.truncateToDouble() == widget.salePrice ? 0 : 2)} kr/${widget.product.unit}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFDC2626),
                        ),
                  ),
                ],
              ),
            ),
          ),

          // Stepper (always visible) + Välj/Tillagd button
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quantity stepper
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StepBtn(
                      icon: Icons.remove,
                      onTap: () => _decrement(imat, cartItem),
                    ),
                    SizedBox(
                      width: 34,
                      child: Text(
                        '$displayQty',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    _StepBtn(
                      icon: Icons.add,
                      onTap: () => _increment(imat, cartItem),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // Välj / Tillagd button
                SizedBox(
                  width: double.infinity,
                  child: inCart
                      ? ElevatedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.check_circle, size: 15),
                          label: const Text('Tillagd'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            textStyle: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.accent,
                            disabledForegroundColor: AppColors.primary,
                          ),
                        )
                      : ElevatedButton.icon(
                          onPressed: () => imat.shoppingCartAdd(
                              ShoppingItem(widget.product, amount: _localQty.toDouble())),
                          icon: const Icon(Icons.add, size: 15),
                          label: const Text('Välj'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            textStyle: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(28, 28),
          padding: const EdgeInsets.all(0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6))),
        ),
        child: Icon(icon, size: 13),
      ),
    );
  }
}
