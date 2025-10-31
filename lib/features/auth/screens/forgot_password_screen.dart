import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/services/pocketbase_auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = PocketBaseAuthService();
  
  bool _isLoading = false;
  bool _emailSent = false;

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
                      onPressed: () => context.go('/login'), // Correction ici
                      icon: const Icon(Icons.arrow_back),
                      color: AppTheme.textGrey,
                    ),
                    Text(
                      l10n.forgotPasswordTitle,
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
                    child: Column(
                      children: [
                        SizedBox(height: 40.h),
                        _buildLogo(),
                        SizedBox(height: 32.h),
                        if (!_emailSent) ...[
                          _buildRequestForm(l10n),
                        ] else ...[
                          _buildEmailSentContent(l10n),
                        ],
                        SizedBox(height: 20.h),
                      ],
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
          Expanded(child: _buildForgotPasswordFormSection(l10n)),
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

  Widget _buildForgotPasswordFormSection(AppLocalizations l10n) {
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
                      onPressed: () => context.go('/login'), // Correction ici
                      icon: const Icon(Icons.arrow_back),
                      color: AppTheme.textGrey,
                    ),
                    Text(
                      l10n.forgotPasswordTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildLogo(),
                const SizedBox(height: 32),
                if (!_emailSent) ...[
                  _buildRequestForm(l10n),
                ] else ...[
                  _buildEmailSentContent(l10n),
                ],
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

  Widget _buildRequestForm(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icône et titre
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.isDesktop(context) ? 24 : 20.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_reset,
              size: ResponsiveUtils.isDesktop(context) ? 48 : 40.sp,
              color: AppTheme.primaryGreen,
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.isDesktop(context) ? 24 : 24.h),
          
          Text(
            l10n.resetYourPassword,
            style: TextStyle(
              fontSize: ResponsiveUtils.isDesktop(context) 
                  ? 24 
                  : ResponsiveUtils.getFontSize(context, 20),
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: ResponsiveUtils.isDesktop(context) ? 12 : 12.h),
          
          Text(
            l10n.resetPasswordInstructions,
            style: TextStyle(
              fontSize: ResponsiveUtils.isDesktop(context) 
                  ? 16 
                  : ResponsiveUtils.getFontSize(context, 14),
              color: AppTheme.textGrey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: ResponsiveUtils.isDesktop(context) ? 32 : 32.h),
          
          // Champ email
          _buildEmailField(),
          
          SizedBox(height: ResponsiveUtils.isDesktop(context) ? 24 : 24.h),
          
          // Bouton envoyer
          _buildSendButton(),
          
          SizedBox(height: ResponsiveUtils.isDesktop(context) ? 24 : 24.h),
          
          // Lien retour connexion
          _buildBackToLoginLink(),
        ],
      ),
    );
  }

  Widget _buildEmailSentContent(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icône succès
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read,
            size: 64.sp,
            color: Colors.green,
          ),
        ),
        
        SizedBox(height: 24.h),
        
        Text(
          l10n.emailSent,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 24),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 16.h),
        
        Text(
          l10n.weSentAnEmailTo,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 16),
            color: AppTheme.textGrey,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          _emailController.text.trim(),
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 16),
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 32.h),
        
        // Instructions claires
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 32.sp),
              SizedBox(height: 16.h),
              Text(
                l10n.howToResetPassword,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 18),
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                l10n.howToResetPasswordInstructions,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 15),
                  color: Colors.black87,
                  height: 1.6,
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
        
        SizedBox(height: 24.h),
        
        Text(
          l10n.checkSpam,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 14),
            color: Colors.orange.shade700,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 32.h),
        
        // Bouton renvoyer
        _buildResendEmailButton(),
        
        SizedBox(height: 16.h),
        
        // Retour login
        _buildBackToLoginLink(),
      ],
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

  Widget _buildSendButton(AppLocalizations l10n) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 48.0, // Hauteur minimale de 48 pixels
      ),
      child: SizedBox(
        width: double.infinity,
        height: ResponsiveUtils.isDesktop(context) ? 48 : 45.h,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleSendResetEmail,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
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
                  l10n.sendResetLink,
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

  Widget _buildResetPasswordButton(AppLocalizations l10n) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 48.0, // Hauteur minimale de 48 pixels
      ),
      child: SizedBox(
        width: double.infinity,
        height: ResponsiveUtils.isDesktop(context) ? 48 : 45.h,
        child: ElevatedButton.icon(
          onPressed: () {
            context.go('/reset-password', extra: {
              'email': _emailController.text.trim(),
            });
          },
          icon: const Icon(Icons.vpn_key),
          label: Text(
            l10n.resetPassword,
            style: TextStyle(
              fontSize: ResponsiveUtils.isDesktop(context)
                  ? 16
                  : ResponsiveUtils.getFontSize(context, 14),
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.isDesktop(context) ? 8 : 8.r,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendEmailButton(AppLocalizations l10n) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 48.0, // Hauteur minimale de 48 pixels
      ),
      child: SizedBox(
        width: double.infinity,
        // La hauteur par défaut était 44/40, mais le ConstrainedBox la forcera à 48.0 min.
        height: ResponsiveUtils.isDesktop(context) ? 44 : 40.h,
        child: OutlinedButton.icon(
          onPressed: _isLoading ? null : _handleSendResetEmail,
          icon: _isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  ),
                )
              : const Icon(Icons.refresh),
          label: Text(
            _isLoading ? l10n.sendingInProgress : l10n.resendEmail,
            style: TextStyle(
              fontSize: ResponsiveUtils.isDesktop(context) 
                  ? 14 
                  : ResponsiveUtils.getFontSize(context, 13),
              fontWeight: FontWeight.w500,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryGreen,
            side: const BorderSide(color: AppTheme.primaryGreen),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.isDesktop(context) ? 8 : 8.r,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackToLoginLink(AppLocalizations l10n) {
    return Center(
      child: GestureDetector(
        onTap: () => context.go('/login'),
        child: Text(
          l10n.backToLogin,
          style: TextStyle(
            fontSize: ResponsiveUtils.isDesktop(context)
                ? 14
                : ResponsiveUtils.getFontSize(context, 14),
            color: AppTheme.primaryGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

 Future<void> _handleSendResetEmail() async {
    final l10n = AppLocalizations.of(context)!;
  if (!_emailSent && !_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
  });

  try {
    final result = await _authService.requestPasswordReset(
      _emailController.text.trim(),
    );

    if (mounted) {
      if (result['success'] == true) {
        // L'utilisateur existe et l'email a été envoyé
        setState(() {
          _emailSent = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? l10n.emailSentMessage),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      } else {
        // Vérifier si c'est parce que l'utilisateur n'existe pas
        if (result['userExists'] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? l10n.emailNotFound),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          // Erreur d'envoi d'email
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? l10n.sendingError),
              backgroundColor: Colors.red,
            ),
          );
        }
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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}