import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ui/screens.dart';
import 'ui/shared/app_navigation_bar.dart';
import 'models/destination.dart';
import 'services/local_notification_service.dart';
import 'services/pocketbase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await LocalNotificationService.init();

  runApp(const TravelApp());
}

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authManager = AuthManager();
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF0088FF),
          secondary: const Color(0xFFFFB300),
          surface: Colors.white,
        ).copyWith(
          primary: const Color(0xFF0088FF),
        );

    CustomTransitionPage<void> buildTransitionPage({
      required GoRouterState state,
      required Widget child,
    }) {
      const duration = Duration(milliseconds: 320);
      var enterBeginX = 0.22;
      var exitEndX = -0.06;
      final extra = state.extra;

      if (extra is Map) {
        final fromTab = extra['fromTabIndex'];
        final toTab = extra['toTabIndex'];
        if (fromTab is int && toTab is int && fromTab != toTab) {
          final movingRight = toTab > fromTab;
          enterBeginX = movingRight ? -0.22 : 0.22;
          exitEndX = movingRight ? 0.06 : -0.06;
        }
      }

      return CustomTransitionPage<void>(
        key: state.pageKey,
        child: child,
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final primary = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart,
            reverseCurve: Curves.easeInQuart,
          );
          final secondary = CurvedAnimation(
            parent: secondaryAnimation,
            curve: Curves.easeOutQuart,
            reverseCurve: Curves.easeInQuart,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(enterBeginX, 0),
              end: Offset.zero,
            ).animate(primary),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: Offset(exitEndX, 0),
              ).animate(secondary),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.94, end: 1).animate(primary),
                child: child,
              ),
            ),
          );
        },
      );
    }

    final router = GoRouter(
      initialLocation: '/auto-login',
      refreshListenable: authManager,
      redirect: (context, state) {
        final auth = context.read<AuthManager>();
        final isAuthScreen = state.matchedLocation == '/auth';
        final isAutoLogin = state.matchedLocation == '/auto-login';
        final isAdminRoute = state.uri.path.startsWith('/manage-tours');

        if (!auth.isAuth && !isAuthScreen && !isAutoLogin) {
          return '/auth';
        }
        if (auth.isAuth && (isAuthScreen || isAutoLogin)) {
          return '/home';
        }
        if (auth.isAuth && isAdminRoute && !auth.isAdmin) {
          return '/tours';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/auto-login',
          pageBuilder: (context, state) => buildTransitionPage(
            state: state,
            child: const AutoLoginHandler(),
          ),
        ),
        GoRoute(
          path: '/auth',
          pageBuilder: (context, state) => buildTransitionPage(
            state: state,
            child: const AuthScreen(),
          ),
        ),
        GoRoute(
          path: '/logout',
          pageBuilder: (context, state) => buildTransitionPage(
            state: state,
            child: FutureBuilder(
              future: context.read<AuthManager>().logout(),
              builder: (context, snapshot) => const SplashScreen(),
            ),
          ),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return Scaffold(
              extendBody: true,
              body: navigationShell,
              bottomNavigationBar: AppNavigationBar(navigationShell: navigationShell),
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/tours',
                  pageBuilder: (context, state) {
                    final searchQuery = state.uri.queryParameters['query'] ?? '';
                    return NoTransitionPage(
                      child: ToursOverviewScreen(initialQuery: searchQuery),
                    );
                  },
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/promotions',
                  pageBuilder: (context, state) => const NoTransitionPage(child: PromotionsScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/bookings',
                  pageBuilder: (context, state) => const NoTransitionPage(child: BookingsScreen()),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  pageBuilder: (context, state) => const NoTransitionPage(child: ProfileScreen()),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/tours/:tourId',
          pageBuilder: (context, state) {
            final tourId = state.pathParameters['tourId']!;
            final tour = context.read<ToursManager>().findById(tourId);
            return buildTransitionPage(
              state: state,
              child: TourDetailScreen(tour: tour!),
            );
          },
        ),
        GoRoute(
          path: '/bookings/:id',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return buildTransitionPage(
              state: state,
              child: BookingDetailScreen(bookingId: id),
            );
          },
        ),
        GoRoute(
          path: '/manage-tours',
          pageBuilder: (context, state) => buildTransitionPage(
            state: state,
            child: const ManageToursScreen(),
          ),
        ),
        GoRoute(
          path: '/manage-bookings',
          pageBuilder: (context, state) => buildTransitionPage(
            state: state,
            child: const ManageBookingsScreen(),
          ),
        ),
        GoRoute(
          path: '/manage-tours/new',
          pageBuilder: (context, state) => buildTransitionPage(
            state: state,
            child: const EditTourScreen(),
          ),
        ),
        GoRoute(
          path: '/manage-tours/:tourId/edit',
          pageBuilder: (context, state) {
            final tourId = state.pathParameters['tourId']!;
            final tour = context.read<ToursManager>().findById(tourId);
            return buildTransitionPage(
              state: state,
              child: EditTourScreen(tour: tour),
            );
          },
        ),
        GoRoute(
          path: '/manage-destinations',
          pageBuilder: (context, state) => buildTransitionPage(
            state: state,
            child: const ManageDestinationsScreen(),
          ),
        ),
        GoRoute(
          path: '/manage-destinations/edit',
          pageBuilder: (context, state) {
            final dest = state.extra as Destination?;
            return buildTransitionPage(
              state: state,
              child: EditDestinationScreen(destination: dest),
            );
          },
        ),
        GoRoute(
          path: '/profile/edit',
          pageBuilder: (context, state) => buildTransitionPage(
            state: state,
            child: const EditProfileScreen(),
          ),
        ),
        GoRoute(
          path: '/manage-promotions',
          pageBuilder: (context, state) => buildTransitionPage(
            state: state,
            child: const ManagePromotionsScreen(),
          ),
        ),
        GoRoute(
          path: '/manage-promotions/new',
          pageBuilder: (context, state) => buildTransitionPage(
            state: state,
            child: const EditPromotionScreen(),
          ),
        ),
        GoRoute(
          path: '/manage-promotions/:id/edit',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            final promotion = context.read<PromotionsManager>().items.firstWhere(
                  (p) => p.id == id,
                  orElse: () => throw Exception('Promotion not found'),
                );
            return buildTransitionPage(
              state: state,
              child: EditPromotionScreen(promotion: promotion),
            );
          },
        ),
        GoRoute(
          path: '/notifications',
          pageBuilder: (context, state) => buildTransitionPage(
            state: state,
            child: const NotificationsScreen(),
          ),
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookingsManager()),
        ChangeNotifierProvider(create: (_) => ToursManager()..fetchTours()),
        ChangeNotifierProvider(create: (_) => PromotionsManager()..fetchPromotions()),
        ChangeNotifierProvider(create: (_) => DestinationsManager()..fetchDestinations()),
        ChangeNotifierProvider.value(value: authManager),
        ChangeNotifierProxyProvider<AuthManager, NotificationsManager>(
          create: (ctx) => NotificationsManager(ctx.read<AuthManager>()),
          update: (ctx, auth, previous) => previous ?? NotificationsManager(auth),
        ),
      ],
      child: MaterialApp.router(
        title: 'Travol',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          appBarTheme: AppBarTheme(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            centerTitle: false,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 1,
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        routerConfig: router,
      ),
    );
  }
}

class AutoLoginHandler extends StatefulWidget {
  const AutoLoginHandler({super.key});

  @override
  State<AutoLoginHandler> createState() => _AutoLoginHandlerState();
}

class _AutoLoginHandlerState extends State<AutoLoginHandler> {
  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    final authManager = context.read<AuthManager>();
    await authManager.tryAutoLogin();
    if (!authManager.isAuth && mounted) {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
