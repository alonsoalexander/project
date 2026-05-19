import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../cart/cart_sidebar.dart';
import 'app_footer.dart';
import 'app_header.dart';

// Maps Root.tsx: header + content outlet + optional right sidebar + footer.
// Sidebar shown only on /products and /checkout (same condition as React).

class AppScaffold extends StatefulWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchSubmit() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.go('/products?q=${Uri.encodeComponent(query)}');
    }
  }

  bool _showSidebar(String path) =>
      path == '/products' || path == '/checkout';

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final showSidebar = _showSidebar(location);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        searchController: _searchController,
        onSearchSubmit: _handleSearchSubmit,
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 600),
                          child: widget.child,
                        ),
                        const AppFooter(),
                      ],
                    ),
                  ),
                ),

                // Right sidebar — cart (only on /products and /checkout)
                if (showSidebar) const CartSidebar(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
