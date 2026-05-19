import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/products_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/account_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/not_found_screen.dart';
import '../widgets/layout/app_scaffold.dart';

// ─── GoRouter ──────────────────────────────────────────────────────────────────
// Maps the React Router v7 route tree from src/app/routes.tsx
//
// React:                Flutter:
// / (Root layout)   →   AppScaffold shell route
//   /               →   HomeScreen
//   /products       →   ProductsScreen
//   /checkout       →   CheckoutScreen
//   /account        →   AccountScreen
//   /contact        →   ContactScreen
//   * (404)         →   NotFoundScreen

final appRouter = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) {
            final query = state.uri.queryParameters['q'];
            return ProductsScreen(initialSearch: query);
          },
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: '/account',
          builder: (context, state) => const AccountScreen(),
        ),
        GoRoute(
          path: '/contact',
          builder: (context, state) => const ContactScreen(),
        ),
      ],
    ),
  ],
);
