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
    final l10n = AppLocalizations.of(context)!;
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
              title: l10n.notifications,
              children: [
                SettingToggle(
                  label: l10n.pushNotifications,
                  subtitle: l10n.pushNotificationsDesc,
                  value: settings.pushNotifications,
                  onChanged: settingsProvider.updatePushNotifications,
                  icon: Icons.notifications,
                ),
                const Divider(height: 1),
                SettingToggle(
                  label: l10n.messageSounds,
                  subtitle: l10n.messageSoundsDesc,
                  value: settings.messageSounds,
                  onChanged: settingsProvider.updateMessageSounds,
                  icon: Icons.volume_up,
                ),
              ],
            ),

            // Chat Preferences Section
            SettingsSection(
              title: l10n.chatPreferences,
              children: [
                SettingToggle(
                  label: l10n.autoSaveConversations,
                  subtitle: l10n.autoSaveConversationsDesc,
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
                  label: l10n.darkMode,
                  subtitle: l10n.darkModeDesc,
                  value: settings.darkMode,
                  onChanged: settingsProvider.updateDarkMode,
                  icon: Icons.dark_mode,
                ),
              ],
            ),

            // Security Section - only show if biometric is available
            if (settingsProvider.biometricAvailable)
              SettingsSection(
                title: l10n.security,
                children: [
                  SettingToggle(
                    label: l10n.biometricAuth,
                    subtitle: l10n.biometricAuthDesc,
                    value: settings.biometricAuth,
                    onChanged: settingsProvider.updateBiometricAuth,
                    icon: Icons.fingerprint,
                  ),
                ],
              ),

            // Account Section
            SettingsSection(
              title: l10n.account,
              children: [
                SettingItem(
                  label: l10n.privacySettings,
                  subtitle: l10n.privacySettingsDesc,
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
                  label: l10n.fontSize,
                  subtitle: _getFontSizeLabel(context, settings.fontSize),
                  icon: Icons.text_fields,
                  onTap: () => _showFontSizeSettings(context),
                ),
                const Divider(height: 1),
                SettingItem(
                  label: l10n.helpAndSupport,
                  subtitle: l10n.helpAndSupportDesc,
                  icon: Icons.help_outline,
                  onTap: () => _showHelp(context),
                ),
                const Divider(height: 1),
                SettingItem(
                  label: l10n.about,
                  subtitle: l10n.aboutDesc,
                  icon: Icons.info_outline,
                  onTap: () => _showAbout(context),
                ),
              ],
            ),

            // Danger Zone Section
            SettingsSection(
              title: l10n.dataAndStorage,
              children: [
                SettingItem(
                  label: l10n.clearChatHistory,
                  subtitle: l10n.clearChatHistoryDesc,
                  icon: Icons.delete_outline,
                  onTap: () => _showClearHistoryDialog(context),
                ),
                const Divider(height: 1),
                SettingItem(
                  label: l10n.resetSettings,
                  subtitle: l10n.resetSettingsDesc,
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

  String _getFontSizeLabel(BuildContext context, double fontSize) {
    final l10n = AppLocalizations.of(context)!;
    if (fontSize <= 12) return l10n.fontSizeSmall;
    if (fontSize <= 14) return l10n.fontSizeMedium;
    if (fontSize <= 16) return l10n.fontSizeLarge;
    return l10n.fontSizeExtraLarge;
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.privacySettings),
        content: Text(l10n.privacySettingsContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showLanguageSettings(BuildContext context) {
    final settingsProvider = context.read<SettingsProvider>();
    final currentLanguage = settingsProvider.settings.language;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.languageEnglish),
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
              title: Text(l10n.languageFrench),
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
              title: Text(l10n.languageSpanish),
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
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.fontSize),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.fontSizeSample,
                  style: TextStyle(fontSize: provider.settings.fontSize),
                ),
                SizedBox(height: 20.h),
                Slider(
                  value: provider.settings.fontSize,
                  min: 10,
                  max: 20,
                  divisions: 4,
                  label: _getFontSizeLabel(context, provider.settings.fontSize),
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
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.helpAndSupport),
        content: Text(l10n.helpAndSupportContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.aboutTgmAi),
        content: Text(l10n.aboutContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearChatHistory),
        content: Text(l10n.clearHistoryDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await context.read<ChatProvider>().clearSavedMessages();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.historyClearedSuccess),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.historyClearedError),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.clear, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetSettings),
        content: Text(l10n.resetSettingsDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              context.read<SettingsProvider>().resetSettings();
              // Also clear user type selection when resetting all settings
              await _clearUserTypeSelection();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.settingsResetSuccess),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              }
            },
            child: Text(l10n.reset),
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
