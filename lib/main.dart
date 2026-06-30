import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'ui/screens.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.purple,
      secondary: Colors.deepOrange,
      surface: Colors.white,
      surfaceTint: Colors.grey[200],
    );

    final themeData = ThemeData(
      fontFamily: 'Lato',
      colorScheme: colorScheme,

      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),

      dialogTheme: DialogThemeData(
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
        ),
      ),
    );

    final authManager = AuthManager();

    final router = GoRouter(
      debugLogDiagnostics: true,
      initialLocation: '/auto-login',
      refreshListenable: authManager,
      redirect: (context, state) {
        final authManager = context.read<AuthManager>();
        final isAtAuthScreen = state.fullPath == '/auth';

        if (!authManager.isAuth && !isAtAuthScreen) {
          return '/auth';
        }
         
        if (authManager.isAuth && isAtAuthScreen) {
          return '/products';
        }
        return null;

      },
      routes: [
        GoRoute(
          path: '/auth',
          builder: (context, state) => 
              const SafeArea(child: AuthScreen()),
        ),

        GoRoute(
          path: '/auto-login',
          builder: (context, state) {
            return FutureBuilder(
              future: context.read<AuthManager>().tryAutoLogin(),
              builder: (context, authSnapshot) =>
                const SafeArea(child: SplashScreen()),
            );
          },
        ),

        GoRoute(
          path: '/logout',
          builder: (context, state) => FutureBuilder(
            future: context.read<AuthManager>().logout(),
            builder: (context, authSnapshot) =>
              const SafeArea(child: SplashScreen()),
          ),
        ),

        GoRoute(
          path: '/products',
          builder: (context, state) =>
              const SafeArea(child: ProductsOverviewScreen()),
        ),
        GoRoute(
          path: '/products/:productId',
          builder: (context, state) {
            final productId = state.pathParameters['productId']!;
            final product = context.read<ProductsManager>().findById(
              productId,
            )!;
            return SafeArea(child: ProductDetailScreen(product));
          },
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const SafeArea(child: CartScreen()),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const SafeArea(child: OrdersScreen()),
        ),
        GoRoute(
          path: '/my-products',
          builder: (context, state) =>
              const SafeArea(child: UserProductsScreen()),
        ),
        GoRoute(
          path: '/my-products/new',
          builder: (context, state) => SafeArea(child: EditProductScreen(null)),
        ),
        GoRoute(
          path: '/my-products/:productId/edit',
          builder: (context, state) {
            final productId = state.pathParameters['productId'];
            final product = productId != null
                ? context.read<ProductsManager>().findById(productId)
                : null;
            return SafeArea(child: EditProductScreen(product));
          },
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authManager),
        ChangeNotifierProvider(create: (context) => ProductsManager()),
        ChangeNotifierProvider(create: (context) => OrdersManager()),
        ChangeNotifierProvider(create: (context) => CartManager()),
      ],
      child: MaterialApp.router(
        title: 'My Shop',
        debugShowCheckedModeBanner: false,
        theme: themeData,
        routerConfig: router,
      ),
    );
  }
}
