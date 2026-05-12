import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_new/providers/service_provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/pro/dashboard_pro_screen.dart';
import 'screens/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Rendre la barre de statut transparente
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
  // Ajouter ces routes
  routes: {
    '/login':          (context) => const LoginScreen(),
    '/home':           (context) => const HomeScreen(),
    '/dashboard-pro':  (context) => const DashboardProScreen(),
    '/admin':          (context) => const HomeScreen(), // temporaire
  },
  home: Consumer<AuthProvider>(
    builder: (context, auth, _) {
      if (!auth.isReady) {
        return const SplashScreen();
      }
      return auth.isAuthenticated
          ? const HomeScreen()
          : const LoginScreen();
    },
  ),
);
  }
}
