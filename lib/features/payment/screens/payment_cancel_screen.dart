// lib/features/payment/screens/payment_cancel_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tgm_ai_chat/core/theme/app_theme.dart';
import 'package:tgm_ai_chat/core/utils/responsive.dart';

class PaymentCancelScreen extends StatelessWidget {
  const PaymentCancelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cancel icon
              Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cancel_outlined,
                  size: 80.sp,
                  color: Colors.orange.shade600,
                ),
              ),
              SizedBox(height: 32.h),
              
              // Title
              Text(
                l10n.paymentCancelledTitle,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 28),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              
              // Message
              Container(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  l10n.paymentCancelledMessage,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 16),
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 40.h),
              
              // Info card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      Icons.info_outline,
                      l10n.noPaymentProcessed,
                    ),
                    SizedBox(height: 12.h),
                    _buildInfoRow(
                      context,
                      Icons.lock_outline,
                      l10n.accountUnchanged,
                    ),
                    SizedBox(height: 12.h),
                    _buildInfoRow(
                      context,
                      Icons.restart_alt,
                      l10n.youCanRetry,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
              
              // Action buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () => context.go('/plans'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restart_alt, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            l10n.retryPayment,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getFontSize(context, 16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: OutlinedButton(
                      onPressed: () => context.go('/chat'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        l10n.returnToApp,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getFontSize(context, 16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: () => context.go('/contact'),
                    child: Text(
                      l10n.needHelpContactSupport,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, 14),
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: AppTheme.primaryGreen,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 14),
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}