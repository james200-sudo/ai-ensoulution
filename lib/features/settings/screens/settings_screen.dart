import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tgm_ai_chat/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/auth_guard.dart';
import '../providers/settings_provider.dart';
import '../widgets/setting_toggle.dart';
import '../../chat/providers/chat_provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndInitialize();
  }

  Future<void> _checkAuthenticationAndInitialize() async {
    await AuthGuard.checkAuthAndRedirect(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ResponsiveWidget(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return const SingleChildScrollView(
      child: _SettingsContent(),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: const SingleChildScrollView(
          child: _SettingsContent(),
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
          child: const SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: _SettingsContent(),
          ),
        ),
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        if (settingsProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final settings = settingsProvider.settings;

        return Column(
          children: [
            SizedBox(height: 16.h),

            // Notifications Section
            SettingsSection(
              title: 'Notifications',
              children: [
                SettingToggle(
                  label: 'Push Notifications',
                  subtitle: 'Receive notifications for new messages',
                  value: settings.pushNotifications,
                  onChanged: settingsProvider.updatePushNotifications,
                  icon: Icons.notifications,
                ),
                const Divider(height: 1),
                SettingToggle(
                  label: 'Message Sounds',
                  subtitle: 'Play sound when messages arrive',
                  value: settings.messageSounds,
                  onChanged: settingsProvider.updateMessageSounds,
                  icon: Icons.volume_up,
                ),
              ],
            ),

            // Chat Preferences Section
            SettingsSection(
              title: 'Chat Preferences',
              children: [
                SettingToggle(
                  label: 'Auto-save Conversations',
                  subtitle: 'Automatically save chat history',
                  value: settings.autoSaveConversations,
                  onChanged: (value) async {
                    await settingsProvider.updateAutoSaveConversations(value);
                    // Notify chat provider about the change
                    if (context.mounted) {
                      await context
                          .read<ChatProvider>()
                          .onAutoSaveSettingChanged(value);
                    }
                  },
                  icon: Icons.save,
                ),
                const Divider(height: 1),
                SettingToggle(
                  label: 'Dark Mode',
                  subtitle: 'Use dark theme for the app',
                  value: settings.darkMode,
                  onChanged: settingsProvider.updateDarkMode,
                  icon: Icons.dark_mode,
                ),
              ],
            ),

            // Security Section - only show if biometric is available
            if (settingsProvider.biometricAvailable)
              SettingsSection(
                title: 'Security',
                children: [
                  SettingToggle(
                    label: 'Biometric Authentication',
                    subtitle: 'Use fingerprint or face ID to unlock',
                    value: settings.biometricAuth,
                    onChanged: settingsProvider.updateBiometricAuth,
                    icon: Icons.fingerprint,
                  ),
                ],
              ),

            // Account Section
            SettingsSection(
              title: 'Account',
              children: [
                SettingItem(
                  label: 'Privacy Settings',
                  subtitle: 'Manage your privacy preferences',
                  icon: Icons.privacy_tip,
                  onTap: () => _showPrivacySettings(context),
                ),
                const Divider(height: 1),
                SettingItem(
                  label: AppLocalizations.of(context)!.language,
                  subtitle: _getLanguageDisplayName(context, settings.language),
                  icon: Icons.language,
                  onTap: () => _showLanguageSettings(context),
                ),
                const Divider(height: 1),
                SettingItem(
                  label: 'Font Size',
                  subtitle: _getFontSizeLabel(settings.fontSize),
                  icon: Icons.text_fields,
                  onTap: () => _showFontSizeSettings(context),
                ),
                const Divider(height: 1),
                SettingItem(
                  label: 'Help & Support',
                  subtitle: 'Get help or contact support',
                  icon: Icons.help_outline,
                  onTap: () => _showHelp(context),
                ),
                const Divider(height: 1),
                SettingItem(
                  label: 'About',
                  subtitle: 'App version and information',
                  icon: Icons.info_outline,
                  onTap: () => _showAbout(context),
                ),
              ],
            ),

            // Danger Zone Section
            SettingsSection(
              title: 'Data & Storage',
              children: [
                SettingItem(
                  label: 'Clear Chat History',
                  subtitle: 'Delete all conversation history',
                  icon: Icons.delete_outline,
                  onTap: () => _showClearHistoryDialog(context),
                ),
                const Divider(height: 1),
                SettingItem(
                  label: 'Reset Settings',
                  subtitle: 'Reset all settings to default',
                  icon: Icons.restore,
                  onTap: () => _showResetDialog(context),
                ),
              ],
            ),

            SizedBox(height: 20.h),
          ],
        );
      },
    );
  }

  String _getFontSizeLabel(double fontSize) {
    if (fontSize <= 12) return 'Small';
    if (fontSize <= 14) return 'Medium';
    if (fontSize <= 16) return 'Large';
    return 'Extra Large';
  }

  String _getLanguageDisplayName(BuildContext context, String languageCode) {
    switch (languageCode) {
      case 'fr':
        return AppLocalizations.of(context)!.languageFrench;
      case 'es':
        return AppLocalizations.of(context)!.languageSpanish;
      case 'en':
      default:
        return AppLocalizations.of(context)!.languageEnglish;
    }
  }

  void _showPrivacySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: const Text(
            'Privacy settings would be configured here, including data collection preferences and privacy controls.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSettings(BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();
    final currentLanguage = settingsProvider.settings.language;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context)!.languageEnglish),
              trailing: currentLanguage == 'en'
                  ? const Icon(Icons.check,
                      color: AppTheme.primaryGreen, size: 20)
                  : null,
              onTap: () {
                settingsProvider.updateLanguage('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.languageFrench),
              trailing: currentLanguage == 'fr'
                  ? const Icon(Icons.check,
                      color: AppTheme.primaryGreen, size: 20)
                  : null,
              onTap: () {
                settingsProvider.updateLanguage('fr');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.languageSpanish),
              trailing: currentLanguage == 'es'
                  ? const Icon(Icons.check,
                      color: AppTheme.primaryGreen, size: 20)
                  : null,
              onTap: () {
                settingsProvider.updateLanguage('es');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeSettings(BuildContext context) {
    final provider = context.read<SettingsProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Size'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sample text with current size',
                  style: TextStyle(fontSize: provider.settings.fontSize),
                ),
                SizedBox(height: 20.h),
                Slider(
                  value: provider.settings.fontSize,
                  min: 10,
                  max: 20,
                  divisions: 4,
                  label: _getFontSizeLabel(provider.settings.fontSize),
                  onChanged: (value) {
                    setState(() {});
                    provider.updateFontSize(value);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Text(
            'For support, please contact us at:\nsupport@ensolutions.ca\n\nOr visit our help center online for frequently asked questions and troubleshooting guides.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About TGM AI'),
        content: const Text(
            'TGM HydroAI Chat App v1.0.0\n\nAn intelligent chat application powered by advanced AI technology.\n\nBuilt with Flutter and designed for seamless communication with AI assistants.\n\n© 2024 TGM AI. All rights reserved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat History'),
        content: const Text(
            'This will permanently delete all your conversation history. This action cannot be undone.\n\nAre you sure you want to continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<ChatProvider>().clearSavedMessages();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chat history cleared successfully'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to clear chat history'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
            'This will reset all settings to their default values. Are you sure you want to continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              context.read<SettingsProvider>().resetSettings();
              // Also clear user type selection when resetting all settings
              await _clearUserTypeSelection();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings reset to defaults'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearUserTypeSelection() async {
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
