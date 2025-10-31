import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';

enum UserType { individual, company }

class UserTypeSelectionScreen extends StatefulWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  State<UserTypeSelectionScreen> createState() =>
      _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen>
    with TickerProviderStateMixin {
  UserType? _selectedUserType;
  final _companyCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isValidating = false;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _scaleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _companyCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      mobile: _buildMobileLayout(),
      tablet: _buildSplitLayout(),
      desktop: _buildSplitLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryGreen.withValues(alpha: 0.1),
              Colors.white,
              AppTheme.primaryGreen.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              children: [
                SizedBox(height: 40.h),
                _buildHeader(),
                SizedBox(height: 50.h),
                _buildUserTypeSelection(),
                SizedBox(height: 30.h),
                _buildCompanyCodeSection(),
                SizedBox(height: 30.h),
                _buildContinueButton(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSplitLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Left side - Image section
          Expanded(
            child: _buildImageSection(),
          ),
          // Right side - User type selection form
          Expanded(
            child: _buildFormSection(),
          ),
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
          colors: [
            AppTheme.primaryGreen,
            AppTheme.lightGreen,
          ],
        ),
      ),
      child: Center(
        child: Image.asset(
          'assets/images/login.png',
          fit: BoxFit.contain,
          height: MediaQuery.of(context).size.height * 0.6,
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderDesktop(),
                const SizedBox(height: 40),
                _buildUserTypeSelectionDesktop(),
                const SizedBox(height: 30),
                _buildCompanyCodeSectionDesktop(),
                const SizedBox(height: 40),
                _buildContinueButtonDesktop(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.people_outline,
                size: 40.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              l10n.welcomeTo,
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 28),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.chooseAccountType,
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 16),
                color: AppTheme.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderDesktop() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.people_outline,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to TGM HydroAI',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose your account type to get started',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeSelection() {
    final l10n = AppLocalizations.of(context)!;
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          _buildUserTypeCard(
            userType: UserType.individual,
            icon: Icons.person,
            title: l10n.individual,
            subtitle: l10n.personalUse,
            color: Colors.blue,
          ),
          SizedBox(height: 16.h),
          _buildUserTypeCard(
            userType: UserType.company,
            icon: Icons.business,
            title: l10n.company,
            subtitle: l10n.businessAccount,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeSelectionDesktop() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          _buildUserTypeCardDesktop(
            userType: UserType.individual,
            icon: Icons.person,
            title: 'Individual',
            subtitle: 'Personal use with social login',
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildUserTypeCardDesktop(
            userType: UserType.company,
            icon: Icons.business,
            title: 'Company',
            subtitle: 'Business account with company code',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildUserTypeCard({
    required UserType userType,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isSelected = _selectedUserType == userType;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected ? AppTheme.primaryGreen : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Material(
        color:
            isSelected ? AppTheme.primaryGreen.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            setState(() {
              _selectedUserType = userType;
              if (userType == UserType.individual) {
                _companyCodeController.clear();
              }
            });
            HapticFeedback.lightImpact();
          },
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getFontSize(context, 18),
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getFontSize(context, 14),
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedScale(
                  scale: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryGreen,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyCodeSection() {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: _selectedUserType == UserType.company
          ? Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.companyCode,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, 16),
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _companyCodeController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      UpperCaseTextFormatter(),
                    ],
                    decoration: InputDecoration(
                      hintText: l10n.companyCodeHint,
                      prefixIcon: const Icon(Icons.business_center),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                            color: AppTheme.primaryGreen, width: 2),
                      ),
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.companyCodeRequired;
                      }
                      if (value.length != 6) {
                        return l10n.companyCodeLength;
                      }
                      if (!RegExp(r'^[A-Z0-9]{6}$').hasMatch(value)) {
                        return l10n.invalidCompanyCode;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value.length == 6) {
                        setState(() {});
                      }
                    },
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    l10n.companyCodeDescription,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, 12),
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildContinueButton() {
    final canContinue = _selectedUserType != null &&
        (_selectedUserType == UserType.individual ||
            (_selectedUserType == UserType.company &&
                _companyCodeController.text.length == 6));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 50.h,
        minWidth: double.infinity,
      ),
      child: ElevatedButton(
        onPressed: canContinue ? _handleContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              canContinue ? AppTheme.primaryGreen : Colors.grey[300],
          foregroundColor: canContinue ? Colors.white : Colors.grey[500],
          elevation: canContinue ? 4 : 0,
          shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.3),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: _isValidating
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  l10n.continueButton,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (_selectedUserType == UserType.company) {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      setState(() {
        _isValidating = true;
      });

      // Simulate company code validation
      await Future.delayed(const Duration(milliseconds: 1500));

      setState(() {
        _isValidating = false;
      });
    }

    // Save user type selection to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_type', _selectedUserType!.name);

      if (_selectedUserType == UserType.company) {
        await prefs.setString('company_code', _companyCodeController.text);
      } else {
        await prefs.remove('company_code');
      }

      await prefs.setBool('user_type_selected', true);
    } catch (e) {
      //debugPrint('Failed to save user type: $e');
    }

    // Navigate to login with user type information
    if (mounted) {
      context.push('/login', extra: {
        'userType': _selectedUserType!.name,
        'companyCode': _selectedUserType == UserType.company
            ? _companyCodeController.text
            : null,
      });
    }
  }

  Widget _buildUserTypeCardDesktop({
    required UserType userType,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isSelected = _selectedUserType == userType;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.primaryGreen : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Material(
        color:
            isSelected ? AppTheme.primaryGreen.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _selectedUserType = userType;
              if (userType == UserType.individual) {
                _companyCodeController.clear();
              }
            });
            HapticFeedback.lightImpact();
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedScale(
                  scale: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyCodeSectionDesktop() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: _selectedUserType == UserType.company
          ? Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Company Code',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _companyCodeController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      UpperCaseTextFormatter(),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter 6-digit company code',
                      prefixIcon: const Icon(Icons.business_center),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppTheme.primaryGreen, width: 2),
                      ),
                      counterText: '',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Company code is required';
                      }
                      if (value.length != 6) {
                        return 'Company code must be exactly 6 characters';
                      }
                      if (!RegExp(r'^[A-Z0-9]{6}$').hasMatch(value)) {
                        return 'Only uppercase letters and numbers allowed';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (value.length == 6) {
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '6 uppercase alphanumeric characters (A-Z, 0-9)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildContinueButtonDesktop() {
    final canContinue = _selectedUserType != null &&
        (_selectedUserType == UserType.individual ||
            (_selectedUserType == UserType.company &&
                _companyCodeController.text.length == 6));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 50,
        minWidth: double.infinity,
      ),
      child: ElevatedButton(
        onPressed: canContinue ? _handleContinue : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              canContinue ? AppTheme.primaryGreen : Colors.grey[300],
          foregroundColor: canContinue ? Colors.white : Colors.grey[500],
          elevation: canContinue ? 4 : 0,
          shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isValidating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
    );
  }

  static Future<void> clearUserTypeSelection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_type');
      await prefs.remove('company_code');
      await prefs.setBool('user_type_selected', false);
    } catch (e) {
      //debugPrint('Failed to clear user type selection: $e');
    }
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}