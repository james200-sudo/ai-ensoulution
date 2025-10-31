// ============================================================================
// SAUVEGARDE MESSAGES VOCAUX ET IMAGES DANS POCKETBASE
// Support: iOS, Android, Web
// ============================================================================

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PocketBaseMessageSaver {
  final PocketBase pb;
  
  PocketBaseMessageSaver(this.pb);

  // ========================================================================
  // SAUVEGARDER MESSAGE VOCAL
  // ========================================================================
  
  Future<RecordModel> saveVoiceMessage({
    required String discussionId,
    required String userId,
    required String audioPath,  // Chemin local du fichier
    required int audioDuration,  // En secondes
    String? transcription,
  }) async {
    try {
      final body = <String, dynamic>{
        'discussion': discussionId,
        'user': userId,
        'is_user': true,
        'status': 'sent',
        'audio_duration': audioDuration,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Ajouter transcription si disponible
      if (transcription != null && transcription.isNotEmpty) {
        body['content'] = transcription;
      }

      // ✅ UPLOAD DU FICHIER AUDIO
      if (kIsWeb) {
        // WEB: Utiliser http.MultipartFile depuis bytes
        body['audio_file'] = await _getMultipartFileFromWeb(audioPath);
      } else {
        // MOBILE (iOS/Android): Utiliser http.MultipartFile depuis File
        body['audio_file'] = await http.MultipartFile.fromPath(
          'audio_file',
          audioPath,
        );
      }

      // Créer le record
      final record = await pb.collection('messages').create(body: body);
      
      debugPrint('✅ Message vocal sauvegardé: ${record.id}');
      return record;
      
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde vocal: $e');
      rethrow;
    }
  }

  // ========================================================================
  // SAUVEGARDER MESSAGE AVEC IMAGE
  // ========================================================================
  
  Future<RecordModel> saveImageMessage({
    required String discussionId,
    required String userId,
    required String imagePath,  // Chemin local de l'image
    String? caption,  // Texte accompagnant l'image
  }) async {
    try {
      final body = <String, dynamic>{
        'discussion': discussionId,
        'user': userId,
        'is_user': true,
        'status': 'sent',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Ajouter caption si disponible
      if (caption != null && caption.isNotEmpty) {
        body['content'] = caption;
      }

      // ✅ UPLOAD DU FICHIER IMAGE
      if (kIsWeb) {
        // WEB: Utiliser http.MultipartFile depuis bytes
        body['image_file'] = await _getMultipartFileFromWeb(imagePath);
      } else {
        // MOBILE (iOS/Android): Utiliser http.MultipartFile depuis File
        body['image_file'] = await http.MultipartFile.fromPath(
          'image_file',
          imagePath,
        );
      }

      // Créer le record
      final record = await pb.collection('messages').create(body: body);
      
      debugPrint('✅ Message image sauvegardé: ${record.id}');
      return record;
      
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde image: $e');
      rethrow;
    }
  }

  // ========================================================================
  // SAUVEGARDER MESSAGE TEXTE SIMPLE
  // ========================================================================
  
  Future<RecordModel> saveTextMessage({
    required String discussionId,
    required String userId,
    required String content,
    bool isUser = true,
  }) async {
    try {
      final body = <String, dynamic>{
        'discussion': discussionId,
        'user': userId,
        'content': content,
        'is_user': isUser,
        'status': 'sent',
        'timestamp': DateTime.now().toIso8601String(),
      };

      final record = await pb.collection('messages').create(body: body);
      
      debugPrint('✅ Message texte sauvegardé: ${record.id}');
      return record;
      
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde texte: $e');
      rethrow;
    }
  }

  // ========================================================================
  // HELPER: Conversion fichier pour WEB
  // ========================================================================
  Future<http.MultipartFile> _getMultipartFileFromWeb(String path) async {
    if (!kIsWeb) {
      throw Exception('_getMultipartFileFromWeb should only be used on Web');
    }

    try {
      // Récupérer les bytes depuis l'URL blob
      final response = await http.get(Uri.parse(path));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch file data: ${response.statusCode}');
      }

      final bytes = response.bodyBytes;
      
      // Déterminer l'extension et le type MIME du fichier
      String filename = 'file_${DateTime.now().millisecondsSinceEpoch}';
      String mimeType = 'application/octet-stream';
      final lower = path.toLowerCase();

      if (lower.contains('.wav')) {
        filename += '.wav';
        mimeType = 'audio/wav';
      } else if (lower.contains('.mp3')) {
        filename += '.mp3';
        mimeType = 'audio/mpeg';
      } else if (lower.contains('.m4a')) {
        filename += '.m4a';
        mimeType = 'audio/mp4';
      } else if (lower.contains('.webm')) {
        filename += '.webm';
        mimeType = 'audio/webm';
      } else if (lower.contains('.jpg') || lower.contains('.jpeg')) {
        filename += '.jpg';
        mimeType = 'image/jpeg';
      } else if (lower.contains('.png')) {
        filename += '.png';
        mimeType = 'image/png';
      } else if (lower.contains('.webp')) {
        filename += '.webp';
        mimeType = 'image/webp';
      } else if (lower.contains('.gif')) {
        filename += '.gif';
        mimeType = 'image/gif';
      } else {
        // fallback: leave filename without extension and use octet-stream
      }

      // Choisir le nom du champ selon le type détecté
      final fieldName = mimeType.startsWith('image/') ? 'image_file' : 'audio_file';

      return http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      );
    } catch (e) {
      debugPrint('Erreur récupération fichier Web: $e');
      rethrow;
    }
  }
  // ========================================================================
  // RÉCUPÉRER L'URL DU FICHIER AUDIO/IMAGE
  // ========================================================================
  
  Object getFileUrl(RecordModel record, String fieldName) {
    // Exemple: fieldName = 'audio_file' ou 'image_file'
    final filename = record.data[fieldName];
    if (filename == null || filename.isEmpty) return '';
    
    return pb.files.getUrl(record, filename);
  }

  // ========================================================================
  // EXEMPLE D'UTILISATION
  // ========================================================================
}

// ============================================================================
// USAGE DANS VOTRE CHAT_PROVIDER
// ============================================================================

/*

// 1. Initialiser
final messageSaver = PocketBaseMessageSaver(pb);

// 2. Sauvegarder un message vocal
try {
  final record = await messageSaver.saveVoiceMessage(
    discussionId: currentDiscussionId,
    userId: currentUserId,
    audioPath: '/path/to/recording.m4a',
    audioDuration: 45,
    transcription: 'Transcription du message',
  );
  
  // Récupérer l'URL du fichier audio
  final audioUrl = messageSaver.getFileUrl(record, 'audio_file');
  print('Audio URL: $audioUrl');
  
} catch (e) {
  print('Erreur: $e');
}

// 3. Sauvegarder un message avec image
try {
  final record = await messageSaver.saveImageMessage(
    discussionId: currentDiscussionId,
    userId: currentUserId,
    imagePath: '/path/to/image.jpg',
    caption: 'Regardez cette image!',
  );
  
  // Récupérer l'URL de l'image
  final imageUrl = messageSaver.getFileUrl(record, 'image_file');
  print('Image URL: $imageUrl');
  
} catch (e) {
  print('Erreur: $e');
}

*/

// ============================================================================
// STRUCTURE POCKETBASE REQUISE POUR COLLECTION "messages"
// ============================================================================

/*

Champs nécessaires:

1. discussion (Relation) → conversations
2. user (Relation) → users
3. content (Text) - optionnel
4. is_user (Bool)
5. status (Select: sent, sending, failed, streaming)
6. audio_file (File) ⭐ IMPORTANT
   - Types MIME: audio/mpeg, audio/mp3, audio/wav, audio/m4a, audio/webm
   - Max size: 10MB
7. audio_duration (Number)
8. image_file (File) ⭐ IMPORTANT
   - Types MIME: image/jpeg, image/png, image/webp
   - Max size: 5MB
9. timestamp (Date)

*/

// ============================================================================
// INTÉGRATION DANS CHAT_PROVIDER
// ============================================================================

/*

class ChatProvider extends ChangeNotifier {
  final PocketBaseMessageSaver _messageSaver;
  
  // Dans sendAudioMessage():
  Future<void> sendAudioMessage(
    String audioPath, {
    required int duration,
    String? transcription,
    required BuildContext context,
  }) async {
    
    // 1. Créer message local
    final userMessage = Message(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      content: transcription ?? '',
      isUser: true,
      timestamp: DateTime.now(),
      audioUrl: audioPath,
      audioDuration: duration,
      status: MessageStatus.sending,
    );
    
    _messages.add(userMessage);
    notifyListeners();
    
    // 2. Sauvegarder dans PocketBase
    try {
      final record = await _messageSaver.saveVoiceMessage(
        discussionId: _currentConversationId!,
        userId: _currentUserId!,
        audioPath: audioPath,
        audioDuration: duration,
        transcription: transcription,
      );
      
      // 3. Mettre à jour avec l'ID réel
      final index = _messages.indexWhere((m) => m.id == userMessage.id);
      if (index != -1) {
        _messages[index] = userMessage.copyWith(
          id: record.id,
          status: MessageStatus.sent,
          audioUrl: _messageSaver.getFileUrl(record, 'audio_file'),
        );
      }
      
      notifyListeners();
      
    } catch (e) {
      // Marquer comme failed
      final index = _messages.indexWhere((m) => m.id == userMessage.id);
      if (index != -1) {
        _messages[index] = userMessage.copyWith(
          status: MessageStatus.failed,
        );
      }
      notifyListeners();
    }
    
    // 4. Continuer avec la réponse AI...
  }
}

*/