import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tgm_ai_chat/features/plans/models/plan_model.dart';
import 'package:tgm_ai_chat/features/plans/widgets/plan_card.dart';
import 'package:tgm_ai_chat/features/plans/providers/plans_provider.dart';
import 'package:tgm_ai_chat/core/theme/app_theme.dart';
import 'package:tgm_ai_chat/core/utils/responsive.dart';
import 'package:tgm_ai_chat/features/profile/providers/profile_provider.dart';
import 'package:tgm_ai_chat/l10n/app_localizations.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  Future<void> _initializeScreen() async {
    final plansProvider = context.read<PlansProvider>();
    final profileProvider = context.read<ProfileProvider>();
    
    try {
      await plansProvider.ensurePlansLoaded();
      await profileProvider.syncPlanFromPocketBase();
      await profileProvider.refreshUserProfile();
      
      //print('✅ PlansScreen: Initialisation complète terminée');
    } catch (e) {
      //print('❌ PlansScreen: Erreur lors de l\'initialisation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          _buildSliverAppBar(context),
          
          // Hero Section avec toggle billing
          SliverToBoxAdapter(
            child: _buildHeroSection(context),
          ),
          
          // Plans Content
          Consumer2<PlansProvider, ProfileProvider>(
            builder: (context, plansProvider, profileProvider, child) {
              if (plansProvider.isLoading && !plansProvider.hasPlans) {
                return _buildLoadingSliver();
              }
              
              if (plansProvider.hasError && !plansProvider.hasPlans) {
                return _buildErrorSliver(context, plansProvider);
              }
              
              if (!plansProvider.hasPlans) {
                return _buildEmptySliver(context);
              }
              
              final sortedPlans = plansProvider.getSortedPlans();
              
              // Disposition responsive AMÉLIORÉE style Bootstrap
              if (isDesktop) {
                return _buildDesktopPlansGrid(sortedPlans, context);
              } else if (isTablet) {
                return _buildTabletPlansGrid(sortedPlans);
              } else {
                return _buildMobilePlansGrid(sortedPlans);
              }
            },
          ),
          
          // Bottom CTA Section
          SliverToBoxAdapter(
            child: _buildBottomSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return SliverAppBar(
      expandedHeight: 100.h,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryGreen,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      actions: [
        Consumer2<PlansProvider, ProfileProvider>(
          builder: (context, plansProvider, profileProvider, _) {
            return IconButton(
              onPressed: (plansProvider.isLoading || profileProvider.isLoading) 
                  ? null 
                  : () => _handleRefresh(plansProvider, profileProvider),
              icon: (plansProvider.isRefreshing || profileProvider.isLoading)
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.refresh),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          localizations.chooseYourPlan,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 20),
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Future<void> _handleRefresh(PlansProvider plansProvider, ProfileProvider profileProvider) async {
    try {
      //print('🔄 PlansScreen: Début du rafraîchissement complet');
      
      await Future.wait([
        plansProvider.refreshPlans(),
        profileProvider.syncPlanFromPocketBase(),
      ]);
      
      await profileProvider.refreshUserProfile();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plans and profile refreshed successfully'),
            backgroundColor: AppTheme.primaryGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      //print('✅ PlansScreen: Rafraîchissement complet terminé');
    } catch (e) {
      //print('❌ PlansScreen: Erreur lors du rafraîchissement: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildHeroSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDesktop = ResponsiveUtils.isDesktop(context);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60.w : 24.w, 
        vertical: isDesktop ? 60.h : 40.h
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryGreen,
            AppTheme.primaryGreen.withValues(alpha: 0.8),
            Theme.of(context).colorScheme.background,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            localizations.unlockThePowerOfAI,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, isDesktop ? 40 : 32),
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            constraints: BoxConstraints(maxWidth: isDesktop ? 600.w : double.infinity),
            child: Text(
              localizations.choosePerfectPlan,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, isDesktop ? 18 : 16),
                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 32.h),

          // Billing Toggle
          _buildBillingToggle(context),
          SizedBox(height: 24.h),

          // Current Plan Info
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, _) {
              if (!profileProvider.isLoading && profileProvider.userProfile != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  profileProvider.syncPlanFromPocketBase();
                });
              }
              
              final currentPlan = profileProvider.userProfile?.currentPlan ?? 'Free';
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (profileProvider.isLoading) ...[
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Text(
                      '${localizations.currentPlan}: $currentPlan',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: ResponsiveUtils.getFontSize(context, 15),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBillingToggle(BuildContext context) {
    return Consumer<PlansProvider>(
      builder: (context, plansProvider, _) {
        return Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleButton(
                context,
                'Monthly',
                !plansProvider.isYearlyBilling,
                () => plansProvider.setBillingPeriod(isYearly: false),
              ),
              _buildToggleButton(
                context,
                'Yearly',
                plansProvider.isYearlyBilling,
                () => plansProvider.setBillingPeriod(isYearly: true),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.onPrimary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected 
                ? AppTheme.primaryGreen
                : Theme.of(context).colorScheme.onPrimary,
            fontSize: ResponsiveUtils.getFontSize(context, 16),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Desktop: Layout une seule colonne centrée
  Widget _buildDesktopPlansGrid(List<Plan> plans, BuildContext context) {
    // Largeur maximale pour une seule colonne (comme Bootstrap container-sm)
    final double maxWidth = 600.w;
    
    return SliverToBoxAdapter(
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 50.h),
          child: Column(
            children: plans.asMap().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: _buildAnimatedPlanCard(entry.value, entry.key),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Tablette: Grille 2 colonnes avec meilleur spacing
  Widget _buildTabletPlansGrid(List<Plan> plans) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 32.h),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 24.w,
          mainAxisSpacing: 24.h,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildAnimatedPlanCard(plans[index], index),
          childCount: plans.length,
        ),
      ),
    );
  }

  // Mobile: Liste verticale
  Widget _buildMobilePlansGrid(List<Plan> plans) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 24.h),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildAnimatedPlanCard(plans[index], index),
          childCount: plans.length,
        ),
      ),
    );
  }

  Widget _buildAnimatedPlanCard(Plan plan, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: PlanCard(plan: plan),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSliver() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryGreen),
            SizedBox(height: 16.h),
            Text(
              'Loading plans...',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 16),
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSliver(BuildContext context, PlansProvider plansProvider) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.sp,
                color: Colors.red,
              ),
              SizedBox(height: 16.h),
              Text(
                'Failed to load plans',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 18),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                plansProvider.errorMessage ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 14),
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: () => _handleRefresh(
                  context.read<PlansProvider>(), 
                  context.read<ProfileProvider>()
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySliver(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64.sp,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'No plans available',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 18),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDesktop = ResponsiveUtils.isDesktop(context);
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60.w : 24.w, 
        vertical: 50.h
      ),
      padding: EdgeInsets.all(isDesktop ? 48.w : 32.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.security,
            size: isDesktop ? 56.sp : 48.sp,
            color: AppTheme.primaryGreen,
          ),
          SizedBox(height: 20.h),
          Text(
            localizations.secureAndReliable,
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, isDesktop ? 24 : 20),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            constraints: BoxConstraints(maxWidth: isDesktop ? 600.w : double.infinity),
            child: Text(
              localizations.enterpriseGradeSecurity,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 15),
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.6,
              ),
            ),
          ),
          SizedBox(height: 32.h),
          Wrap(
            spacing: isDesktop ? 60.w : 40.w,
            runSpacing: 20.h,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureIcon(context, Icons.shield, localizations.secure),
              _buildFeatureIcon(context, Icons.speed, localizations.fast),
              _buildFeatureIcon(context, Icons.support_agent, localizations.support247),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(BuildContext context, IconData icon, String label) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isDesktop ? 16.w : 12.w),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primaryGreen.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryGreen,
            size: isDesktop ? 28.sp : 24.sp,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 14),
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}