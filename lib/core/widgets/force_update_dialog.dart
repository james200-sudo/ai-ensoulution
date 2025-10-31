// lib/core/widgets/force_update_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/app_version_service.dart';
import '../theme/app_theme.dart';

class ForceUpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;
  
  const ForceUpdateDialog({
    super.key,
    required this.updateInfo,
  });
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      // ✅ Remplace WillPopScope - Empêche de fermer le dialogue avec le bouton retour
      canPop: !updateInfo.isUpdateRequired,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(
              updateInfo.isUpdateRequired 
                  ? Icons.system_update_alt 
                  : Icons.notification_important,
              color: updateInfo.isUpdateRequired 
                  ? Colors.red 
                  : Colors.orange,
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                updateInfo.isUpdateRequired
                    ? 'Mise à jour requise'
                    : 'Mise à jour disponible',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              updateInfo.updateMessage ?? 
              'Une nouvelle version de l\'application est disponible.',
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 16.h),
            
            // Informations de version
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  _buildVersionRow(
                    'Version actuelle',
                    updateInfo.currentVersion,
                    Colors.grey.shade600,
                  ),
                  if (updateInfo.latestVersion != null) ...[
                    SizedBox(height: 8.h),
                    _buildVersionRow(
                      'Nouvelle version',
                      updateInfo.latestVersion!,
                      AppTheme.primaryGreen,
                    ),
                  ],
                ],
              ),
            ),
            
            if (updateInfo.isUpdateRequired) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red.shade700,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Cette mise à jour est obligatoire pour continuer à utiliser l\'application.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!updateInfo.isUpdateRequired)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Plus tard',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () => _openStore(),
            style: ElevatedButton.styleFrom(
              backgroundColor: updateInfo.isUpdateRequired 
                  ? Colors.red 
                  : AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 12.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  'Mettre à jour',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVersionRow(String label, String version, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          version,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
  
  /// Ouvre le store approprié (Play Store ou App Store)
  Future<void> _openStore() async {
    String url;
    
    if (kIsWeb) {
      // Sur web, rediriger vers votre site
      url = 'https://hydro-ai-chat.ensolutions.ca'; // ✅ Votre URL PocketBase
    } else if (Platform.isAndroid) {
      // ⚠️ REMPLACER par votre vrai package name Android
      url = 'https://play.google.com/store/apps/details?id=com.ensolutions.tgm_ai_chat';
    } else {
      // ⚠️ REMPLACER par votre vrai App Store ID iOS
      url = 'https://apps.apple.com/app/6754232369';
    }
    
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch store');
      }
    } catch (e) {
      //print('❌ Error opening store: $e');
    }
  }
}