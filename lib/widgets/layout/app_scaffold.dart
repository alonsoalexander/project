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

  void _handleSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.go('/products?q=${Uri.encodeComponent(query)}');
    } else if (GoRouterState.of(context).uri.path == '/products') {
      context.go('/products');
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
        onSearchChanged: _handleSearchChanged,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: location == '/products'
                ? widget.child
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 600),
                          child: widget.child,
                        ),
                        const SizedBox(height: 300),
                        const AppFooter(),
                      ],
                    ),
                  ),
          ),

          // Right sidebar — cart (only on /products and /checkout)
          if (showSidebar) const CartSidebar(),
        ],
      ),
    );
  }
}
