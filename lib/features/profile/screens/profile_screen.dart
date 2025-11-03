import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import 'package:tgm_ai_chat/features/plans/screens/plans_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/auth_guard.dart';
import '../../../core/widgets/user_avatar.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndInitialize();
  }

  Future<void> _checkAuthenticationAndInitialize() async {
    final isAuthenticated = await AuthGuard.checkAuthAndRedirect(context);

    if (isAuthenticated && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProfileProvider>().refreshUserProfile();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
        ],
      ),
      body: ResponsiveWidget(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }


  Widget _buildMobileLayout(BuildContext context) {
    
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16, 
        16, 
        16, 
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: _ProfileContent(
        onEditProfile: () => _showEditDialog(context),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _ProfileContent(
            onEditProfile: () => _showEditDialog(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Card(
          elevation: ResponsiveUtils.getCardElevation(context),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: _ProfileContent(
              onEditProfile: () => _showEditDialog(context),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final provider = context.read<ProfileProvider>();
    final profile = provider.userProfile;

    if (profile == null) return;

    final nameController = TextEditingController(text: profile.name);
    final emailController = TextEditingController(text: profile.email);
    String? newAvatarUrl = profile.avatarUrl;
    XFile? selectedImageFile;
    

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.editProfile),
          content: SizedBox(
            width: ResponsiveUtils.isDesktop(context) ? 400 : double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProfileImagePicker(
                    currentImageUrl: newAvatarUrl,
                    initials: profile.initials,
                    onImageSelected: (imageUrl, imageFile) {
                      setState(() {
                        newAvatarUrl = imageUrl;
                        selectedImageFile = imageFile;
                      });
                    },
                  ),
                  SizedBox(height: 24.h),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.name,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person, size: 20),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // CHAMP EMAIL GRISÉ (DISABLED)
                  TextField(
                    controller: emailController,
                    enabled: false, // ✅ Email désactivé pour tous les utilisateurs
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: Colors.grey[600], // Style pour montrer qu'il est désactivé
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.email,
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email, size: 20, color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[200], // Fond gris pour montrer qu'il est désactivé
                      helperText: AppLocalizations.of(context)!.emailCannotBeChanged, // Message d'aide
                      helperStyle: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            // ✅ REMPLACEZ TOUT CE BLOC ElevatedButton
            ElevatedButton(
              onPressed: provider.isLoading 
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.nameCannotBeEmpty),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      try {
                        await provider.updateProfile(
                          name: nameController.text.trim(),
                          avatarUrl: newAvatarUrl,
                          avatarFile: selectedImageFile,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.profileUpdatedSuccessfully),
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.failedToUpdateProfile(e.toString())),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: provider.isLoading 
                    ? Colors.grey[300]
                    : AppTheme.primaryGreen,
                foregroundColor: provider.isLoading
                    ? Colors.grey[600]
                    : Colors.white,
              ),
              child: provider.isLoading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.save),
                      ],
                    )
                  : Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final VoidCallback onEditProfile;

  const _ProfileContent({required this.onEditProfile});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.userProfile == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final profile = provider.userProfile;
        if (profile == null) {
          return Center(
            child: Text(AppLocalizations.of(context)!.noProfileData),
          );
        }

        return Consumer<ProfileProvider>(
          builder: (context, profileProvider, _) {
            return Column(
              children: [
                _buildProfileHeader(context, profile),
                SizedBox(height: 30.h),
                _buildStatsSection(context, profile),
                SizedBox(height: 20.h),
                // Only show plan section for individual users
                if (!profileProvider.isCompanyUser) ...[
                  _buildPlanSection(context),
                  SizedBox(height: 20.h),
                ],
                SizedBox(height: 30.h),
                _buildMenuSection(context),
                SizedBox(height: 30.h),
                _buildLogoutButton(context),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic profile) {
    return Column(
      children: [
        UserAvatar(
          initials: profile.initials,
          size: ResponsiveUtils.isDesktop(context) ? 100 : 80,
          imageUrl: profile.avatarUrl,
        ),
        SizedBox(height: 15.h),
        Text(
          profile.name,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 18),
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          profile.email,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 14),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, dynamic profile) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            profile.stats.messageCount.toString(),
            AppLocalizations.of(context)!.messages,
          ),
          _buildStatItem(
            context,
            profile.stats.daysActive.toString(),
            AppLocalizations.of(context)!.daysActive,
          ),
          _buildStatItem(
            context,
            profile.stats.rating.toStringAsFixed(1),
            AppLocalizations.of(context)!.rating,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 12),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              AppLocalizations.of(context)!.currentPlanTitle,
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, _) {
              final plan = profileProvider.userProfile?.currentPlan ?? 'Free';
              final expiryDate = profileProvider.userProfile?.planExpiryDate;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "${AppLocalizations.of(context)!.currentPlan} $plan",
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, 14),
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (expiryDate != null && plan != 'Free') ...[
                    SizedBox(height: 4.h),
                    Text(
                      AppLocalizations.of(context)!.expires(
                          "${expiryDate.day}/${expiryDate.month}/${expiryDate.year}"),
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getFontSize(context, 12),
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        final menuItems = [
          {
            'title': AppLocalizations.of(context)!.editProfile,
            'icon': Icons.edit,
            'onTap': onEditProfile,
          },
          {
            'title': AppLocalizations.of(context)!.settings,
            'icon': Icons.tune,
            'onTap': () => context.push('/settings'),
          },
          {
            'title': AppLocalizations.of(context)!.helpAndSupport,
            'icon': Icons.help_outline,
            'onTap': () => _showHelp(context),
          },
          {
            'title': AppLocalizations.of(context)!.about,
            'icon': Icons.info_outline,
            'onTap': () => _showAbout(context),
          },
          // Only show Change Plan for individual users
          if (!profileProvider.isCompanyUser)
            {
              'title': AppLocalizations.of(context)!.changePlan,
              'icon': Icons.price_change,
              'onTap': () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PlansScreen(),
                    ),
                  ),
            },
        ];

        return Column(
          children: menuItems
              .map((item) => _buildMenuItem(
                    context,
                    item['title'] as String,
                    item['icon'] as IconData,
                    item['onTap'] as VoidCallback,
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, 14),
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          size: 16,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.helpAndSupportTitle),
        content: Text(AppLocalizations.of(context)!.helpAndSupportContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.aboutTitle),
        content: Text(AppLocalizations.of(context)!.aboutContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        width: double.infinity,
        height: 45, // Hauteur stable
        child: ElevatedButton(
          onPressed: () => _showLogoutDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.logOut,
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logOut),
        content: Text(AppLocalizations.of(context)!.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<ProfileProvider>().logout();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/user-type');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.logOut,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}