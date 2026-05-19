import 'package:flutter/material.dart';
import 'package:imat/config/category_config.dart';
import 'package:imat/model/imat/product.dart';
import 'package:imat/model/imat/shopping_item.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/model/internet_handler.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';

// Maps Products.tsx with API-backed products and real images.
// Categories configurable in lib/config/category_config.dart.

class ProductsScreen extends StatefulWidget {
  final String? initialSearch;

  const ProductsScreen({super.key, this.initialSearch});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // null = "Alla" (inga filter)
  ProductCategory? _selectedCategory;
  late String _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearch ?? '';
  }

  @override
  void didUpdateWidget(ProductsScreen old) {
    super.didUpdateWidget(old);
    if (widget.initialSearch != old.initialSearch) {
      setState(() {
        _searchQuery = widget.initialSearch ?? '';
        if (_searchQuery.isNotEmpty) _selectedCategory = null;
      });
    }
  }

  List<Product> _filter(List<Product> all) {
    return all.where((p) {
      final catOk = _selectedCategory == null || p.category == _selectedCategory;
      final searchOk =
          _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return catOk && searchOk;
    }).toList();
  }

  void _openModal(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductModal(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imat = context.watch<ImatDataHandler>();

    if (imat.isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.lg),
            Text('Laddar produkter...'),
          ],
        ),
      );
    }

    final filtered = _filter(imat.selectProducts);

    // Only show categories that actually have products in the current assortment
    final availableCategories = kShownCategories
        .where((cat) => imat.products.any((p) => p.category == cat))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category sidebar ──────────────────────────────────────────────
          SizedBox(
            width: 190,
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

                // "Alla" button
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: SizedBox(
                    width: double.infinity,
                    child: _selectedCategory == null
                        ? ElevatedButton(
                            onPressed: () => setState(() => _selectedCategory = null),
                            child: const Text('Alla'),
                          )
                        : OutlinedButton(
                            onPressed: () => setState(() => _selectedCategory = null),
                            child: const Text('Alla'),
                          ),
                  ),
                ),

                // Category buttons — edit kShownCategories in category_config.dart
                ...availableCategories.map((cat) {
                  final active = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: SizedBox(
                      width: double.infinity,
                      child: active
                          ? ElevatedButton(
                              onPressed: () => setState(() => _selectedCategory = cat),
                              child: Text(categoryLabel(cat)),
                            )
                          : OutlinedButton(
                              onPressed: () => setState(() {
                                _selectedCategory = cat;
                                _searchQuery = '';
                              }),
                              style: OutlinedButton.styleFrom(
                                alignment: Alignment.centerLeft,
                              ),
                              child: Text(categoryLabel(cat)),
                            ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.xl),

          // ── Product grid ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_searchQuery.isNotEmpty) ...[
                  Text.rich(
                    TextSpan(
                      text: 'Visar resultat för: ',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.mutedForeground),
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
                      childAspectRatio: 0.62,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _ProductCard(
                      product: filtered[index],
                      imat: imat,
                      onTap: () => _openModal(filtered[index]),
                    ),
                  );
                }),

                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Center(
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
  final ImatDataHandler imat;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.imat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final img = InternetHandler.cachedImage(product.productId);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: SizedBox(
                width: double.infinity,
                child: img ??
                    Container(
                      color: AppColors.accent,
                      child: Image.asset(
                        'assets/images/placeholder.png',
                        fit: BoxFit.cover,
                      ),
                    ),
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
                      product.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.price.toStringAsFixed(product.price.truncateToDouble() == product.price ? 0 : 2)} kr/${product.unit}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (product.isEcological)
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'EKO',
                          style: TextStyle(
                            color: AppColors.primaryForeground,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Add button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.add, size: 15),
                  label: const Text('Välj'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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

// ─── Product Modal (Bottom Sheet) ─────────────────────────────────────────────

class _ProductModal extends StatefulWidget {
  final Product product;

  const _ProductModal({required this.product});

  @override
  State<_ProductModal> createState() => _ProductModalState();
}

class _ProductModalState extends State<_ProductModal> {
  int _quantity = 1;

  void _addToCart() {
    final imat = context.read<ImatDataHandler>();
    imat.shoppingCartAdd(
      ShoppingItem(widget.product, amount: _quantity.toDouble()),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} tillagd i varukorgen!'),
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
    final detail = context.read<ImatDataHandler>().getDetail(product);
    final img = InternetHandler.cachedImage(product.productId, fit: BoxFit.contain);

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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Image
            ClipRRect(
              borderRadius: AppRadius.large,
              child: SizedBox(
                height: 140,
                child: img ??
                    Image.asset('assets/images/placeholder.png',
                        height: 140, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Name + category + eco badge
            Text(product.name, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 4),
            Text(
              categoryLabel(product.category),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.mutedForeground),
            ),
            if (product.isEcological) ...[
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.extraLarge,
                ),
                child: const Text(
                  'EKOLOGISK',
                  style: TextStyle(
                    color: AppColors.primaryForeground,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],

            // Detail info (brand, origin)
            if (detail != null) ...[
              const SizedBox(height: AppSpacing.sm),
              if (detail.brand.isNotEmpty)
                Text(detail.brand,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.mutedForeground)),
              if (detail.origin.isNotEmpty)
                Text('Ursprung: ${detail.origin}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.mutedForeground)),
            ],

            const SizedBox(height: AppSpacing.xl),

            // Price
            Text(
              '${product.price.toStringAsFixed(product.price.truncateToDouble() == product.price ? 0 : 2)} kr/${product.unit}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontSize: 20,
                  ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Quantity picker
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _QtyBtn(
                  icon: Icons.remove,
                  onTap: () => setState(() => _quantity = (_quantity - 1).clamp(1, 99)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
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

            // Total + add button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: Text(
                  _quantity > 1
                      ? 'Lägg till $_quantity st  ·  ${(product.price * _quantity).toStringAsFixed(2)} kr'
                      : 'Lägg till i varukorgen',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),
          ],
        ),
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
        minimumSize: const Size(44, 44),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
      ),
      child: Icon(icon, size: 20),
    );
  }
}
