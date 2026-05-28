import 'package:flutter/material.dart';
import 'package:imat/config/category_config.dart';
import 'package:imat/model/imat/product.dart';
import 'package:imat/model/imat/shopping_item.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/model/internet_handler.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';
import '../widgets/layout/app_footer.dart';
import '../widgets/product_modal.dart';

class ProductsScreen extends StatefulWidget {
  final String? initialSearch;

  const ProductsScreen({super.key, this.initialSearch});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String? _selectedGroup;
  bool _showFavorites = false;
  late String _searchQuery;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
        if (_searchQuery.isNotEmpty) {
          _selectedGroup = null;
          _showFavorites = false;
        }
      });
    }
  }

  List<Product> _filter(List<Product> all, List<Product> favorites) {
    final pool = _showFavorites ? favorites : all;
    final groupCats = (!_showFavorites && _selectedGroup != null)
        ? kCategoryGroups[_selectedGroup]
        : null;
    return pool.where((p) {
      final catOk = groupCats == null || groupCats.contains(p.category);
      final searchOk =
          _searchQuery.isEmpty || p.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return catOk && searchOk;
    }).toList();
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

    final filtered = _filter(imat.selectProducts, imat.favorites);

    final availableGroups = kCategoryGroups.keys
        .where((group) => imat.products.any(
              (p) => kCategoryGroups[group]!.contains(p.category),
            ))
        .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Category sidebar (sticky) ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.xl, 0, AppSpacing.xl),
          child: SizedBox(
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

                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: SizedBox(
                    width: double.infinity,
                    child: (_selectedGroup == null && !_showFavorites)
                        ? ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedGroup = null;
                                _showFavorites = false;
                              });
                              _scrollController.jumpTo(0);
                            },
                            child: const Text('Alla'),
                          )
                        : OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedGroup = null;
                                _showFavorites = false;
                              });
                              _scrollController.jumpTo(0);
                            },
                            child: const Text('Alla'),
                          ),
                  ),
                ),

                ...availableGroups.map((group) {
                  final active = !_showFavorites && _selectedGroup == group;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: SizedBox(
                      width: double.infinity,
                      child: active
                          ? ElevatedButton(
                              onPressed: () => setState(() {
                                _selectedGroup = group;
                                _showFavorites = false;
                              }),
                              child: Text(group),
                            )
                          : OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedGroup = group;
                                  _searchQuery = '';
                                  _showFavorites = false;
                                });
                                _scrollController.jumpTo(0);
                              },
                              style: OutlinedButton.styleFrom(
                                alignment: Alignment.centerLeft,
                              ),
                              child: Text(group),
                            ),
                    ),
                  );
                }),

                const SizedBox(height: AppSpacing.sm),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: SizedBox(
                    width: double.infinity,
                    child: _showFavorites
                        ? ElevatedButton.icon(
                            onPressed: () {
                              setState(() => _showFavorites = true);
                              _scrollController.jumpTo(0);
                            },
                            icon: const Icon(Icons.favorite, size: 14),
                            label: const Text('Favoriter'),
                          )
                        : OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _showFavorites = true;
                                _selectedGroup = null;
                              });
                              _scrollController.jumpTo(0);
                            },
                            icon: const Icon(Icons.favorite_border, size: 14),
                            label: const Text('Favoriter'),
                            style: OutlinedButton.styleFrom(
                              alignment: Alignment.centerLeft,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.xl),

        // ── Product grid (scrollable) ─────────────────────────────────────
        Expanded(
          child: ScrollbarTheme(
            data: ScrollbarThemeData(
              thumbColor: WidgetStateProperty.all(AppColors.primary),
              trackColor: WidgetStateProperty.all(
                  AppColors.primary.withValues(alpha: 0.15)),
              thumbVisibility: WidgetStateProperty.all(true),
              trackVisibility: WidgetStateProperty.all(true),
              thickness: WidgetStateProperty.all(6),
              radius: const Radius.circular(3),
            ),
            child: Scrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(
                    0, AppSpacing.xl, AppSpacing.xl, AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_searchQuery.isNotEmpty) ...[
                      Text(
                        'Bästa resultat',
                        style: Theme.of(context).textTheme.headlineMedium,
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
                          childAspectRatio: 0.55,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _ProductCard(
                          product: filtered[index],
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
                    const SizedBox(height: 300),
                    const AppFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatefulWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  final _cardKey = GlobalKey();

  void _open() {
    final box = _cardKey.currentContext!.findRenderObject() as RenderBox;
    final imat = context.read<ImatDataHandler>();
    final cartItem = imat.cartItems.cast<ShoppingItem?>().firstWhere(
      (i) => i?.product.productId == widget.product.productId,
      orElse: () => null,
    );
    showProductPopup(context, widget.product, box,
        initialQuantity: cartItem?.amount.round() ?? 1);
  }

  @override
  Widget build(BuildContext context) {
    final imat = context.watch<ImatDataHandler>();
    final isFav = imat.isFavorite(widget.product);
    final img = InternetHandler.cachedImage(widget.product.productId);
    final inCart = imat.cartItems.any(
      (i) => i.product.productId == widget.product.productId,
    );

    return Card(
      key: _cardKey,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image with favourite heart overlay
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
                  right: 6,
                  child: GestureDetector(
                    onTap: () => imat.toggleFavorite(widget.product),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.red : AppColors.mutedForeground,
                        size: 15,
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
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (widget.product.isEcological)
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
              child: inCart
                  ? ElevatedButton.icon(
                      onPressed: _open,
                      icon: const Icon(Icons.check, size: 15),
                      label: const Text('Tillagd'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                        backgroundColor: AppColors.muted,
                        foregroundColor: AppColors.mutedForeground,
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _open,
                      icon: const Icon(Icons.add, size: 15),
                      label: const Text('Välj'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
