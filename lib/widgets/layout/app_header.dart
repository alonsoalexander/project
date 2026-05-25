import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../model/imat_data_handler.dart';
import '../../theme/app_theme.dart';

// Maps the sticky header in Root.tsx:
// Logo | Search bar | Nav links (Startsida, Handla, Kontakt, Mitt konto) | Kassa button with cart badge

const _navItems = [
  (label: 'Startsida', path: '/'),
  (label: 'Handla', path: '/products'),
  (label: 'Kontakt', path: '/contact'),
  (label: 'Mitt konto', path: '/account'),
];

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchSubmit;

  const AppHeader({
    super.key,
    required this.searchController,
    required this.onSearchSubmit,
  });

  @override
  Size get preferredSize => const Size.fromHeight(500);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<ImatDataHandler>();
    final location = GoRouterState.of(context).uri.path;

    return Container(
      height: 100,
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
                    Image.asset(
                      'assets/images/logga-imat.png',
                      fit: BoxFit.cover,
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
              ..._navItems.expand((item) => [
                    _NavLink(
                      label: item.label,
                      path: item.path,
                      active: location == item.path,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ]),

              const SizedBox(width: AppSpacing.sm),

              // ── Kassa button with cart badge ──────────────────────────────
              // ── Kassa button with cart badge ──────────────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                _NavLink(
                  label: 'Kassa',
                  path: '/checkout',
                  active: location == '/checkout',
                  icon: Icons.shopping_cart_outlined,
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
  final IconData? icon;
  final String path;
  final bool active;

  const _NavLink({
    required this.label,
    required this.path,
    required this.active,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.go(path),
      style: ElevatedButton.styleFrom(
        backgroundColor: active
            ? AppColors.primary
            : const Color.fromARGB(255, 255, 255, 255),
        foregroundColor:
            active ? AppColors.primaryForeground : AppColors.foreground,
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.medium,
        ),
      ),
      child: icon != null
    ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Text(label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
        ],
      )
      :Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}
