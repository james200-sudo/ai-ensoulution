import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import 'package:tgm_ai_chat/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  void _startSplashSequence() async {
    // Start animations
    _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();

    // Wait for minimum splash duration
    await Future.delayed(const Duration(milliseconds: 2500));

    // Check login status and user type selection
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt');
    final userTypeSelected = prefs.getBool('user_type_selected') ?? false;

    // Navigate based on login status and user type selection
    if (mounted) {
      if (jwt != null && jwt.isNotEmpty) {
        // User is logged in, go to chat
        context.go('/chat');
      } else if (userTypeSelected) {
        // User has selected type but not logged in, go to login with saved type
        final userType = prefs.getString('user_type');
        final companyCode = prefs.getString('company_code');

        context.push('/login', extra: {
          'userType': userType,
          'companyCode': companyCode,
        });
      } else {
        // User hasn't selected type, go to user type selection
        context.go('/user-type');
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              AppTheme.lightGreen.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: ResponsiveWidget(
          mobile: _buildMobileLayout(),
          tablet: _buildTabletLayout(),
          desktop: _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return _buildSplashContent(context);
  }

  Widget _buildTabletLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: _buildSplashContent(context),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: _buildSplashContent(context),
      ),
    );
  }

  Widget _buildSplashContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo with animations
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: ResponsiveUtils.isDesktop(context) ? 200 : 150.w,
                  height: ResponsiveUtils.isDesktop(context) ? 200 : 150.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30.r),
                    child: _buildLogo(),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 40.h),

          // App name and tagline with fade animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Text(
                  l10n.appTitle,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 32),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.appTagline,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 16),
                    color: AppTheme.textGrey,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 60.h),

          // Loading indicator
          FadeTransition(
            opacity: _fadeAnimation,
            child: const Column(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        final l10n = AppLocalizations.of(context)!;
        // Fallback to gradient container with text if logo.png is not found
        return Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Center(
            child: Text(
              l10n.logoFallback,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveUtils.getFontSize(context, 32),
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }
}
