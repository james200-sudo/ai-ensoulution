import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/user_type_selection_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/chat/screens/history_screen.dart';
import '../../features/contact/screens/contact_form_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/plans/screens/plans_screen.dart';
import '../../features/payment/screens/payment_success_screen.dart';
import '../../features/payment/screens/payment_cancel_screen.dart';

class AppRouter {
  // ✅ AJOUTER CE GlobalKey STATIQUE
  static final GlobalKey<NavigatorState> rootNavigatorKey = 
      GlobalKey<NavigatorState>(debugLabel: 'root');
  
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey, // ✅ AJOUTER CETTE LIGNE
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) {
          //print('Navigation vers: splash');
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/user-type',
        name: 'user-type',
        builder: (context, state) {
          //print('Navigation vers: user-type');
          return const UserTypeSelectionScreen();
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          //print('Navigation vers: login');
          final extra = state.extra as Map<String, dynamic>?;
          return LoginScreen(
            userType: extra?['userType'],
            companyCode: extra?['companyCode'],
          );
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) {
          //print('Navigation vers: register');
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) {
          //print('Navigation vers: forgot-password');
          return const ForgotPasswordScreen();
        },
      ),
      GoRoute(
        path: '/verify-email',
        name: 'verify-email',
        builder: (context, state) {
          //print('Navigation vers: verify-email');
          final extra = state.extra as Map<String, dynamic>?;
          return VerifyEmailScreen(
            email: extra?['email'] as String?,
            fromRegister: extra?['fromRegister'] as bool? ?? false,
          );
        },
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/contact',
        name: 'contact',
        builder: (context, state) => const ContactFormScreen(),
      ),
      GoRoute(
        path: '/plans',
        name: 'plans',
        builder: (context, state) => const PlansScreen(),
      ),
      
      // Routes de paiement
      GoRoute(
        path: '/payment/success',
        name: 'payment-success',
        builder: (context, state) {
          //print('Navigation vers: payment-success');
          final sessionId = state.uri.queryParameters['session_id'];
          //print('Session ID: $sessionId');
          
          return PaymentSuccessScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/payment/cancel',
        name: 'payment-cancel',
        builder: (context, state) {
          //print('Navigation vers: payment-cancel');
          return const PaymentCancelScreen();
        },
      ),
      
      // Route alternative pour /success (sans /payment)
      GoRoute(
        path: '/success',
        name: 'success',
        builder: (context, state) {
          //print('Navigation vers: success (redirect)');
          final sessionId = state.uri.queryParameters['session_id'];
          return PaymentSuccessScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/cancel',
        name: 'cancel',
        builder: (context, state) {
          //print('Navigation vers: cancel (redirect)');
          return const PaymentCancelScreen();
        },
      ),
    ],
    errorBuilder: (context, state) {
      //print('ERREUR ROUTER: ${state.error}');
      //print('PATH DEMANDÉ: ${state.matchedLocation}');
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erreur de navigation'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Path: ${state.matchedLocation}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Error: ${state.error}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      );
    },
  );
}