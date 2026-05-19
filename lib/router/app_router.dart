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
      // Ändrat till pageBuilder för att ta bort animationen på själva skalet
      pageBuilder: (context, state, child) => NoTransitionPage(
        child: AppScaffold(child: child),
      ),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/products',
          pageBuilder: (context, state) {
            final query = state.uri.queryParameters['q'];
            return NoTransitionPage(
              child: ProductsScreen(initialSearch: query),
            );
          },
        ),
        GoRoute(
          path: '/checkout',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CheckoutScreen(),
          ),
        ),
        GoRoute(
          path: '/account',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AccountScreen(),
          ),
        ),
        GoRoute(
          path: '/contact',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ContactScreen(),
          ),
        ),
      ],
    ),
  ],
);