import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/strapi_client.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/providers/profile_provider.dart';
import '../../../core/services/pocketbase_auth_service.dart';
import '../../../core/services/auth_session_manager.dart';

class LoginScreen extends StatefulWidget {
  final String? userType;
  final String? companyCode;

  const LoginScreen({
    super.key,
    this.userType,
    this.companyCode,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = PocketBaseAuthService();
  final _sessionManager = AuthSessionManager();  
  bool _isLoading = false;
  bool _obscurePassword = true;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canUseBiometrics = false;
  bool _biometricEnabled = false;

  bool get _isCompanyUser => widget.userType == 'company';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _checkUserTypeSelection();
    _testPocketBaseConnection();
    _loadLastCredentials();  
  }

  Future<void> _loadLastCredentials() async {
    try {
      final credentials = await _sessionManager.getLastCredentials();
      
      if (credentials['email']?.isNotEmpty ?? false) {
        setState(() {
          _emailController.text = credentials['email']!;
        });
        debugPrint('📧 Email pré-rempli: ${credentials['email']}');
      }
    } catch (e) {
      debugPrint('❌ Erreur chargement credentials: $e');
    }
  }

  Future<void> _testPocketBaseConnection() async {
    final connectionOk = await _authService.testConnection();
    if (!connectionOk) {
      //print('⚠️ Connexion PocketBase non disponible');
    }
  }

  Future<void> _checkUserTypeSelection() async {
    if (widget.userType == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userTypeSelected = prefs.getBool('user_type_selected') ?? false;

        if (!userTypeSelected && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/user-type');
          });
        }
      } catch (e) {
        //debugPrint('Failed to check user type selection: $e');
      }
    }
  }

  Future<void> _checkBiometricAvailability() async {
    if (kIsWeb) {
      setState(() {
        _canUseBiometrics = false;
        _biometricEnabled = false;
      });
      return;
    }

    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      if (mounted) {
        final settingsProvider = context.read<SettingsProvider>();
        setState(() {
          _canUseBiometrics = isAvailable &&
              isDeviceSupported &&
              availableBiometrics.isNotEmpty;
          _biometricEnabled =
              _canUseBiometrics && settingsProvider.settings.biometricAuth;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _canUseBiometrics = false;
          _biometricEnabled = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Ajout du Scaffold ici pour éviter les erreurs de contexte
      body: ResponsiveWidget(
        mobile: _buildMobileLayout(),
        tablet: _buildSplitLayout(),
        desktop: _buildSplitLayout(),
      ),
    );
  }

  // ✅ CORRECTION 1 : La page est maintenant entièrement scrollable
  Widget _buildMobileLayout() {
    return ResponsiveLayout(
      child: SafeArea(
        child: Padding(
          padding: ResponsiveUtils.getHorizontalPadding(context),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40.h),
                  _buildLogo(),
                  SizedBox(height: 40.h),
                  
                  // Formulaire pour tous les utilisateurs individuels
                  if (!_isCompanyUser) ...[
                    Text(
                      AppLocalizations.of(context)!.choosePreferredSignInMethod,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, 16),
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    _buildEmailField(),
                    SizedBox(height: 16.h),
                    _buildPasswordField(),
                    SizedBox(height: 24.h),
                    _buildSignInButton(),
                    SizedBox(height: 24.h),
                    _buildOrDivider(),
                    SizedBox(height: 20.h),
                    _buildSocialButtons(),
                    _buildAuthLinks(),
                  ],
                  
                  // Formulaire pour utilisateurs company
                  if (_isCompanyUser) ...[
                    _buildEmailField(),
                    SizedBox(height: 16.h),
                    _buildPasswordField(),
                    SizedBox(height: 24.h),
                    _buildSignInButton(),
                  ],
                  
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSplitLayout() {
    return Scaffold(
      body: Row(
        children: [
          Expanded(child: _buildImageSection()),
          Expanded(child: _buildLoginFormSection()),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryGreen, AppTheme.lightGreen],
        ),
      ),
      child: Center(
        child: Image.asset(
          'assets/images/login.png',
          fit: BoxFit.contain,
          height: MediaQuery.sizeOf(context).height * 0.6,
        ),
      ),
    );
  }

  Widget _buildLoginFormSection() {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 48),
                  
                  if (!_isCompanyUser) ...[
                    Text(
                      AppLocalizations.of(context)!.choosePreferredSignInMethod,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, 16),
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 24),
                    _buildSignInButton(),
                    const SizedBox(height: 24),
                    _buildOrDivider(),
                    const SizedBox(height: 20),
                    _buildSocialButtons(),
                    _buildAuthLinksDesktop(),
                  ],
                  
                  if (_isCompanyUser) ...[
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 24),
                    _buildSignInButton(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: ResponsiveUtils.isDesktop(context) ? 100 : 80.w,
      height: ResponsiveUtils.isDesktop(context) ? 100 : 80.h,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildEmailField() {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: l10n.enterYourUsername,
        prefixIcon: const Icon(Icons.email_outlined),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.pleaseEnterYourUsername;
        }
        if (!value.contains('@')) {
          return l10n.pleaseEnterValidEmail;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.enterYourPassword,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.pleaseEnterYourPassword;
        }
        if (value.length < 6) {
          return AppLocalizations.of(context)!.passwordMustBeAtLeast6Characters;
        }
        return null;
      },
    );
  }

  // ✅ CORRECTION 2 : Le bouton a maintenant une taille minimale garantie
  Widget _buildSignInButton() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 45.0, // Hauteur minimale fixe
      ),
      child: SizedBox(
        width: double.infinity,
        height: 45.h, // Hauteur responsive qui ne descendra pas sous 45.0
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  height: 20.h,
                  width: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  AppLocalizations.of(context)!.signIn,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    if (_isCompanyUser) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Text(
            AppLocalizations.of(context)!.or,
            style: TextStyle(
              color: AppTheme.textGrey,
              fontSize: ResponsiveUtils.getFontSize(context, 14),
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialButtons() {
    if (_isCompanyUser) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        if (_biometricEnabled) ...[
          _buildBiometricButton(),
          SizedBox(height: 8.h),
        ],
        _buildGoogleButton(),
      ],
    );
  }

  Widget _buildGoogleButton() {
    final isMobile = ResponsiveUtils.isMobile(context);
    return SizedBox(
      width: isMobile ? double.infinity : 300,
      height: isMobile ? 40.h : 44,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleGoogleLogin,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF4285F4), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 8.r : 8),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google_logo.png',
              width: isMobile ? 18.sp : 18,
              height: isMobile ? 18.sp : 18,
              fit: BoxFit.contain,
            ),
            SizedBox(width: isMobile ? 8.w : 8),
            Text(
              AppLocalizations.of(context)!.continueWithGoogle,
              style: TextStyle(
                color: const Color(0xFF4285F4),
                fontSize: isMobile ? ResponsiveUtils.getFontSize(context, 13) : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthLinks() {
    if (_isCompanyUser) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SizedBox(height: 16.h),
        TextButton(
          onPressed: () => context.go('/forgot-password'),
          child: Text(
            l10n.forgotPassword,
            style: TextStyle(
              color: AppTheme.primaryGreen,
              fontSize: ResponsiveUtils.getFontSize(context, 14),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Text(
                l10n.newToPlatform,
                style: TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: ResponsiveUtils.getFontSize(context, 13),
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: double.infinity,
          height: 44.h,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/register'),
            icon: const Icon(Icons.person_add),
            label: Text(
              l10n.createFreeAccount,
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 14),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
              side: const BorderSide(color: AppTheme.primaryGreen, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthLinksDesktop() {
    if (_isCompanyUser) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => context.go('/forgot-password'),
          child: Text(
            l10n.forgotPassword,
            style: const TextStyle(
              color: AppTheme.primaryGreen,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                l10n.newToPlatform,
                style: const TextStyle(
                  color: AppTheme.textGrey,
                  fontSize: 13,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/register'),
            icon: const Icon(Icons.person_add),
            label: Text(
              l10n.createFreeAccount,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryGreen,
              side: const BorderSide(color: AppTheme.primaryGreen, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBiometricButton() {
    final isMobile = ResponsiveUtils.isMobile(context);
    return SizedBox(
      width: isMobile ? double.infinity : 300,
      height: isMobile ? 44.h : 48,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleBiometricLogin,
        icon: _isLoading
            ? SizedBox(
                width: isMobile ? 18.sp : 18,
                height: isMobile ? 18.sp : 18,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                Icons.fingerprint,
                color: Colors.white,
                size: isMobile ? 18.sp : 18,
              ),
        label: Text(
          _isLoading
              ? AppLocalizations.of(context)!.authenticating
              : AppLocalizations.of(context)!.useBiometricLogin,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? ResponsiveUtils.getFontSize(context, 14) : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 8.r : 8),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    final isMobile = ResponsiveUtils.isMobile(context);
    return SizedBox(
      width: isMobile ? double.infinity : 300,
      height: isMobile ? 40.h : 44,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: isMobile ? 18.sp : 18),
        label: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: isMobile ? ResponsiveUtils.getFontSize(context, 13) : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 8.r : 8),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isCompanyUser) {
        await _handleCompanyLogin();
      } else {
        await _handleIndividualLogin();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.loginFailed(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleCompanyLogin() async {
    final l10n = AppLocalizations.of(context)!;
    final strapiClient = StrapiClient(apiUrl: AppConstants.strapiApiUrl);
    final response = await strapiClient.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (response.containsKey('jwt')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt', response['jwt']);
      // 🆕 Sauvegarder l'email pour pré-remplissage
      await prefs.setString('last_email', _emailController.text.trim());
      await prefs.setString('last_user_type', 'company');
      if (response.containsKey('user')) {
        final userJson = json.encode(response['user']);
        await prefs.setString('user', userJson);
      }
      if (prefs.getString('firstLoginDate') == null) {
        await prefs.setString(
            'firstLoginDate', DateTime.now().toIso8601String());
      }
      if (mounted) {
        final profileProvider = context.read<ProfileProvider>();
        await profileProvider.refreshUserProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.companyLoginSuccess),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        context.go('/chat');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.loginFailed(l10n.jwtNotFound)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleIndividualLogin() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await _authService.loginWithEmailPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (result['success'] == true && mounted) {
      // 🆕 Sauvegarder l'email pour pré-remplissage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_email', _emailController.text.trim());
      await prefs.setString('last_user_type', 'individual');
      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.refreshUserProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? l10n.loginSuccess),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      context.go('/chat');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? l10n.loginError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await _authService.loginWithGoogle();
      if (result['success'] == true && mounted) {
        // 🆕 Sauvegarder l'email pour pré-remplissage
        if (result['user'] != null && result['user']['email'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('last_email', result['user']['email']);
          await prefs.setString('last_user_type', 'individual');
        }
        final profileProvider = context.read<ProfileProvider>();
        await profileProvider.refreshUserProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? l10n.googleLoginSuccess),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        context.go('/chat');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? l10n.googleLoginError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.googleError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    if (!_biometricEnabled) return;
    final l10n = AppLocalizations.of(context)!;
    try {
      setState(() {
        _isLoading = true;
      });
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: l10n.pleaseAuthenticateToLogin,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (didAuthenticate && mounted) {
        final result = await _authService.loginWithGoogle();
        if (result['success'] == true) {
          final profileProvider = context.read<ProfileProvider>();
          await profileProvider.refreshUserProfile();
          context.go('/chat');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.biometricAuthFailed(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}