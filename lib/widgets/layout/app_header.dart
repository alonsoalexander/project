import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';

// Maps the sticky header in Root.tsx:
// Logo | Search bar | Nav links (Startsida, Handla, Kontakt, Mitt konto) | Kassa button with cart badge

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchSubmit;

  const AppHeader({
    super.key,
    required this.searchController,
    required this.onSearchSubmit,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final location = GoRouterState.of(context).uri.path;

    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            children: [
              // ── Logo ──────────────────────────────────────────────────────
              GestureDetector(
                onTap: () => context.go('/'),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadius.medium,
                      ),
                      child: const Center(
                        child: Text('🛒', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'iMat',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.xl),

              // ── Search bar (desktop) ───────────────────────────────────────
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: TextField(
                    controller: searchController,
                    onSubmitted: (_) => onSearchSubmit(),
                    decoration: InputDecoration(
                      hintText: 'Sök produkter...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                searchController.clear();
                                onSearchSubmit();
                              },
                            )
                          : null,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.lg),

              // ── Nav links ─────────────────────────────────────────────────
              _NavLink(
                label: 'Startsida',
                path: '/',
                active: location == '/',
              ),
              _NavLink(
                label: 'Handla',
                path: '/products',
                active: location == '/products',
              ),
              _NavLink(
                label: 'Kontakt',
                path: '/contact',
                active: location == '/contact',
              ),
              _NavLink(
                label: 'Mitt konto',
                path: '/account',
                active: location == '/account',
              ),

              const SizedBox(width: AppSpacing.sm),

              // ── Kassa button with cart badge ──────────────────────────────
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.go('/checkout'),
                    icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                    label: const Text('Kassa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: location == '/checkout'
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.9),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),
                  if (cart.cartItemCount > 0)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${cart.cartItemCount}',
                            style: const TextStyle(
                              color: AppColors.primaryForeground,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final String path;
  final bool active;

  const _NavLink({
    required this.label,
    required this.path,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => context.go(path),
      style: TextButton.styleFrom(
        foregroundColor: active ? AppColors.primary : AppColors.foreground,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          if (active)
            Container(
              margin: const EdgeInsets.only(top: 2),
              height: 2,
              width: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }
}
