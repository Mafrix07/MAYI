import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/service_provider.dart';
import 'providers/avis_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/event_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/recherche/search_screen.dart';
import 'screens/favoris/favoris_screen.dart';
import 'screens/touriste/events/event_list_screen.dart';
import 'screens/touriste/recherche/explore_map_screen.dart';
import 'screens/pro/dashboard_pro_screen.dart';
import 'screens/pro/mes_services/mes_services_screen.dart';
import 'screens/pro/reservations_recues/reservations_recues_screen.dart';
import 'screens/pro/avis/mes_avis_screen.dart';
import 'screens/pro/profil/profil_pro_screen.dart';
import 'screens/touriste/reservations/mes_reservations_screen.dart';
import 'screens/touriste/profil/profil_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/welcome_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..tryAutoLogin()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..init()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => AvisProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: const MayiTogoApp(),
    ),
  );
}

class MayiTogoApp extends StatelessWidget {
  const MayiTogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Mayi Togo Tourism',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.premiumTheme,
      themeMode: themeProvider.mode,
      routes: {
        '/login':                (context) => const LoginScreen(),
        '/forgot-password':      (context) => const ForgotPasswordScreen(),
        '/profile':              (context) => const ProfilScreen(),
        '/home':                 (context) => const HomeScreen(),
        '/search':               (context) => const SearchScreen(),
        '/explore-map':          (context) => const ExploreMapScreen(),
        '/favoris':              (context) => const FavorisScreen(),
        '/events':               (context) => const EventListScreen(),
        '/dashboard-pro':        (context) => const DashboardProScreen(),
        '/admin':                (context) => const HomeScreen(), // temporaire
        // Touriste
        '/reservations':         (context) => const MesReservationsScreen(),
        // Pro — Semaine 3
        '/pro/mes-services':     (context) => const MesServicesScreen(),
        '/pro/reservations':     (context) => const ReservationsRecuesScreen(),
        '/pro/avis':             (context) => const MesAvisProScreen(),
        '/pro/profil':           (context) => const ProfilProScreen(),
      },
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // Chargement initial (splash logo)
          if (!auth.isReady) return const SplashScreen();
          // Connecté → home selon le rôle
          if (auth.isAuthenticated) {
            switch (auth.role) {
              case 'PROFESSIONNEL':
                return const DashboardProScreen();
              default:
                return const HomeScreen();
            }
          }
          // Non connecté → onboarding si jamais vu, sinon écran de bienvenue
          if (!auth.onboardingComplete) return const OnboardingScreen();
          return const WelcomeScreen();
        },
      ),
    );
  }
}
