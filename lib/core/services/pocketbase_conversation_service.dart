import 'package:pocketbase/pocketbase.dart';
import 'package:flutter/foundation.dart';

import '../../features/chat/models/conversation.dart';
import '../../features/chat/models/message.dart';
import 'pocketbase_auth_service.dart';


class PocketBaseConversationService {
  static const String _discussionsCollection = 'discussions';
  static const String _messagesCollection = 'messages';
  
  final PocketBaseAuthService _authService = PocketBaseAuthService();
  
  // Getter pour l'instance PocketBase
  PocketBase get _pb => _authService.pocketBase;

  /// Sauvegarder une nouvelle discussion
  Future<String?> saveConversation(Conversation conversation) async {
    try {
      if (!_authService.isLoggedIn) {
        //debugPrint('Utilisateur non connecté');
        return null;
      }

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        debugPrint('Données utilisateur non disponibles');
        return null;
      }

      final data = {
        // PocketBase génère automatiquement l'ID
        'title': conversation.title,
        'user': currentUser['id'],
        'last_message_at': conversation.lastMessageAt.toIso8601String(),
        'ragflow_session_id': conversation.ragflowSessionId,
        'message_count': conversation.messages.length,
        'is_archived': false,
      };

      final record = await _pb.collection(_discussionsCollection).create(body: data);
      
      //debugPrint('✅ Discussion sauvegardée: ${record.id}');
      return record.id;
      
    } catch (e) {
      //debugPrint('❌ Exception sauvegarde discussion: $e');
      return null;
    }
  }

  /// Mettre à jour une discussion existante
  Future<bool> updateConversation(Conversation conversation) async {
    try {
      if (!_authService.isLoggedIn) {
        //debugPrint('Utilisateur non connecté');
        return false;
      }

      final data = {
        'title': conversation.title,
        'last_message_at': conversation.lastMessageAt.toIso8601String(),
        'ragflow_session_id': conversation.ragflowSessionId,
        'message_count': conversation.messages.length,
      };

      await _pb.collection(_discussionsCollection).update(conversation.id, body: data);
      
      //debugPrint('✅ Discussion mise à jour: ${conversation.id}');
      return true;
      
    } catch (e) {
      //debugPrint('❌ Exception mise à jour discussion: $e');
      return false;
    }
  }

  /// Sauvegarder un message
  Future<String?> saveMessage(Message message, String discussionId) async {
    try {
      if (!_authService.isLoggedIn) {
        //debugPrint('Utilisateur non connecté');
        return null;
      }

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        //debugPrint('Données utilisateur non disponibles');
        return null;
      }

      final data = {
        // PocketBase génère automatiquement l'ID
        'content': message.content,
        'user': currentUser['id'],
        'discussion': discussionId,
        'is_user': message.isUser,
        'status': message.status.name,
        'timestamp': message.timestamp.toIso8601String(),
        'image_url': message.imageUrl,
        'image_data': message.imageData,
        'audio_url': message.audioUrl,
        'audio_duration': message.audioDuration,
      };

      final record = await _pb.collection(_messagesCollection).create(body: data);
      
      //debugPrint('✅ Message sauvegardé: ${record.id}');
      
      // Mettre à jour le compteur de messages de la discussion
      await _updateMessageCount(discussionId);
      
      return record.id;
      
    } catch (e) {
      //debugPrint('❌ Exception sauvegarde message: $e');
      return null;
    }
  }

  /// Mettre à jour le compteur de messages d'une discussion
  Future<void> _updateMessageCount(String discussionId) async {
    try {
      // Compter les messages de cette discussion
      final resultList = await _pb.collection(_messagesCollection).getList(
        filter: 'discussion="$discussionId"',
        perPage: 1, // On veut juste le total
      );

      final messageCount = resultList.totalItems;

      // Mettre à jour la discussion avec le nouveau nombre
      await _pb.collection(_discussionsCollection).update(discussionId, body: {
        'message_count': messageCount,
        'last_message_at': DateTime.now().toIso8601String(),
      });
      
    } catch (e) {
      //debugPrint('Erreur mise à jour compteur: $e');
    }
  }

  /// Mettre à jour le statut d'un message
  Future<bool> updateMessageStatus(String messageId, MessageStatus status) async {
    try {
      if (!_authService.isLoggedIn) return false;

      await _pb.collection(_messagesCollection).update(messageId, body: {
        'status': status.name,
      });

      //debugPrint('✅ Statut message mis à jour: $messageId');
      return true;
      
    } catch (e) {
      //debugPrint('❌ Exception mise à jour statut: $e');
      return false;
    }
  }

  /// Mettre à jour le contenu d'un message (pour le streaming)
  Future<bool> updateMessageContent(String messageId, String content) async {
    try {
      if (!_authService.isLoggedIn) return false;

      await _pb.collection(_messagesCollection).update(messageId, body: {
        'content': content,
      });

      return true;
      
    } catch (e) {
      //debugPrint('❌ Exception mise à jour contenu: $e');
      return false;
    }
  }


  /// Charger les discussions de l'utilisateur
  Future<List<Conversation>> loadUserConversations() async {
    try {
      if (!_authService.isLoggedIn) {
        //debugPrint('Utilisateur non connecté');
        return [];
      }

      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        //debugPrint('Données utilisateur non disponibles');
        return [];
      }

      final resultList = await _pb.collection(_discussionsCollection).getList(
        filter: 'user="${currentUser['id']}" && is_archived!=true',
        sort: '-last_message_at',
        perPage: 100,
      );

      List<Conversation> conversations = [];
      
      for (final record in resultList.items) {
        // Charger les messages pour chaque discussion
        final messages = await loadConversationMessages(record.id);
        
        final conversation = Conversation(
          id: record.id,
          title: record.data['title'] ?? 'Discussion sans titre',
          createdAt: DateTime.parse(record.created),
          lastMessageAt: DateTime.parse(record.data['last_message_at']),
          messages: messages,
          ragflowSessionId: record.data['ragflow_session_id'],
        );
        
        conversations.add(conversation);
      }
      
      //debugPrint('✅ ${conversations.length} discussions chargées depuis PocketBase');
      return conversations;
      
    } catch (e) {
      //debugPrint('❌ Exception chargement discussions: $e');
      return [];
    }
  }

  /// Charger les messages d'une discussion
  Future<List<Message>> loadConversationMessages(String discussionId) async {
    try {
      if (!_authService.isLoggedIn) {
        //debugPrint('❌ Utilisateur non connecté - impossible de charger les messages');
        return [];
      }

      // ✅ CORRECTION : Vérifier que la discussion existe d'abord
      try {
        await _pb.collection(_discussionsCollection).getOne(discussionId);
      } catch (e) {
        //debugPrint('❌ Discussion $discussionId introuvable dans PocketBase');
        return [];
      }

      // ✅ CORRECTION : Ajouter gestion d'erreur robuste
      final resultList = await _pb.collection(_messagesCollection).getList(
        filter: 'discussion="$discussionId"',
        sort: 'timestamp',
        perPage: 500,
      );

      if (resultList.items.isEmpty) {
        //debugPrint('⚠️ Aucun message trouvé pour discussion $discussionId');
        return [];
      }

      final messages = resultList.items.map((record) {
        try {
          final data = record.data;
          
          return Message(
            id: record.id, // ✅ IMPORTANT : Utiliser l'ID PocketBase
            content: data['content'] ?? '',
            isUser: data['is_user'] ?? false,
            timestamp: DateTime.parse(data['timestamp']),
            status: MessageStatus.values.firstWhere(
              (e) => e.name == data['status'],
              orElse: () => MessageStatus.sent,
            ),
            imageUrl: data['image_url'],
            imageData: data['image_data'],
            audioUrl: data['audio_url']?.toString(),
            audioDuration: data['audio_duration']?.toInt(),
          );
        } catch (e) {
          //debugPrint('❌ Erreur conversion message ${record.id}: $e');
          return null;
        }
      }).whereType<Message>().toList(); // ✅ Filtrer les nulls

      //debugPrint('✅ ${messages.length} messages chargés pour discussion $discussionId');
      return messages;
        
    } catch (e) {
      //debugPrint('❌ Exception chargement messages: $e');
      return [];
    }
  }

  /// Supprimer une discussion
  Future<bool> deleteConversation(String discussionId) async {
    try {
      if (!_authService.isLoggedIn) return false;

      // Supprimer d'abord tous les messages de la discussion
      final messagesList = await _pb.collection(_messagesCollection).getList(
        filter: 'discussion="$discussionId"',
        perPage: 500,
      );

      // Supprimer chaque message
      for (final message in messagesList.items) {
        try {
          await _pb.collection(_messagesCollection).delete(message.id);
        } catch (e) {
          //debugPrint('Erreur suppression message ${message.id}: $e');
        }
      }

      // Puis supprimer la discussion
      await _pb.collection(_discussionsCollection).delete(discussionId);

      //debugPrint('✅ Discussion supprimée: $discussionId');
      return true;
      
    } catch (e) {
      //debugPrint('❌ Exception suppression discussion: $e');
      return false;
    }
  }

  /// Archiver une discussion au lieu de la supprimer
  Future<bool> archiveConversation(String discussionId) async {
    try {
      if (!_authService.isLoggedIn) return false;

      await _pb.collection(_discussionsCollection).update(discussionId, body: {
        'is_archived': true,
      });

      //debugPrint('✅ Discussion archivée: $discussionId');
      return true;
      
    } catch (e) {
      //debugPrint('❌ Exception archivage discussion: $e');
      return false;
    }
  }

  /// Restaurer une discussion archivée
  Future<bool> restoreConversation(String discussionId) async {
    try {
      if (!_authService.isLoggedIn) return false;

      await _pb.collection(_discussionsCollection).update(discussionId, body: {
        'is_archived': false,
      });

      //debugPrint('✅ Discussion restaurée: $discussionId');
      return true;
      
    } catch (e) {
      //debugPrint('❌ Exception restauration discussion: $e');
      return false;
    }
  }

  /// Charger les discussions archivées
  Future<List<Conversation>> loadArchivedConversations() async {
    try {
      if (!_authService.isLoggedIn) return [];

      final currentUser = _authService.currentUser;
      if (currentUser == null) return [];

      final resultList = await _pb.collection(_discussionsCollection).getList(
        filter: 'user="${currentUser['id']}" && is_archived=true',
        sort: '-last_message_at',
        perPage: 100,
      );

      List<Conversation> conversations = [];
      
      for (final record in resultList.items) {
        final messages = await loadConversationMessages(record.id);
        
        final conversation = Conversation(
          id: record.id,
          title: record.data['title'] ?? 'Discussion archivée',
          createdAt: DateTime.parse(record.created),
          lastMessageAt: DateTime.parse(record.data['last_message_at']),
          messages: messages,
          ragflowSessionId: record.data['ragflow_session_id'],
        );
        
        conversations.add(conversation);
      }
      
      //debugPrint('✅ ${conversations.length} discussions archivées chargées');
      return conversations;
      
    } catch (e) {
      //debugPrint('❌ Exception chargement discussions archivées: $e');
      return [];
    }
  }

  /// Vérifier si l'utilisateur est un utilisateur individuel (PocketBase)
  bool isIndividualUser() {
    return _authService.isLoggedIn && _authService.currentUser != null;
  }

  /// Rechercher dans les discussions
  Future<List<Conversation>> searchConversations(String query) async {
    try {
      if (!_authService.isLoggedIn) return [];
      if (query.trim().isEmpty) return [];

      final currentUser = _authService.currentUser;
      if (currentUser == null) return [];

      final resultList = await _pb.collection(_discussionsCollection).getList(
        filter: 'user="${currentUser['id']}" && title~"$query"',
        sort: '-last_message_at',
        perPage: 50,
      );

      List<Conversation> conversations = [];
      
      for (final record in resultList.items) {
        final messages = await loadConversationMessages(record.id);
        
        final conversation = Conversation(
          id: record.id,
          title: record.data['title'] ?? 'Discussion',
          createdAt: DateTime.parse(record.created),
          lastMessageAt: DateTime.parse(record.data['last_message_at']),
          messages: messages,
          ragflowSessionId: record.data['ragflow_session_id'],
        );
        
        conversations.add(conversation);
      }
      
      //debugPrint('✅ ${conversations.length} discussions trouvées pour "$query"');
      return conversations;
      
    } catch (e) {
      //debugPrint('❌ Exception recherche discussions: $e');
      return [];
    }
  }

  /// Obtenir les statistiques utilisateur
  Future<Map<String, int>> getUserStats() async {
    try {
      if (!_authService.isLoggedIn) return {};

      final currentUser = _authService.currentUser;
      if (currentUser == null) return {};

      // Compter les discussions
      final discussionsList = await _pb.collection(_discussionsCollection).getList(
        filter: 'user="${currentUser['id']}"',
        perPage: 1,
      );

      // Compter les messages
      final messagesList = await _pb.collection(_messagesCollection).getList(
        filter: 'user="${currentUser['id']}"',
        perPage: 1,
      );

      return {
        'discussions': discussionsList.totalItems,
        'messages': messagesList.totalItems,
      };
      
    } catch (e) {
      //debugPrint('❌ Exception stats utilisateur: $e');
      return {};
    }
  }
}