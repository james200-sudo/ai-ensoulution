import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/pocketbase_auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? email;
  final String? token;

  const ResetPasswordScreen({
    super.key,
    this.email,
    this.token,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _authService = PocketBaseAuthService();

  bool _isLoading = false;
  bool _isSuccess = false;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  String? _token;

  @override
  void initState() {
    super.initState();
    _token = widget.token;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        child: SafeArea(
          child: Padding(
            padding: ResponsiveUtils.getHorizontalPadding(context),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.arrow_back),
                      color: AppTheme.textGrey,
                    ),
                    Text(
                      AppLocalizations.of(context)!.resetPassword,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, 18),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: _isSuccess
                          ? _buildSuccessContent()
                          : _buildResetForm(),
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

  Widget _buildResetForm() {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône
          Icon(
            Icons.lock_open,
            size: 64.sp,
            color: AppTheme.primaryGreen,
          ),

          SizedBox(height: 32.h),

          Text(
            l10n.setNewPassword,
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 24),
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 16.h),

          // Champ Nouveau mot de passe
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: l10n.newPassword,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                return l10n.pleaseEnterPassword;
              }
              if (value.length < 8) {
                return l10n.passwordTooShort;
              }
              return null;
            },
          ),

          SizedBox(height: 16.h),

          // Champ Confirmer mot de passe
          TextFormField(
            controller: _passwordConfirmController,
            obscureText: _obscurePasswordConfirm,
            decoration: InputDecoration(
              hintText: l10n.confirmPassword,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePasswordConfirm
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePasswordConfirm = !_obscurePasswordConfirm;
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
          ),

          SizedBox(height: 32.h),

          // Bouton Réinitialiser
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text(l10n.resetPassword),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/animations/success.json',
          width: 150.w,
          height: 150.h,
          fit: BoxFit.fill,
        ),
        SizedBox(height: 32.h),
        Text(
          l10n.passwordResetSuccess,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 22),
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16.h),
        Text(
          l10n.canNowLogin,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 16),
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            child: Text(l10n.returnToLogin),
          ),
        ),
      ],
    );
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate() || _token == null) {
      if (_token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.resetTokenMissing),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.confirmPasswordReset(
        _token!,
        _passwordController.text,
        _passwordConfirmController.text,
      );

      if (mounted) {
        if (result['success'] == true) {
          setState(() {
            _isSuccess = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? AppLocalizations.of(context)!.errorOccurred),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }
}
