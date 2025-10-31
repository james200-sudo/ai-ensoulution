import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGuard {
  /// Checks if user is authenticated by verifying JWT in SharedPreferences
  static Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt');
      return jwt != null && jwt.isNotEmpty;
    } catch (e) {
      //debugPrint('Failed to check authentication: $e');
      return false;
    }
  }

  /// Checks authentication and redirects to appropriate login screen if not authenticated
  static Future<bool> checkAuthAndRedirect(BuildContext context) async {
    final isAuth = await isAuthenticated();
    
    if (!isAuth) {
      if (!context.mounted) return false;
      
      // User is not authenticated, check if they have selected user type
      try {
        final prefs = await SharedPreferences.getInstance();
        final userTypeSelected = prefs.getBool('user_type_selected') ?? false;
        
        if (!context.mounted) return false;
        
        if (userTypeSelected) {
          // User has selected type, go to login with saved type
          final userType = prefs.getString('user_type');
          final companyCode = prefs.getString('company_code');
          
          context.go('/login', extra: {
            'userType': userType,
            'companyCode': companyCode,
          });
        } else {
          // User hasn't selected type, go to user type selection
          context.go('/user-type');
        }
      } catch (e) {
        // Fallback to user type selection if there's an error
        if (context.mounted) {
          context.go('/user-type');
        }
      }
    }
    
    return isAuth;
  }

  /// Widget wrapper that shows loading while checking authentication
  static Widget guardedScreen({
    required Widget child,
    Widget? loadingWidget,
  }) {
    return FutureBuilder<bool>(
      future: isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? 
            const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
        }
        
        if (snapshot.hasError || !snapshot.data!) {
          // Authentication failed, redirect will be handled by individual screens
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              checkAuthAndRedirect(context);
            }
          });
          
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return child;
      },
    );
  }
}