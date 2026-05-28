import 'package:flutter/material.dart';
import 'package:imat/model/imat/product.dart';
import 'package:imat/model/imat/shopping_item.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/model/internet_handler.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';

/// Shows a quantity-picker popup positioned over the tapped product card.
/// [initialQuantity] pre-fills the stepper with the current cart amount.
void showProductPopup(
  BuildContext context,
  Product product,
  RenderBox cardBox, {
  int initialQuantity = 1,
}) {
  final cardOffset = cardBox.localToGlobal(Offset.zero);
  final cardSize   = cardBox.size;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _ProductPopupOverlay(
      product:         product,
      cardOffset:      cardOffset,
      cardSize:        cardSize,
      onDismiss:       () => entry.remove(),
      initialQuantity: initialQuantity,
    ),
  );
  Overlay.of(context).insert(entry);
}

// ─── Overlay widget ───────────────────────────────────────────────────────────

class _ProductPopupOverlay extends StatefulWidget {
  final Product      product;
  final Offset       cardOffset;
  final Size         cardSize;
  final VoidCallback onDismiss;
  final int          initialQuantity;

  const _ProductPopupOverlay({
    required this.product,
    required this.cardOffset,
    required this.cardSize,
    required this.onDismiss,
    required this.initialQuantity,
  });

  @override
  State<_ProductPopupOverlay> createState() => _ProductPopupOverlayState();
}

class _ProductPopupOverlayState extends State<_ProductPopupOverlay> {
  late int _quantity;

  static const double _popupWidth  = 260.0;
  static const double _popupHeight = 420.0;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  void _addToCart() {
    final imat = context.read<ImatDataHandler>();
    // Remove existing entry (if any) so we SET quantity, not accumulate.
    final existing = imat.cartItems.cast<ShoppingItem?>().firstWhere(
      (i) => i?.product.productId == widget.product.productId,
      orElse: () => null,
    );
    if (existing != null) imat.shoppingCartRemove(existing);
    if (_quantity > 0) {
      imat.shoppingCartAdd(ShoppingItem(widget.product, amount: _quantity.toDouble()));
    }
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    double left = widget.cardOffset.dx + widget.cardSize.width  / 2 - _popupWidth  / 2;
    double top  = widget.cardOffset.dy + widget.cardSize.height / 2 - _popupHeight / 2;
    left = left.clamp(8.0, screen.width  - _popupWidth  - 8);
    top  = top .clamp(8.0, screen.height - _popupHeight - 8);

    final img = InternetHandler.cachedImage(widget.product.productId, fit: BoxFit.contain);
    final priceStr =
        '${widget.product.price.toStringAsFixed(widget.product.price.truncateToDouble() == widget.product.price ? 0 : 2)} kr/${widget.product.unit}';

    return Stack(
      children: [
        // ── Backdrop ──────────────────────────────────────────────────────────
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            child: Container(color: Colors.black.withValues(alpha: 0.35)),
          ),
        ),

        // ── Popup card ────────────────────────────────────────────────────────
        Positioned(
          left:  left,
          top:   top,
          width: _popupWidth,
          child: Material(
            elevation:    12,
            borderRadius: BorderRadius.circular(16),
            color:        AppColors.surface,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onDismiss,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.primaryForeground,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Stäng'),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Image
                  SizedBox(
                    height: 90,
                    child: img ??
                        Image.asset('assets/images/placeholder.png',
                            height: 90, fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 10),

                  // Name
                  Text(
                    widget.product.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Price
                  Text(
                    priceStr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quantity stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SmallBtn(
                        icon:  Icons.remove,
                        onTap: () => setState(
                            () => _quantity = (_quantity - 1).clamp(1, 99)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ),
                      _SmallBtn(
                        icon:  Icons.add,
                        onTap: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Add / update cart
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      child: Text(
                        _quantity > 1
                            ? 'Lägg till $_quantity st'
                            : 'Lägg till',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _SmallBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;

  const _SmallBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(36, 36),
        padding:     EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
      ),
      child: Icon(icon, size: 18),
    );
  }
}
