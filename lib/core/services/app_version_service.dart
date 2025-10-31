// lib/core/services/app_version_service.dart
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppVersionService {
  static const String pocketbaseUrl = 'https://hydro-ai-chat.ensolutions.ca';
  
  /// Vérifie si une mise à jour est nécessaire
  Future<UpdateInfo> checkForUpdate() async {
    try {
      // 1. Récupérer la version actuelle de l'app
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      // 2. Déterminer la plateforme (avec support web)
      String platform;
      if (kIsWeb) {
        platform = 'all'; // Sur web, on utilise 'all'
      } else {
        platform = Platform.isAndroid ? 'android' : 'ios';
      }
      
      final response = await http.get(
        Uri.parse('$pocketbaseUrl/api/collections/app_config/records'),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch app config');
      }
      
      final data = jsonDecode(response.body);
      final records = data['items'] as List;
      
      if (records.isEmpty) {
        return UpdateInfo(
          isUpdateRequired: false,
          isUpdateAvailable: false,
          currentVersion: currentVersion,
        );
      }
      
      // Trouver la config pour la plateforme actuelle ou "all"
      final config = records.firstWhere(
        (record) => record['platform'] == platform || record['platform'] == 'all',
        orElse: () => records.first,
      );
      
      final minimumVersion = config['minimumVersion'] as String;
      final latestVersion = config['latestVersion'] as String;
      final forceUpdate = config['forceUpdate'] as bool? ?? false;
      final updateMessage = config['updateMessage'] as String? ?? 
          'Une nouvelle version est disponible.';
      
      // 3. Comparer les versions
      final isUpdateRequired = _isVersionLower(currentVersion, minimumVersion);
      final isUpdateAvailable = _isVersionLower(currentVersion, latestVersion);
      
      return UpdateInfo(
        isUpdateRequired: forceUpdate && isUpdateRequired,
        isUpdateAvailable: isUpdateAvailable,
        currentVersion: currentVersion,
        minimumVersion: minimumVersion,
        latestVersion: latestVersion,
        updateMessage: updateMessage,
      );
      
    } catch (e) {
      print('Error checking for update: $e');
      return UpdateInfo(
        isUpdateRequired: false,
        isUpdateAvailable: false,
        currentVersion: '0.0.0',
      );
    }
  }
  
  /// Compare deux versions (format: "1.2.3")
  bool _isVersionLower(String current, String minimum) {
    final currentParts = current.split('.').map(int.parse).toList();
    final minimumParts = minimum.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      final minimumPart = i < minimumParts.length ? minimumParts[i] : 0;
      
      if (currentPart < minimumPart) return true;
      if (currentPart > minimumPart) return false;
    }
    
    return false; // Les versions sont égales
  }
}

/// Informations sur la mise à jour
class UpdateInfo {
  final bool isUpdateRequired; // Mise à jour obligatoire (bloque l'app)
  final bool isUpdateAvailable; // Mise à jour disponible (optionnelle)
  final String currentVersion;
  final String? minimumVersion;
  final String? latestVersion;
  final String? updateMessage;
  
  UpdateInfo({
    required this.isUpdateRequired,
    required this.isUpdateAvailable,
    required this.currentVersion,
    this.minimumVersion,
    this.latestVersion,
    this.updateMessage,
  });
  
  @override
  String toString() {
    return 'UpdateInfo(isUpdateRequired: $isUpdateRequired, '
           'isUpdateAvailable: $isUpdateAvailable, '
           'currentVersion: $currentVersion, '
           'latestVersion: $latestVersion)';
  }
}