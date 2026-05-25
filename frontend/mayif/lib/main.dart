import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/service_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/pro/dashboard_pro_screen.dart';
import 'screens/pro/mes_services/mes_services_screen.dart';
import 'screens/pro/reservations_recues/reservations_recues_screen.dart';
import 'screens/touriste/reservations/mes_reservations_screen.dart';
import 'screens/touriste/profil/profil_screen.dart';
import 'screens/splash_screen.dart';

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
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
      ],
      child: const MayiTogoApp(),
    ),
  );
}

class MayiTogoApp extends StatelessWidget {
  const MayiTogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Mayi Togo Tourism',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.premiumTheme,
      routes: {
        '/login':                (context) => const LoginScreen(),
        '/forgot-password':      (context) => const ForgotPasswordScreen(),
        '/profile':              (context) => const ProfilScreen(),
        '/home':                 (context) => const HomeScreen(),
        '/dashboard-pro':        (context) => const DashboardProScreen(),
        '/admin':                (context) => const HomeScreen(), // temporaire
        // Touriste
        '/reservations':         (context) => const MesReservationsScreen(),
        // Pro — Semaine 3
        '/pro/mes-services':     (context) => const MesServicesScreen(),
        '/pro/reservations':     (context) => const ReservationsRecuesScreen(),
      },
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!auth.isReady) return const SplashScreen();
          if (!auth.isAuthenticated) return const LoginScreen();
          // Redirection selon le rôle
          switch (auth.role) {
            case 'PROFESSIONNEL':
              return const DashboardProScreen();
            default:
              return const HomeScreen();
          }
        },
      ),
    );
  }
}
