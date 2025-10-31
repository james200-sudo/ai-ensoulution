// ============================================================================
// HELPER WEB: Conversion fichiers pour upload PocketBase
// ============================================================================

import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WebFileHelper {
  
  /// Convertir un Blob URL en MultipartFile pour PocketBase
  static Future<http.MultipartFile> blobUrlToMultipartFile({
    required String blobUrl,
    required String fieldName,
    required String filename,
  }) async {
    try {
      // 1. Récupérer le blob
      final response = await html.window.fetch(blobUrl);
      final blob = await response.blob();
      
      // 2. Convertir en bytes
      final reader = html.FileReader();
      reader.readAsArrayBuffer(blob);
      await reader.onLoad.first;
      
      final bytes = reader.result as Uint8List;
      
      // 3. Créer MultipartFile
      return http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: filename,
      );
      
    } catch (e) {
      throw Exception('Erreur conversion blob: $e');
    }
  }
  
  /// Convertir un File HTML en MultipartFile
  static Future<http.MultipartFile> htmlFileToMultipartFile({
    required html.File file,
    required String fieldName,
  }) async {
    try {
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;
      
      final bytes = reader.result as Uint8List;
      
      return http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: file.name,
      );
      
    } catch (e) {
      throw Exception('Erreur conversion file: $e');
    }
  }
}

// ============================================================================
// VERSION COMPLÈTE DE _getMultipartFileFromWeb
// ============================================================================

// À remplacer dans pocketbase_message_saver.dart

Future<http.MultipartFile> _getMultipartFileFromWeb(
  String path, {
  String? filename,
}) async {
  try {
    // Déterminer le type de path
    if (path.startsWith('blob:')) {
      // C'est un Blob URL
      return await WebFileHelper.blobUrlToMultipartFile(
        blobUrl: path,
        fieldName: 'file',
        filename: filename ?? 'audio.m4a',
      );
    } else if (path.startsWith('data:')) {
      // C'est une data URL (base64)
      return _dataUrlToMultipartFile(path, filename ?? 'audio.m4a');
    } else {
      throw Exception('Type de path non supporté sur Web: $path');
    }
  } catch (e) {
    debugPrint('❌ Erreur conversion Web: $e');
    rethrow;
  }
}

/// Convertir data URL en MultipartFile
http.MultipartFile _dataUrlToMultipartFile(String dataUrl, String filename) {
  // Format: data:audio/m4a;base64,XXXXX
  final parts = dataUrl.split(',');
  if (parts.length != 2) {
    throw Exception('Format data URL invalide');
  }
  
  final base64Data = parts[1];
  final bytes = base64Decode(base64Data);
  
  return http.MultipartFile.fromBytes(
    'file',
    bytes,
    filename: filename,
  );
}