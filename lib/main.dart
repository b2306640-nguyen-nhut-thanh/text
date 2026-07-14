import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'ui/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
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
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => buildTransitionPage(
            state: state,
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/tours',
          pageBuilder: (context, state) {
            final searchQuery = state.uri.queryParameters['query'] ?? '';
            return buildTransitionPage(
              state: state,
              child: ToursOverviewScreen(initialQuery: searchQuery),
            );
          },
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
          path: '/promotions',
          pageBuilder: (context, state) => buildTransitionPage(
            state: state,
            child: const PromotionsScreen(),
          ),
        ),
        GoRoute(
          path: '/bookings',
          pageBuilder: (context, state) => buildTransitionPage(
            state: state,
            child: const BookingsScreen(),
          ),
        ),
        GoRoute(
          path: '/manage-tours',
          pageBuilder: (context, state) => buildTransitionPage(
            state: state,
            child: const ManageToursScreen(),
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
          path: '/profile',
          pageBuilder: (context, state) => buildTransitionPage(
            state: state,
            child: const ProfileScreen(),
          ),
        ),
        GoRoute(
          path: '/profile/edit',
          pageBuilder: (context, state) => buildTransitionPage(
            state: state,
            child: const EditProfileScreen(),
          ),
        ),
      ],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookingsManager()),
        ChangeNotifierProvider(create: (_) => ToursManager()),
        ChangeNotifierProvider.value(value: authManager),
      ],
      child: MaterialApp.router(
        title: 'TravelMate',
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
