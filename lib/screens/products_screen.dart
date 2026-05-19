import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/products_data.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';

// Maps Products.tsx:
// Left sidebar: category filter
// Main: product grid with search filter
// Click card → modal bottom sheet (popover) with quantity + organic/regular choice

class ProductsScreen extends StatefulWidget {
  final String? initialSearch;

  const ProductsScreen({super.key, this.initialSearch});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _selectedCategory = 'Alla';
  late String _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearch ?? '';
    // Mirror React: if search is present, reset category to "Alla"
    if (_searchQuery.isNotEmpty) _selectedCategory = 'Alla';
  }

  @override
  void didUpdateWidget(ProductsScreen old) {
    super.didUpdateWidget(old);
    if (widget.initialSearch != old.initialSearch) {
      setState(() {
        _searchQuery = widget.initialSearch ?? '';
        if (_searchQuery.isNotEmpty) _selectedCategory = 'Alla';
      });
    }
  }

  List<Product> get _filtered => products.where((p) {
        final matchCat =
            _selectedCategory == 'Alla' || p.category == _selectedCategory;
        final matchSearch =
            p.name.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchCat && matchSearch;
      }).toList();

  void _openProductModal(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductPopover(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left category sidebar ─────────────────────────────────────────
          SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avdelningar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.mutedForeground,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...categories.map((cat) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: SizedBox(
                        width: double.infinity,
                        child: _selectedCategory == cat
                            ? ElevatedButton(
                                onPressed: () =>
                                    setState(() => _selectedCategory = cat),
                                child: Text(cat),
                              )
                            : OutlinedButton(
                                onPressed: () =>
                                    setState(() => _selectedCategory = cat),
                                child: Text(cat),
                              ),
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.xl),

          // ── Product grid ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search info
                if (_searchQuery.isNotEmpty) ...[
                  Text.rich(
                    TextSpan(
                      text: 'Visar resultat för: ',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                      children: [
                        TextSpan(
                          text: '"$_searchQuery"',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Grid
                LayoutBuilder(builder: (context, constraints) {
                  final cols = constraints.maxWidth > 700
                      ? 4
                      : constraints.maxWidth > 450
                          ? 3
                          : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _ProductCard(
                      product: filtered[index],
                      onTap: () => _openProductModal(filtered[index]),
                    ),
                  );
                }),

                if (filtered.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxxl),
                      child: Text(
                        'Inga produkter hittades.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.mutedForeground,
                            ),
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

// ─── Product Card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(product.image,
                          style: const TextStyle(fontSize: 52)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'fr. ${product.price.toStringAsFixed(0)} kr/${product.unit}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

            // Footer button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.md,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Välj'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle:
                        const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Product Popover (Bottom Sheet) ──────────────────────────────────────────
// Maps the overlay popover in Products.tsx — quantity picker + organic/regular

class _ProductPopover extends StatefulWidget {
  final Product product;

  const _ProductPopover({required this.product});

  @override
  State<_ProductPopover> createState() => _ProductPopoverState();
}

class _ProductPopoverState extends State<_ProductPopover> {
  int _quantity = 1;

  void _addToCart(bool isOrganic) {
    final cart = context.read<CartProvider>();
    for (int i = 0; i < _quantity; i++) {
      cart.addToCart(widget.product, isOrganic: isOrganic);
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.product.name} tillagd i varukorgen!',
          style: const TextStyle(color: AppColors.primaryForeground),
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Emoji + name
          Text(product.image, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: AppSpacing.md),
          Text(product.name,
              style: Theme.of(context).textTheme.displaySmall),
          Text(
            product.category,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedForeground,
                ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Quantity picker
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _QtyBtn(
                icon: Icons.remove,
                onTap: () =>
                    setState(() => _quantity = (_quantity - 1).clamp(1, 99)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  '$_quantity',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              _QtyBtn(
                icon: Icons.add,
                onTap: () => setState(() => _quantity++),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Organic option
          if (product.hasOrganic)
            _ChoiceButton(
              onTap: () => _addToCart(true),
              borderColor: AppColors.primary,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Ekologisk',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                )),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'EKO',
                                style: TextStyle(
                                  color: AppColors.primaryForeground,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Utan kemiska bekämpningsmedel',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${product.organicPrice?.toStringAsFixed(0)} kr/${product.unit}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      if (_quantity > 1)
                        Text(
                          'Totalt: ${((product.organicPrice ?? 0) * _quantity).toStringAsFixed(0)} kr',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.sm),

          // Regular option
          _ChoiceButton(
            onTap: () => _addToCart(false),
            borderColor: AppColors.border,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Konventionell',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          )),
                      const SizedBox(height: 2),
                      Text(
                        'Standardodlad vara',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(0)} kr/${product.unit}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (_quantity > 1)
                      Text(
                        'Totalt: ${(product.price * _quantity).toStringAsFixed(0)} kr',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(40, 40),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
      ),
      child: Icon(icon, size: 18),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color borderColor;
  final Widget child;

  const _ChoiceButton({
    required this.onTap,
    required this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2),
          borderRadius: AppRadius.large,
        ),
        child: child,
      ),
    );
  }
}
