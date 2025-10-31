import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../settings/providers/settings_provider.dart';

class LanguageSelector extends StatelessWidget {
  final bool showLabel;
  final bool compactMode;

  const LanguageSelector({
    super.key,
    this.showLabel = true,
    this.compactMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final currentLocale = settingsProvider.settings.locale;
    final isMobile = ResponsiveUtils.isMobile(context);

    if (compactMode) {
      return _buildCompactSelector(context, settingsProvider, currentLocale, isMobile);
    }

    return _buildFullSelector(context, settingsProvider, currentLocale, isMobile);
  }

  Widget _buildCompactSelector(
    BuildContext context,
    SettingsProvider settingsProvider,
    String currentLocale,
    bool isMobile,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.language,
        color: AppTheme.primaryGreen,
        size: isMobile ? 24.sp : 24,
      ),
      tooltip: l10n.changeLanguage,
      onSelected: (String locale) {
        settingsProvider.updateLocale(locale);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'fr',
          child: Row(
            children: [
              Text('🇫🇷', style: TextStyle(fontSize: isMobile ? 20.sp : 20)),
              SizedBox(width: isMobile ? 12.w : 12),
              Text(
                l10n.languageFrench,
                style: TextStyle(
                  fontSize: isMobile ? 14.sp : 14,
                  fontWeight: currentLocale == 'fr' ? FontWeight.w600 : FontWeight.normal,
                  color: currentLocale == 'fr' ? AppTheme.primaryGreen : Colors.black87,
                ),
              ),
              if (currentLocale == 'fr') ...[
                const Spacer(),
                Icon(Icons.check, color: AppTheme.primaryGreen, size: isMobile ? 18.sp : 18),
              ],
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              Text('🇬🇧', style: TextStyle(fontSize: isMobile ? 20.sp : 20)),
              SizedBox(width: isMobile ? 12.w : 12),
              Text(
                l10n.languageEnglish,
                style: TextStyle(
                  fontSize: isMobile ? 14.sp : 14,
                  fontWeight: currentLocale == 'en' ? FontWeight.w600 : FontWeight.normal,
                  color: currentLocale == 'en' ? AppTheme.primaryGreen : Colors.black87,
                ),
              ),
              if (currentLocale == 'en') ...[
                const Spacer(),
                Icon(Icons.check, color: AppTheme.primaryGreen, size: isMobile ? 18.sp : 18),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullSelector(
    BuildContext context,
    SettingsProvider settingsProvider,
    String currentLocale,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12.w : 12,
        vertical: isMobile ? 8.h : 8,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(isMobile ? 8.r : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabel) ...[
            Icon(
              Icons.language,
              color: AppTheme.primaryGreen,
              size: isMobile ? 18.sp : 18,
            ),
            SizedBox(width: isMobile ? 8.w : 8),
          ],
          _buildLanguageButton(
            context,
            '🇫🇷',
            'FR',
            'fr',
            currentLocale == 'fr',
            () => settingsProvider.updateLocale('fr'),
            isMobile,
          ),
          SizedBox(width: isMobile ? 8.w : 8),
          Container(
            width: 1,
            height: isMobile ? 20.h : 20,
            color: AppTheme.textGrey.withOpacity(0.3),
          ),
          SizedBox(width: isMobile ? 8.w : 8),
          _buildLanguageButton(
            context,
            '🇬🇧',
            'EN',
            'en',
            currentLocale == 'en',
            () => settingsProvider.updateLocale('en'),
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    String flag,
    String code,
    String locale,
    bool isSelected,
    VoidCallback onTap,
    bool isMobile,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isMobile ? 6.r : 6),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8.w : 8,
          vertical: isMobile ? 4.h : 4,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(isMobile ? 6.r : 6),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: TextStyle(fontSize: isMobile ? 16.sp : 16),
            ),
            SizedBox(width: isMobile ? 4.w : 4),
            Text(
              code,
              style: TextStyle(
                fontSize: isMobile ? 13.sp : 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryGreen : AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}