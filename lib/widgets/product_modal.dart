import 'package:flutter/material.dart';
import 'package:imat/model/imat/product.dart';
import 'package:imat/model/imat/shopping_item.dart';
import 'package:imat/model/imat_data_handler.dart';
import 'package:imat/model/internet_handler.dart';
import 'package:provider/provider.dart';

import '../theme/app_theme.dart';

/// Shows a compact quantity-picker popup positioned over the tapped product card.
void showProductPopup(BuildContext context, Product product, RenderBox cardBox) {
  final cardOffset = cardBox.localToGlobal(Offset.zero);
  final cardSize   = cardBox.size;

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _ProductPopupOverlay(
      product:    product,
      cardOffset: cardOffset,
      cardSize:   cardSize,
      onDismiss:  () => entry.remove(),
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

  const _ProductPopupOverlay({
    required this.product,
    required this.cardOffset,
    required this.cardSize,
    required this.onDismiss,
  });

  @override
  State<_ProductPopupOverlay> createState() => _ProductPopupOverlayState();
}

class _ProductPopupOverlayState extends State<_ProductPopupOverlay> {
  int _quantity = 1;

  static const double _popupWidth  = 240.0;
  static const double _popupHeight = 360.0;

  void _addToCart() {
    context.read<ImatDataHandler>().shoppingCartAdd(
      ShoppingItem(widget.product, amount: _quantity.toDouble()),
    );
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    // Centre popup on the card, then clamp to screen bounds
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: widget.onDismiss,
                      child: const Icon(Icons.close, size: 18,
                          color: AppColors.mutedForeground),
                    ),
                  ),
                  const SizedBox(height: 4),

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

                  // Add to cart
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
                            : 'Lägg i varukorgen',
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
