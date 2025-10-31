import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';

class SettingToggle extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;

  const SettingToggle({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon != null 
          ? Icon(
              icon,
              color: AppTheme.textGrey,
              size: 20,
            )
          : null,
      title: Text(
        label,
        style: TextStyle(
          fontSize: ResponsiveUtils.getFontSize(context, 14),
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null 
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 12),
                color: AppTheme.textGrey,
              ),
            )
          : null,
      trailing: _buildSwitch(context),
      onTap: () => onChanged(!value),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }

  Widget _buildSwitch(BuildContext context) {
    return Transform.scale(
      scale: ResponsiveUtils.isDesktop(context) ? 1.2 : 1.0,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryGreen,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingItem({
    super.key,
    required this.label,
    this.subtitle,
    this.icon,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon != null 
          ? Icon(
              icon,
              color: AppTheme.textGrey,
              size: 20,
            )
          : null,
      title: Text(
        label,
        style: TextStyle(
          fontSize: ResponsiveUtils.getFontSize(context, 14),
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null 
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 12),
                color: AppTheme.textGrey,
              ),
            )
          : null,
      trailing: trailing ?? Icon(
        Icons.chevron_right,
        color: AppTheme.textGrey,
        size: 16,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 8.h,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(children: children),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }
}