import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tgm_ai_chat/core/theme/app_theme.dart';
import 'package:tgm_ai_chat/core/utils/responsive.dart';
import 'package:tgm_ai_chat/l10n/app_localizations.dart';
import 'package:tgm_ai_chat/core/services/contact_service.dart';

class ContactFormScreen extends StatefulWidget {
  final String? planName; // Nom du plan qui a déclenché le contact
  
  const ContactFormScreen({
    super.key,
    this.planName,
  });

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  
  // Service de contact
  final ContactService _contactService = ContactService();

  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
    
    // Pré-remplir le message si un plan est spécifié
    if (widget.planName != null) {
      _messageController.text = 
          'I am interested in the ${widget.planName} plan. Please contact me with more information about pricing and features.';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _companyController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      _buildHeaderCard(context),
                      SizedBox(height: 24.h),
                      _buildContactForm(context),
                      SizedBox(height: 24.h),
                      _buildContactInfo(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryGreen,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          AppLocalizations.of(context)?.enterpriseContact ??
              'Enterprise Contact',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: ResponsiveUtils.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryGreen,
                AppTheme.primaryGreen.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50.w,
                top: -50.h,
                child: Container(
                  width: 150.w,
                  height: 150.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                left: -30.w,
                bottom: -30.h,
                child: Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.business,
                size: 40.sp,
                color: AppTheme.primaryGreen,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              widget.planName != null 
                  ? '${widget.planName} Plan'
                  : (AppLocalizations.of(context)?.enterpriseSolutions ?? 'Enterprise Solutions'),
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 24),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context)?.enterpriseDescription ??
                  'Get customized solutions for your business needs. Our team will contact you within 24 hours to discuss your requirements.',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 14),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.contactInformation,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 20.h),

              // Company Name Field
              _buildAnimatedField(
                child: TextFormField(
                  controller: _companyController,
                  decoration: _buildInputDecoration(
                    label: AppLocalizations.of(context)!.companyName,
                    icon: Icons.business,
                    hint: AppLocalizations.of(context)!.enterCompanyName,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .pleaseEnterCompanyName;
                    }
                    return null;
                  },
                ),
                delay: 200,
              ),

              SizedBox(height: 16.h),

              // Full Name Field
              _buildAnimatedField(
                child: TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration(
                    label: AppLocalizations.of(context)!.fullName,
                    icon: Icons.person,
                    hint: AppLocalizations.of(context)!.pleaseEnterFullName,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterFullName;
                    }
                    return null;
                  },
                ),
                delay: 300,
              ),

              SizedBox(height: 16.h),

              // Email Field
              _buildAnimatedField(
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration(
                    label: AppLocalizations.of(context)!.email,
                    icon: Icons.email,
                    hint: AppLocalizations.of(context)!.pleaseEnterEmailAddress,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .pleaseEnterEmailAddress;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return AppLocalizations.of(context)!
                          .pleaseEnterValidEmail;
                    }
                    return null;
                  },
                ),
                delay: 400,
              ),

              SizedBox(height: 16.h),

              // Phone Field
              _buildAnimatedField(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _buildInputDecoration(
                    label: AppLocalizations.of(context)!.phoneNumber,
                    icon: Icons.phone,
                    hint: AppLocalizations.of(context)!.enterPhoneNumber,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .pleaseEnterPhoneNumber;
                    }
                    return null;
                  },
                ),
                delay: 500,
              ),

              SizedBox(height: 16.h),

              // Message Field
              _buildAnimatedField(
                child: TextFormField(
                  controller: _messageController,
                  maxLines: 4,
                  decoration: _buildInputDecoration(
                    label: AppLocalizations.of(context)!.message,
                    icon: Icons.message,
                    hint: AppLocalizations.of(context)!.enterMessage,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterMessage;
                    }
                    if (value.length < 20) {
                      return AppLocalizations.of(context)!
                          .pleaseProvideMoreDetails;
                    }
                    return null;
                  },
                ),
                delay: 600,
              ),

              SizedBox(height: 32.h),

              // Submit Button
              _buildAnimatedField(
                child: SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: _isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                AppLocalizations.of(context)!.sending,
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveUtils.getFontSize(context, 16),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            AppLocalizations.of(context)!.sendMessage,
                            style: TextStyle(
                              fontSize:
                                  ResponsiveUtils.getFontSize(context, 16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                delay: 700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.alternativeContactMethods,
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 18),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16.h),
            _buildContactItem(
              icon: Icons.email_outlined,
              title: AppLocalizations.of(context)!.email,
              subtitle: AppLocalizations.of(context)!.enterpriseEmail,
              color: Colors.blue,
            ),
            SizedBox(height: 12.h),
            _buildContactItem(
              icon: Icons.phone_outlined,
              title: AppLocalizations.of(context)!.phoneNumber,
              subtitle: AppLocalizations.of(context)!.enterprisePhone,
              color: Colors.green,
            ),
            SizedBox(height: 12.h),
            _buildContactItem(
              icon: Icons.access_time_outlined,
              title: AppLocalizations.of(context)!.businessHours,
              subtitle: AppLocalizations.of(context)!.businessHoursText,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 12),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedField({required Widget child, required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20.sp),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Theme.of(context).dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: AppTheme.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    );
  }

  // ✅ MÉTHODE CORRIGÉE - ENREGISTRE DANS POCKETBASE
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      //print('📤 Envoi de la demande de contact vers PocketBase...');
      
      // ✅ APPEL RÉEL À L'API POCKETBASE
      await _contactService.submitContactRequest(
        company: _companyController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        message: _messageController.text.trim(),
        planInterested: widget.planName, // Hydropower, Enterprise, etc.
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.messageSentSuccessfully,
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.primaryGreen,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );

        // Clear form
        _formKey.currentState!.reset();
        _companyController.clear();
        _nameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _messageController.clear();

        // Navigate back after a delay
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      //print('❌ Erreur lors de l\'envoi: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Failed to send message: ${e.toString()}',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}