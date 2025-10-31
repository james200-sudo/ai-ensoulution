// lib/features/payment/screens/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tgm_ai_chat/features/plans/models/plan_model.dart';
import 'package:tgm_ai_chat/features/plans/providers/plans_provider.dart';
import 'package:tgm_ai_chat/features/profile/providers/profile_provider.dart';
import 'package:tgm_ai_chat/core/services/pocketbase_auth_service.dart';
import 'package:tgm_ai_chat/core/theme/app_theme.dart';
import 'package:tgm_ai_chat/core/utils/responsive.dart';
import 'package:tgm_ai_chat/core/services/stripe_checkout_service.dart';

class PaymentScreen extends StatefulWidget {
  final Plan plan;

  const PaymentScreen({super.key, required this.plan});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessingPayment = false;
  String _paymentError = '';
  
  final StripeCheckoutService _checkoutService = StripeCheckoutService();
  final PocketBaseAuthService _authService = PocketBaseAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text(
          'Finaliser l\'achat',
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildPlanSummaryCard(),
            SizedBox(height: 20.h),
            
            _buildPaymentInfo(),
            SizedBox(height: 20.h),
            
            if (_paymentError.isNotEmpty) ...[
              _buildErrorMessage(),
              SizedBox(height: 16.h),
            ],
            
            _buildPaymentButton(),
            SizedBox(height: 16.h),
            
            _buildSecurityInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSummaryCard() {
    final plansProvider = context.watch<PlansProvider>();
    final currentPrice = plansProvider.getPlanPrice(widget.plan);
    final billingPeriod = plansProvider.getBillingPeriodText();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryGreen.withOpacity(0.8),
              AppTheme.primaryGreen,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Forfait sélectionné',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.getFontSize(context, 12),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.star, color: Colors.white, size: 18.sp),
              ],
            ),
            SizedBox(height: 8.h),
            
            Text(
              widget.plan.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveUtils.getFontSize(context, 24),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currentPrice,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.getFontSize(context, 28),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!widget.plan.isFree && !widget.plan.isEnterprise) ...[
                  Text(
                    billingPeriod,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: ResponsiveUtils.getFontSize(context, 16),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: AppTheme.primaryGreen, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Paiement sécurisé avec Stripe',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, 16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            
            Text(
              'Vous serez redirigé vers la page de paiement sécurisée de Stripe pour finaliser votre achat.',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 14),
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),
            
            _buildInfoRow(Icons.check_circle, 'Chiffrement SSL 256 bits'),
            SizedBox(height: 8.h),
            _buildInfoRow(Icons.credit_card, 'Toutes les cartes bancaires acceptées'),
            SizedBox(height: 8.h),
            _buildInfoRow(Icons.shield, 'Conforme au PCI DSS'),
            SizedBox(height: 8.h),
            _buildInfoRow(Icons.lock, 'Vos données ne sont jamais stockées'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppTheme.primaryGreen),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 12),
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              _paymentError,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: ResponsiveUtils.getFontSize(context, 12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    final plansProvider = context.watch<PlansProvider>();
    final currentPrice = plansProvider.getPlanPrice(widget.plan);
    
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _isProcessingPayment ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: AppTheme.primaryGreen.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: _isProcessingPayment
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Traitement...',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, 14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Continuer vers le paiement - $currentPrice',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, 14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.blue.shade700, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Paiement sécurisé et chiffré',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: ResponsiveUtils.getFontSize(context, 12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            'Les informations de paiement sont protégées par un chiffrement de niveau bancaire. Nous ne stockons jamais les détails de votre carte.',
            style: TextStyle(
              color: Colors.blue.shade600,
              fontSize: ResponsiveUtils.getFontSize(context, 10),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              'Propulsé par Stripe',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 8.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessingPayment = true;
      _paymentError = '';
    });

    try {
      final plansProvider = context.read<PlansProvider>();
      final profileProvider = context.read<ProfileProvider>();
      
      // Récupérer le token PocketBase
      final pocketbaseToken = _authService.currentToken;
      
      //debugPrint('=== PAYMENT PROCESS START ===');
      //debugPrint('Plan: ${widget.plan.name}');
      //debugPrint('User authenticated: ${_authService.isLoggedIn}');
      //debugPrint('Token present: ${pocketbaseToken != null}');
      
      if (pocketbaseToken == null || pocketbaseToken.isEmpty) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      }
      
      if (!_authService.isLoggedIn) {
        throw Exception('Vous devez être connecté pour effectuer un paiement.');
      }
      
      // Calculer le montant
      final amount = plansProvider.isYearlyBilling 
          ? widget.plan.yearlyPrice 
          : widget.plan.monthlyPrice;

      if (amount <= 0) {
        throw Exception('Montant invalide');
      }

      //debugPrint('Amount: \$${amount.toStringAsFixed(2)}');
      //debugPrint('Period: ${plansProvider.isYearlyBilling ? "Yearly" : "Monthly"}');
      //debugPrint('Token: ${pocketbaseToken.substring(0, 20)}...');

      // Rediriger vers Stripe Checkout
      final result = await _checkoutService.redirectToCheckout(
        amount: amount,
        currency: 'usd', // Changez en 'eur' si nécessaire
        planId: widget.plan.id,
        planName: widget.plan.name,
        isYearly: plansProvider.isYearlyBilling,
        pocketbaseToken: pocketbaseToken,
        metadata: {
          'plan_name': widget.plan.name,
          'billing_period': plansProvider.isYearlyBilling ? 'yearly' : 'monthly',
          'user_email': profileProvider.userProfile?.email ?? '',
          'user_id': profileProvider.userProfile?.id ?? '',
        },
      );

      if (result.isSuccess) {
        if (mounted) {
          //debugPrint('Redirected to Stripe Checkout successfully');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.open_in_browser, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Redirection vers la page de paiement sécurisée...',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // Note: L'utilisateur sera redirigé vers Stripe
          // Il reviendra via hydroaichat://payment/success ou cancel
          //debugPrint('=== PAYMENT PROCESS - REDIRECTED ===');
        }
      } else if (result.isCancelled) {
        //debugPrint('Payment cancelled by user');
        setState(() {
          _paymentError = 'Paiement annulé';
        });
      } else {
        //debugPrint('Payment failed: ${result.errorMessage}');
        setState(() {
          _paymentError = result.errorMessage ?? 'Échec de l\'initialisation du paiement';
        });
      }

    } catch (e) {
      //debugPrint('=== PAYMENT ERROR ===');
      //debugPrint('Error: $e');
      //debugPrint('Stack trace: ${StackTrace.current}');
      
      String errorMessage = e.toString();
      
      // Nettoyer le message d'erreur
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      
      // Messages d'erreur plus conviviaux
      if (errorMessage.contains('Session expirée') || errorMessage.contains('401')) {
        errorMessage = 'Session expirée. Veuillez vous reconnecter.';
      } else if (errorMessage.contains('network') || errorMessage.contains('connection')) {
        errorMessage = 'Problème de connexion. Vérifiez votre internet.';
      } else if (errorMessage.contains('timeout')) {
        errorMessage = 'Le serveur ne répond pas. Réessayez plus tard.';
      }
      
      setState(() {
        _paymentError = errorMessage;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }
}