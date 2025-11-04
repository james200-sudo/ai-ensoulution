import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:tgm_ai_chat/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/services/pocketbase_auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String? email;
  final bool fromRegister;

  const VerifyEmailScreen({
    super.key,
    this.email,
    this.fromRegister = false,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _authService = PocketBaseAuthService();
  bool _isResending = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
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
                    l10n.verifyEmail,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icône
                        Container(
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.mark_email_unread,
                            size: 64.sp,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        
                        SizedBox(height: 32.h),
                        
                        Text(
                          l10n.verificationEmailSent,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getFontSize(context, 24),
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        if (widget.email != null) ...[
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
                            widget.email!,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getFontSize(context, 16),
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24.h),
                        ],
                        
                        // Instructions
                        Container(
                          padding: EdgeInsets.all(20.w),
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue.shade700,
                                    size: 24.sp,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      l10n.instructions,
                                      style: TextStyle(
                                        fontSize: ResponsiveUtils.getFontSize(context, 18),
                                        fontWeight: FontWeight.w700,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              _buildInstructionStep(
                                '1',
                                l10n.openMailbox,
                                Icons.email_outlined,
                              ),
                              SizedBox(height: 12.h),
                              _buildInstructionStep(
                                '2',
                                l10n.findVerificationEmail,
                                Icons.search,
                              ),
                              SizedBox(height: 12.h),
                              _buildInstructionStep(
                                '3',
                                l10n.clickVerifyButton,
                                Icons.touch_app,
                              ),
                              SizedBox(height: 12.h),
                              _buildInstructionStep(
                                '4',
                                l10n.accountActivated,
                                Icons.check_circle_outline,
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        // Note importante
                        Container(
                          padding: EdgeInsets.all(16.w),
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.orange.shade700,
                                size: 24.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  l10n.checkSpam,
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getFontSize(context, 14),
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 32.h),
                        
                        // Bouton renvoyer
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isResending ? null : _handleResend,
                            icon: _isResending
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh),
                            label: Text(
                              _isResending ? l10n.sendingInProgress : l10n.resendEmail,
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getFontSize(context, 16),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryGreen,
                              side: const BorderSide(
                                color: AppTheme.primaryGreen,
                                width: 2,
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        // Retour login
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: Text(
                            l10n.returnToLogin,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getFontSize(context, 16),
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: ResponsiveUtils.getFontSize(context, 16),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Row(
            children: [
              Icon(icon, size: 20.sp, color: Colors.blue.shade700),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 15),
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleResend() async {
    if (widget.email == null) return;

    setState(() => _isResending = true);

    try {
      final result = await _authService.requestEmailVerification(widget.email!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Email renvoyé'),
            backgroundColor: result['success'] == true
                ? AppTheme.primaryGreen
                : Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }
}