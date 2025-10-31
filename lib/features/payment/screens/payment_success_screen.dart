// lib/features/payment/screens/payment_success_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tgm_ai_chat/features/profile/providers/profile_provider.dart';
import 'package:tgm_ai_chat/core/theme/app_theme.dart';
import 'package:tgm_ai_chat/core/utils/responsive.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String? sessionId;

  const PaymentSuccessScreen({
    super.key,
    this.sessionId,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isVerifying = true;
  bool _verificationSuccess = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    
    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    // Vérifier et rafraîchir le profil
    _verifyAndRefresh();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _verifyAndRefresh() async {
    try {
      setState(() {
        _isVerifying = true;
        _errorMessage = '';
      });

      // Attendre un peu pour que le webhook soit traité
      await Future.delayed(const Duration(seconds: 2));

      // Rafraîchir le profil utilisateur
      if (mounted) {
        final profileProvider = context.read<ProfileProvider>();
        await profileProvider.refreshUserProfile();
        
        setState(() {
          _isVerifying = false;
          _verificationSuccess = true;
        });
        
        // Démarrer l'animation
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _verificationSuccess = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: SafeArea(
        child: _isVerifying
            ? _buildLoadingState()
            : _verificationSuccess
                ? _buildSuccessState()
                : _buildErrorState(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryGreen,
            strokeWidth: 3,
          ),
          SizedBox(height: 24.h),
          Text(
            'Vérification de votre paiement...',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 16),
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Veuillez patienter un instant',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 14),
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated success icon
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80.sp,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
            SizedBox(height: 32.h),
            
            // Success title
            Text(
              'Paiement réussi !',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 28),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            
            // Success message
            Container(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                'Votre abonnement a été activé avec succès. Vous avez désormais accès à toutes les fonctionnalités premium !',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 16),
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 40.h),
            
            // Success details card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Consumer<ProfileProvider>(
                builder: (context, profileProvider, _) {
                  // Récupérer le nom du plan depuis le provider ou utiliser une valeur par défaut
                  final planName = 'Premium'; // Vous pouvez adapter selon votre modèle
                  
                  return Column(
                    children: [
                      _buildDetailRow(
                        Icons.workspace_premium,
                        'Forfait',
                        planName,
                      ),
                      Divider(height: 24.h),
                      _buildDetailRow(
                        Icons.check_circle_outline,
                        'Statut',
                        'Actif',
                        valueColor: AppTheme.primaryGreen,
                      ),
                      if (widget.sessionId != null) ...[
                        Divider(height: 24.h),
                        _buildDetailRow(
                          Icons.receipt_long,
                          'Session',
                          widget.sessionId!.substring(0, 20) + '...',
                          isSmall: true,
                        ),
                      ],
                    ],
                  );
                },
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
                    onPressed: () => context.go('/chat'),
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
                        Icon(Icons.chat_bubble_outline, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Commencer le chat',
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
                    onPressed: () => context.go('/profile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      side: BorderSide(color: AppTheme.primaryGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Voir le profil',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80.sp,
            color: Colors.red,
          ),
          SizedBox(height: 24.h),
          
          Text(
            'Problème de vérification',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 24),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'Impossible de vérifier votre paiement. Contactez le support si le problème persiste.',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 14),
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32.h),
          
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _verifyAndRefresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Réessayer la vérification',
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
                    'Continuer dans l\'application',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool isSmall = false,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: AppTheme.primaryGreen,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 12),
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(
                    context,
                    isSmall ? 12 : 16,
                  ),
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}