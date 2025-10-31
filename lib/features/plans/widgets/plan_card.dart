import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tgm_ai_chat/l10n/app_localizations.dart';
import 'package:tgm_ai_chat/features/plans/models/plan_model.dart';
import 'package:tgm_ai_chat/features/plans/providers/plans_provider.dart';
import 'package:tgm_ai_chat/features/payment/screens/payment_screen.dart';
import 'package:tgm_ai_chat/features/profile/providers/profile_provider.dart';
import 'package:tgm_ai_chat/core/theme/app_theme.dart';
import 'package:tgm_ai_chat/core/utils/responsive.dart';
import 'package:tgm_ai_chat/features/contact/screens/contact_form_screen.dart';

class PlanCard extends StatelessWidget {
  final Plan plan;

  const PlanCard({super.key, required this.plan});

  String _getEnglishPlanName(String localizedPlanName) {
    // Convert localized plan names to English for comparison
    if (localizedPlanName == 'Free' || localizedPlanName == 'Gratuit' || localizedPlanName == 'Gratis') {
      return 'Free';
    } else if (localizedPlanName == 'Pro') {
      return 'Pro';
    } else if (localizedPlanName == 'Premium') {
      return 'Premium';
    } else if (localizedPlanName == 'Enterprise' || localizedPlanName == 'Entreprise' || localizedPlanName == 'Empresarial') {
      return 'Enterprise';
    }
    return localizedPlanName;
  }

  // Vérifie si c'est le plan Hydropower Utilities
  bool get isHydropowerPlan {
    final planName = plan.name.toLowerCase();
    return planName.contains('hydropower') || planName.contains('utilities');
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final profileProvider = context.watch<ProfileProvider>();
    final plansProvider = context.watch<PlansProvider>();
    
    // Comparaison améliorée des plans
    final currentUserPlan = profileProvider.userProfile?.currentPlan?.toLowerCase() ?? 'free';
    final planName = plan.name.toLowerCase();
    final englishPlanName = _getEnglishPlanName(plan.name).toLowerCase();
    
    final isCurrentPlan = currentUserPlan == planName || 
                         currentUserPlan == englishPlanName ||
                         (currentUserPlan == 'gratuit' && englishPlanName == 'free') ||
                         (currentUserPlan == 'free' && planName == 'gratuit');
    
    // Vérifier si c'est un plan recommandé
    final isRecommended = plansProvider.isPlanRecommended(plan);
    
    // Déterminer si on doit afficher ce plan en mode mensuel
    final shouldShowInMonthly = !plansProvider.isYearlyBilling && 
                                plan.monthlyPrice == 0 && 
                                !plan.isFree && 
                                !isHydropowerPlan;
    
    // Ne pas afficher les plans qui n'ont que des prix annuels en mode mensuel
    // SAUF Hydropower qui doit toujours être visible
    if (shouldShowInMonthly) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.isDesktop(context) ? 0 : 16.w, 
        vertical: 8.h
      ),
      child: Card(
        elevation: isRecommended ? 12 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: isRecommended
              ? const BorderSide(color: AppTheme.primaryGreen, width: 2)
              : BorderSide.none,
        ),
        child: Container(
          padding: EdgeInsets.all(ResponsiveUtils.isDesktop(context) ? 32.w : 24.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: isRecommended
                ? LinearGradient(
                    colors: [
                      AppTheme.primaryGreen.withValues(alpha: 0.1),
                      Theme.of(context).colorScheme.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header avec nom et badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      plan.name,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, 26),
                        fontWeight: FontWeight.bold,
                        color: isRecommended 
                            ? AppTheme.primaryGreen 
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  // Badge CURRENT ou POPULAR
                  if (isCurrentPlan)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'CURRENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.getFontSize(context, 11),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else if (isRecommended)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'POPULAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ResponsiveUtils.getFontSize(context, 11),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              
              // Prix avec période de facturation
              _buildPriceSection(context, plansProvider),
              
              SizedBox(height: 24.h),
              
              // Divider
              Divider(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
              
              SizedBox(height: 16.h),
              
              // Features/Perks
              ...plan.perks.map((perk) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.primaryGreen,
                          size: 22.sp,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            perk,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getFontSize(context, 15),
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
              
              SizedBox(height: 24.h),
              
              // Action Button
              _buildActionButton(context, isCurrentPlan, localizations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection(BuildContext context, PlansProvider plansProvider) {
    // Plan gratuit
    if (plan.isFree) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '\$0',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 36),
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryGreen,
            ),
          ),
          Text(
            'Free for 7 days',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 15),
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      );
    }
    
    // Plan Hydropower Utilities - AFFICHAGE MODIFIÉ À 0$ 
    if (isHydropowerPlan) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 18),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),
              Text(
                '0',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 36),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryGreen,
                ),
              ),
              Text(
                '/year',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 15),
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16.sp,
                  color: AppTheme.primaryGreen,
                ),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    'Free until Go-Live',
                    style: TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: ResponsiveUtils.getFontSize(context, 12),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    
    // Plan entreprise
    if (plan.isEnterprise) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 36),
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryGreen,
            ),
          ),
          Text(
            'Contact us for pricing',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 15),
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      );
    }
    
    // Plans payants réguliers (Individual, Company)
    final currentPrice = plansProvider.isYearlyBilling 
        ? plan.yearlyPrice 
        : plan.monthlyPrice;
    final period = plansProvider.getBillingPeriodText();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 18),
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGreen,
              ),
            ),
            Text(
              currentPrice.toStringAsFixed(0),
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 36),
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryGreen,
              ),
            ),
            Text(
              period,
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 15),
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, 
    bool isCurrentPlan, 
    AppLocalizations localizations
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: isCurrentPlan ? null : () => _handlePlanSelection(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCurrentPlan
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)
              : _getButtonColor(context),
          foregroundColor: Colors.white,
          elevation: isCurrentPlan ? 0 : _getButtonElevation(),
          shadowColor: isCurrentPlan
              ? Colors.transparent
              : _getButtonShadowColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: _buildButtonContent(context, isCurrentPlan, localizations),
      ),
    );
  }

  Widget _buildButtonContent(
    BuildContext context,
    bool isCurrentPlan,
    AppLocalizations localizations,
  ) {
    if (isCurrentPlan) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 20.sp,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
          ),
          SizedBox(width: 8.w),
          Text(
            localizations.current,
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      );
    }

    String buttonText;
    if (plan.isEnterprise || isHydropowerPlan) {
      buttonText = localizations.contactUs;
    } else if (plan.isFree) {
      buttonText = 'Get Started';
    } else {
      buttonText = localizations.choosePlan;
    }

    return Text(
      buttonText,
      style: TextStyle(
        fontSize: ResponsiveUtils.getFontSize(context, 16),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Color _getButtonColor(BuildContext context) {
    final plansProvider = context.read<PlansProvider>();
    final isRecommended = plansProvider.isPlanRecommended(plan);
    
    if (plan.isFree) {
      return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8);
    } else if (isRecommended) {
      return AppTheme.primaryGreen;
    } else {
      return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8);
    }
  }

  double _getButtonElevation() {
    final isRecommended = plan.name.toLowerCase().contains('premium') ||
                         plan.name.toLowerCase().contains('pro');
    return isRecommended ? 8 : 4;
  }

  Color _getButtonShadowColor(BuildContext context) {
    final isRecommended = plan.name.toLowerCase().contains('premium') ||
                         plan.name.toLowerCase().contains('pro');
    return isRecommended
        ? AppTheme.primaryGreen.withValues(alpha: 0.3)
        : Colors.grey.withValues(alpha: 0.3);
  }

  void _handlePlanSelection(BuildContext context) async {
    if (plan.isEnterprise || isHydropowerPlan) {
      // Rediriger vers la page de contact avec le nom du plan
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ContactFormScreen(planName: plan.name),
        ),
      );
    } else if (plan.isFree) {
      // Pour les plans gratuits, mettre à jour le profil
      try {
        final profileProvider = context.read<ProfileProvider>();
        await profileProvider.updatePlan(plan.name);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Switched to ${plan.name} plan successfully!'),
              backgroundColor: AppTheme.primaryGreen,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to switch plan: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Plans payants - aller vers l'écran de paiement
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentScreen(plan: plan),
        ),
      );
    }
  }
}