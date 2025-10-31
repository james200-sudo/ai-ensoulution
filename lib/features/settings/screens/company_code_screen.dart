import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../providers/settings_provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CompanyCodeScreen extends StatefulWidget {
  const CompanyCodeScreen({super.key});

  @override
  State<CompanyCodeScreen> createState() => _CompanyCodeScreenState();
}

class _CompanyCodeScreenState extends State<CompanyCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _companyCodeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final settingsProvider = context.read<SettingsProvider>();
    _companyCodeController = TextEditingController(
      text: settingsProvider.settings.companyCode ?? '',
    );
  }

  @override
  void dispose() {
    _companyCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ResponsiveWidget(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return _buildContent();
  }

  Widget _buildTabletLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Card(
          elevation: ResponsiveUtils.getCardElevation(context),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20.h),
            Text(
              'Configure Company Code',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 24),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Enter your company code to associate your account with your organization. This field is optional.',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 14),
                color: AppTheme.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.h),
            TextFormField(
              controller: _companyCodeController,
              decoration: const InputDecoration(
                labelText: 'Company Code',
                hintText: 'Enter your company code (optional)',
                prefixIcon: Icon(Icons.business, size: 20),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                // No validation required as it's optional
                return null;
              },
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _clearCode,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Text(
                        'Clear Code',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getFontSize(context, 14),
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
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
                              'Save Code',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getFontSize(context, 14),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final code = _companyCodeController.text.trim();
      final settingsProvider = context.read<SettingsProvider>();
      
      await settingsProvider.updateCompanyCode(code.isEmpty ? null : code.toUpperCase());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(code.isEmpty 
                ? 'Company code cleared successfully'
                : 'Company code saved successfully'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save company code: ${e.toString()}'),
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

  Future<void> _clearCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final settingsProvider = context.read<SettingsProvider>();
      await settingsProvider.updateCompanyCode(null);
      _companyCodeController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Company code cleared successfully'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear company code: ${e.toString()}'),
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
}