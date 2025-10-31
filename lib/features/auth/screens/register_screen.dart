import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package.flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/services/pocketbase_auth_service.dart';
import '../../profile/providers/profile_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = PocketBaseAuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ResponsiveWidget(
      mobile: _buildMobileLayout(l10n),
      tablet: _buildSplitLayout(l10n),
      desktop: _buildSplitLayout(l10n),
    );
  }

  Widget _buildMobileLayout(AppLocalizations l10n) {
    return Scaffold(
      body: ResponsiveLayout(
        child: SafeArea(
          child: Padding(
            padding: ResponsiveUtils.getHorizontalPadding(context),
            child: Column(
              children: [
                // Header avec bouton retour
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.arrow_back),
                      color: AppTheme.textGrey,
                    ),
                    Text(
                      l10n.createAccount,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, 18),
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 32.h),
                          _buildLogo(),
                          SizedBox(height: 32.h),

                          Text(
                            l10n.joinOurCommunity,
                            style: TextStyle(
                              fontSize:
                                  ResponsiveUtils.getFontSize(context, 16),
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textGrey,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 24.h),
                          _buildNameField(l10n),
                          SizedBox(height: 16.h),
                          _buildEmailField(l10n),
                          SizedBox(height: 16.h),
                          _buildPasswordField(l10n),
                          SizedBox(height: 16.h),
                          _buildConfirmPasswordField(l10n),
                          SizedBox(height: 16.h),
                          _buildTermsCheckbox(l10n),
                          SizedBox(height: 24.h),
                          _buildRegisterButton(l10n),

                          // ✅ NOUVEAU : Diviseur "OU"
                          SizedBox(height: 24.h),
                          _buildOrDivider(l10n),
                          SizedBox(height: 20.h),

                          // ✅ NOUVEAU : Bouton Google OAuth
                          _buildGoogleButton(l10n),

                          SizedBox(height: 24.h),
                          _buildLoginLink(l10n),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSplitLayout(AppLocalizations l10n) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(child: _buildImageSection()),
          Expanded(child: _buildRegisterFormSection(l10n)),
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

  Widget _buildRegisterFormSection(AppLocalizations l10n) {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                // Header avec bouton retour
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.arrow_back),
                      color: AppTheme.textGrey,
                    ),
                    Text(
                      l10n.createAccount,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildLogo(),
                      const SizedBox(height: 32),
                      Text(
                        l10n.joinOurCommunity,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _buildNameField(l10n),
                      const SizedBox(height: 16),
                      _buildEmailField(l10n),
                      const SizedBox(height: 16),
                      _buildPasswordField(l10n),
                      const SizedBox(height: 16),
                      _buildConfirmPasswordField(l10n),
                      const SizedBox(height: 16),
                      _buildTermsCheckbox(l10n),
                      const SizedBox(height: 24),
                      _buildRegisterButton(l10n),
                      const SizedBox(height: 24),
                      _buildOrDivider(l10n),
                      const SizedBox(height: 20),
                      _buildGoogleButton(l10n),
                      const SizedBox(height: 24),
                      _buildLoginLink(l10n),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: ResponsiveUtils.isDesktop(context) ? 80 : 60.w,
      height: ResponsiveUtils.isDesktop(context) ? 80 : 60.h,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildNameField(AppLocalizations l10n) {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
        hintText: l10n.fullName,
        prefixIcon: const Icon(Icons.person_outline),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.pleaseEnterYourName;
        }
        if (value.length < 2) {
          return l10n.nameMinLength;
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(AppLocalizations l10n) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: l10n.emailAddress,
        prefixIcon: const Icon(Icons.email_outlined),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.pleaseEnterEmailAddress;
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return l10n.pleaseEnterValidEmail;
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: l10n.password,
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
          return l10n.pleaseEnterYourPassword;
        }
        if (value.length < 8) {
          return l10n.passwordMinLength8;
        }
        if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
          return l10n.passwordComplexity;
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField(AppLocalizations l10n) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        hintText: l10n.confirmPassword,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.pleaseConfirmPassword;
        }
        if (value != _passwordController.text) {
          return l10n.passwordsDoNotMatch;
        }
        return null;
      },
    );
  }

  Widget _buildTermsCheckbox(AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
          activeColor: AppTheme.primaryGreen,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: Text(
              l10n.acceptTerms,
              style: TextStyle(
                fontSize: ResponsiveUtils.isDesktop(context) 
                    ? 14 
                    : ResponsiveUtils.getFontSize(context, 13),
                color: AppTheme.textGrey,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(AppLocalizations l10n) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 48.0,
      ),
      child: SizedBox(
        width: double.infinity,
        height: ResponsiveUtils.isDesktop(context) ? 48 : 45.h,
        child: ElevatedButton(
          onPressed: (_isLoading || !_acceptTerms) ? null : _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppTheme.textGrey.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.isDesktop(context) ? 8 : 8.r,
              ),
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
                  l10n.createMyAccount,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.isDesktop(context) 
                        ? 16 
                        : ResponsiveUtils.getFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  // ✅ NOUVEAU : Diviseur "OU"
  Widget _buildOrDivider(AppLocalizations l10n) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.isDesktop(context) ? 15 : 15.w,
          ),
          child: Text(
            l10n.or.toUpperCase(),
            style: TextStyle(
              color: AppTheme.textGrey,
              fontSize: ResponsiveUtils.isDesktop(context) 
                  ? 14 
                  : ResponsiveUtils.getFontSize(context, 14),
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  // ✅ NOUVEAU : Bouton Google OAuth
  Widget _buildGoogleButton(AppLocalizations l10n) {
    final isMobile = ResponsiveUtils.isMobile(context);
    return SizedBox(
      width: isMobile ? double.infinity : 300,
      height: isMobile ? 44.h : 48,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleGoogleRegister,
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
              l10n.continueWithGoogle,
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

  Widget _buildLoginLink(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.alreadyHaveAnAccount,
          style: TextStyle(
            fontSize: ResponsiveUtils.isDesktop(context) 
                ? 14 
                : ResponsiveUtils.getFontSize(context, 14),
            color: AppTheme.textGrey,
          ),
        ),
        GestureDetector(
          onTap: () => context.go('/login'),
          child: Text(
            l10n.signIn,
            style: TextStyle(
              fontSize: ResponsiveUtils.isDesktop(context) 
                  ? 14 
                  : ResponsiveUtils.getFontSize(context, 14),
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ========================================
  // GESTION DES ACTIONS
  // ========================================

  Future<void> _handleRegister() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.mustAcceptTerms),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirm: _confirmPasswordController.text,
        name: _nameController.text.trim(),
      );

      if (mounted) {
        if (result['success'] == true) {
          // Inscription réussie et email envoyé
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? l10n.registrationSuccess),
              backgroundColor: AppTheme.primaryGreen,
              duration: const Duration(seconds: 4),
            ),
          );

          // Rediriger vers l'écran de vérification d'email
          context.go('/verify-email', extra: {
            'email': _emailController.text.trim(),
            'fromRegister': true,
          });
          
        } else if (result['success'] == false && result['emailSent'] == false) {
          // Compte créé mais problème d'envoi d'email
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? l10n.accountCreatedEmailError),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );

          // Rediriger quand même vers la vérification car le compte existe
          if (result['userId'] != null) {
            context.go('/verify-email', extra: {
              'email': _emailController.text.trim(),
              'fromRegister': true,
            });
          }
          
        } else {
          // Échec de l'inscription
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? l10n.registrationError),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorWithMessage(e.toString())),
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

  // ✅ NOUVEAU : Gestion de l'inscription Google
  Future<void> _handleGoogleRegister() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
    });

    try {
     //print('🔵 Inscription Google démarrée...');
      
      final result = await _authService.loginWithGoogle();
      
      if (mounted) {
        if (result['success'] == true) {
         //print('✅ Google Auth réussie: ${result['message']}');
          
          // Rafraîchir le profil utilisateur
          final profileProvider = context.read<ProfileProvider>();
          await profileProvider.refreshUserProfile();
          
          // Message différencié selon nouvel utilisateur ou existant
          final isNewUser = result['isNewUser'] == true;
          final message = isNewUser 
              ? l10n.accountCreatedSuccess
              : l10n.loginSuccess;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppTheme.primaryGreen,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Rediriger vers le chat
          context.go('/chat');
          
        } else {
          // Erreur d'authentification Google
         //print('❌ Erreur Google Auth: ${result['error']}');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? l10n.googleAuthError),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
     //print('❌ Exception Google Register: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.unexpectedError(e.toString())),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}