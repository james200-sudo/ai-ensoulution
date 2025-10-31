import 'dart:async';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/ragflow_service.dart';
import '../../../core/services/pocketbase_conversation_service.dart';
import 'package:tgm_ai_chat/core/services/message_counter_service.dart';
import 'package:tgm_ai_chat/core/services/plan_enforcement_service.dart';
import 'package:tgm_ai_chat/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:tgm_ai_chat/core/services/pocketbase_auth_service.dart';
import 'package:tgm_ai_chat/core/services/pocketbase_message_saver.dart';
import 'package:tgm_ai_chat/core/services/auth_session_manager.dart';

class ChatProvider extends ChangeNotifier {
  final PlanEnforcementService _planService = PlanEnforcementService();
  final List<Message> _messages = [];
  bool _isTyping = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAppInFocus = true;
  bool _isInitialized = false;
  bool _isLoadingMessages = true;
  bool _wasManuallyCleared = false;
  late final PocketBaseMessageSaver _messageSaver;
  final MessageCounterService _messageCounterService = MessageCounterService();
  static const String _messagesKey = 'chat_messages';
  static const String _conversationsKey = 'saved_conversations';
  static const String _currentConversationKey = 'current_conversation_id';

  String? _currentConversationId;
  final Map<String, Conversation> _savedConversations = {};

  // INTÉGRATION POCKETBASE
  final PocketBaseConversationService _pocketBaseService = PocketBaseConversationService();
  bool _isPocketBaseUser = false;
  final AuthSessionManager _sessionManager = AuthSessionManager();

  // ✅ PROPRIÉTÉS POUR LA SYNCHRONISATION
  Timer? _syncTimer;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  
  // ✅ NOUVEAU: Mapping des IDs locaux vers IDs PocketBase
  final Map<String, String> _localToPocketBaseIds = {};
  
  // ✅ NOUVEAU: File d'attente de synchronisation
  final List<Message> _syncQueue = [];

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  bool get isLoadingMessages => _isLoadingMessages;
  String? get currentConversationId => _currentConversationId;
  Map<String, Conversation> get savedConversations => Map.unmodifiable(_savedConversations);
  bool get isPocketBaseUser => _isPocketBaseUser;
  final Map<String, String> _messageBuffers = {};
  final Map<String, String> _displayedContent = {};
  final Map<String, Timer?> _typewriterTimers = {};
  static const int _typewriterSpeed = 30;
  void setAppFocus(bool inFocus) {
    _isAppInFocus = inFocus;
  }
  // 🆕 MÉTHODE: Valider la session avant toute action
  Future<bool> _validateSession(BuildContext context) async {
    // Vérifier si l'utilisateur est connecté
    if (!_isPocketBaseUser) {
      return true; // Les utilisateurs company utilisent Strapi (système différent)
    }

    // Valider le token
    final isValid = await _sessionManager.validateTokenBeforeAction();
    
    if (!isValid) {
      // Session expirée - nettoyer et rediriger
      debugPrint('🔴 Session expirée - Nettoyage et redirection vers login');
      
      // Nettoyer les données locales
      await clearAllLocalData();
      
      if (context.mounted) {
        // Afficher un message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Votre session a expiré. Veuillez vous reconnecter.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Rediriger vers login
        context.go('/login');
      }
      
      return false;
    }
    
    return true;
  }
  // 🆕 MÉTHODE: Nettoyer TOUTES les données locales à la déconnexion
  Future<void> clearAllLocalData() async {
    try {
      debugPrint('🧹 Nettoyage complet des données locales...');
      
      // 1. Nettoyer les messages et conversations en mémoire
      _messages.clear();
      _savedConversations.clear();
      _currentConversationId = null;
      
      // 2. Nettoyer SharedPreferences (sauf les credentials pour pré-remplissage)
      final prefs = await SharedPreferences.getInstance();
      
      // Sauvegarder temporairement les infos de login
      final lastEmail = prefs.getString('last_email');
      final lastUserType = prefs.getString('last_user_type');
      
      // Supprimer toutes les clés liées au chat
      await prefs.remove(_messagesKey);
      await prefs.remove(_conversationsKey);
      await prefs.remove(_currentConversationKey);
      await prefs.remove('messageCount');
      
      // Restaurer les infos de login pour le pré-remplissage
      if (lastEmail != null) {
        await prefs.setString('last_email', lastEmail);
      }
      if (lastUserType != null) {
        await prefs.setString('last_user_type', lastUserType);
      }
      
      // 3. Réinitialiser les états
      _isInitialized = false;
      _isLoadingMessages = false;
      _isPocketBaseUser = false;
      
      notifyListeners();
      
      debugPrint('✅ Données locales nettoyées avec succès');
    } catch (e) {
      debugPrint('❌ Erreur lors du nettoyage des données: $e');
    }
  }
  ChatProvider() {
     // 🆕 AJOUTER cette ligne :
  final authService = PocketBaseAuthService();
  _messageSaver = PocketBaseMessageSaver(authService.pocketBase);
  
    _initializeProvider();
  }
  

  Future<void> _initializeProvider() async {
    try {
      // Déterminer le type d'utilisateur
      _isPocketBaseUser = _pocketBaseService.isIndividualUser();
      //debugPrint('Type utilisateur détecté: ${_isPocketBaseUser ? "PocketBase (Individuel)" : "Strapi (Entreprise)"}');

      if (_isPocketBaseUser) {
        // Charger depuis PocketBase pour les utilisateurs individuels
        await _loadConversationsFromPocketBase();
      } else {
        // Charger depuis le système local pour les utilisateurs entreprise
        await _loadMessages();
        await _loadSavedConversations();
      }
    } catch (e) {
      //debugPrint('Erreur initialisation provider: $e');
      // Solution de secours vers le système local en cas d'erreur
      await _loadMessages();
      await _loadSavedConversations();
    }
  }

  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      

      // Vérifier le type d'utilisateur
      _isPocketBaseUser = _pocketBaseService.isIndividualUser();
      //debugPrint('Initialize - Type utilisateur: ${_isPocketBaseUser ? "PocketBase" : "Strapi"}');

      if (_isPocketBaseUser) {
        // Charger les conversations depuis PocketBase
        await _loadConversationsFromPocketBase();
      } else {
        // Utiliser le système local existant pour les utilisateurs entreprise
        if (!_isInitialized) {
          await _loadMessages();
          await _loadSavedConversations();
        }
      }

      // S'assurer que nous avons un ID de conversation courant d'au moins 15 caractères
      if (_currentConversationId == null) {
        _currentConversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
        if (_isPocketBaseUser) {
          await _createNewPocketBaseConversation();
        } else {
          await _saveConversations();
        }
      } else if (_currentConversationId!.length < 15) {
        // Corriger les ID courts existants
        _currentConversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
        if (_isPocketBaseUser) {
          await _createNewPocketBaseConversation();
        } else {
          await _saveConversations();
        }
      }
      
    if (_isPocketBaseUser) {
        final authService = PocketBaseAuthService();
        final userId = authService.currentUser?['id'];
        
        if (userId != null) {
          final planService = PlanEnforcementService();
          await planService.forceSyncMessageCount(userId);
        }
      }
      _isInitialized = true;
    } catch (e) {
      //debugPrint('Erreur initialisation ChatProvider: $e');
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  // NOUVELLES MÉTHODES POCKETBASE
  Future<void> _loadConversationsFromPocketBase() async {
    try {
      _isLoadingMessages = true;
      notifyListeners();

      final conversations = await _pocketBaseService.loadUserConversations();
      
      _savedConversations.clear();
      for (final conversation in conversations) {
        _savedConversations[conversation.id] = conversation;
      }

      // Charger la conversation courante si elle existe
      if (conversations.isNotEmpty) {
        final currentConv = conversations.first;
        _currentConversationId = currentConv.id;
        _messages.clear();
        _messages.addAll(currentConv.messages);
      }

      //debugPrint('${conversations.length} conversations chargées depuis PocketBase');
    } catch (e) {
      //debugPrint('Erreur chargement PocketBase: $e');
      // Solution de secours vers système local en cas d'erreur
      _isPocketBaseUser = false;
      await _loadMessages();
      await _loadSavedConversations();
    }
  }

  Future<void> _createNewPocketBaseConversation() async {
    if (!_isPocketBaseUser || _currentConversationId == null) return;

    try {
      final conversation = Conversation(
        id: _currentConversationId!, // ID temporaire local
        title: 'Nouvelle Conversation',
        createdAt: DateTime.now(),
        lastMessageAt: DateTime.now(),
        messages: [],
      );

      // Sauvegarder et récupérer l'ID généré par PocketBase
      final pocketBaseId = await _pocketBaseService.saveConversation(conversation);
      
      if (pocketBaseId != null) {
        // ✅ CORRECTION: Mapper l'ID au lieu de le remplacer
        final oldId = _currentConversationId;
        _localToPocketBaseIds[oldId!] = pocketBaseId;
        _currentConversationId = pocketBaseId;
        
        // Mettre à jour dans la map
        if (_savedConversations.containsKey(oldId)) {
          _savedConversations.remove(oldId);
        }
        _savedConversations[pocketBaseId] = conversation.copyWith(id: pocketBaseId);
        
        //debugPrint('✅ Conversation créée: $pocketBaseId (ID PocketBase)');
      } else {
        //debugPrint('❌ Échec création conversation - ID null');
      }
      
    } catch (e) {
      //debugPrint('❌ Erreur création conversation PocketBase: $e');
    }
  }

  // ✅ CORRECTION: Ne jamais modifier l'ID, utiliser le mapping
  Future<String?> _saveMessageToPocketBase(Message message) async {
    if (!_isPocketBaseUser || _currentConversationId == null) return null;

    try {
      // Sauvegarder et récupérer l'ID généré par PocketBase
      final pocketBaseId = await _pocketBaseService.saveMessage(message, _currentConversationId!);
      
      if (pocketBaseId != null) {
        // ✅ MAPPING au lieu de modification
        _localToPocketBaseIds[message.id] = pocketBaseId;
        //debugPrint('✅ Message mappé: ${message.id} → $pocketBaseId');
        return pocketBaseId;
      }
      
      return null;
    } catch (e) {
      //debugPrint('❌ Erreur sauvegarde message PocketBase: $e');
      // ✅ Ajouter à la file d'attente pour retry
      if (!_syncQueue.any((m) => m.id == message.id)) {
        _syncQueue.add(message);
      }
      return null;
    }
  }

  Future<void> _updateMessageStatusInPocketBase(String messageId, MessageStatus status) async {
    if (!_isPocketBaseUser) return;

    try {
      // ✅ Utiliser l'ID PocketBase si disponible
      final pocketBaseId = _localToPocketBaseIds[messageId] ?? messageId;
      await _pocketBaseService.updateMessageStatus(pocketBaseId, status);
    } catch (e) {
      //debugPrint('❌ Erreur mise à jour statut PocketBase: $e');
    }
  }

  Future<void> _saveCurrentConversationToPocketBase() async {
    if (!_isPocketBaseUser || _messages.isEmpty || _currentConversationId == null) return;

    try {
      final now = DateTime.now();
      final conversation = Conversation(
        id: _currentConversationId!,
        title: Conversation.generateTitle(_messages),
        createdAt: _savedConversations[_currentConversationId!]?.createdAt ?? now,
        lastMessageAt: now,
        messages: List.from(_messages),
        ragflowSessionId: _getCurrentConversationSessionId(),
      );

      if (_savedConversations.containsKey(_currentConversationId!)) {
        await _pocketBaseService.updateConversation(conversation);
      } else {
        await _pocketBaseService.saveConversation(conversation);
      }

      _savedConversations[_currentConversationId!] = conversation;
    } catch (e) {
      //debugPrint('Erreur sauvegarde conversation PocketBase: $e');
    }
  }

  Future<void> sendMessage(
    String content, {
    XFile? imageXFile,
    required BuildContext context,
  }) async {
    // 🆕 VALIDATION DE SESSION
    final isSessionValid = await _validateSession(context ?? BuildContext as BuildContext);
    if (!isSessionValid) {
      debugPrint('❌ Session invalide - Message non envoyé');
      return;
    } 

    if (content.trim().isEmpty && imageXFile == null) return;

    // ======================================
    // VÉRIFICATION DU PLAN D'ABONNEMENT
    // ======================================
    
    // Récupérer l'ID utilisateur actuel
    final authService = PocketBaseAuthService();
    final userId = authService.currentUser?['id'];
    
    // Vérifier si l'utilisateur peut envoyer un message
    if (_isPocketBaseUser && userId != null) {
      final checkResult = await _planService.canSendMessage(userId);
      if (!checkResult.isAllowed) {
        if (context != null && context.mounted) {
          _showPlanError(context, checkResult.errorMessage ?? 'Limite de messages atteinte');
          
          if (checkResult.requiresUpgrade) {
            _showUpgradeDialog(context);
          }
        }
        return;
      }
      
      // Vérifier les permissions pour l'image si présente
      if (imageXFile != null) {
        final imageBytes = await imageXFile.readAsBytes();
        final imageCheck = await _planService.canUploadImage(userId, imageBytes.length);
        
        if (!imageCheck.isAllowed) {
          if (context != null && context.mounted) {
            _showPlanError(context, imageCheck.errorMessage ?? 'Téléchargement d\'image non autorisé');
            
            if (imageCheck.requiresUpgrade) {
              _showUpgradeDialog(context);
            }
          }
          return;
        }
      }
      
      // Afficher avertissement si proche de la limite
      if (checkResult.remainingQuota != null && checkResult.remainingQuota! < 10) {
        if (context != null && context.mounted) {
          _showQuotaWarning(context, checkResult.remainingQuota!);
        }
      }
    }
    
    // ======================================
    // CRÉATION/VÉRIFICATION DE LA CONVERSATION
    // ======================================

    if (_isPocketBaseUser) {
      if (_currentConversationId == null || _currentConversationId!.length < 15) {
        _currentConversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';
      }
      
      if (!_savedConversations.containsKey(_currentConversationId!)) {
        await _createNewPocketBaseConversation();
      }
    }

    // ======================================
    // TRAITEMENT DE L'IMAGE
    // ======================================

    String? imageData;
    if (imageXFile != null && kIsWeb) {
      imageData = await _convertImageToBase64(imageXFile);
    }

    // ======================================
    // CRÉATION DU MESSAGE UTILISATEUR
    // ======================================

    final userMessage = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_user',
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      imageUrl: imageXFile?.path,
      imageData: imageData,
      status: imageXFile != null ? MessageStatus.sending : MessageStatus.sent,
    );

    _messages.add(userMessage);
    _wasManuallyCleared = false;
    
    // ✅ Notifier AVANT la sauvegarde pour affichage immédiat
    notifyListeners();
    
    // ======================================
    // SAUVEGARDE DU MESSAGE UTILISATEUR
    // ======================================
    
    String? userMessagePocketBaseId;
    if (_isPocketBaseUser) {
      userMessagePocketBaseId = await _saveMessageToPocketBase(userMessage);
      
      // ✅ Incrémenter APRÈS confirmation de sauvegarde
      if (userMessagePocketBaseId != null && userId != null) {
        await _planService.incrementMessageCount(userId);
        //debugPrint('✅ Compteur incrémenté après sauvegarde confirmée');
      }
    } else {
      _saveMessages();
    }
    
    // Compteur local (pour utilisateurs entreprise)
    _messageCounterService.incrementMessageCount();
    
    _setTyping(true);

    try {
      // ======================================
      // UPLOAD DE L'IMAGE SI PRÉSENTE
      // ======================================
      
      if (imageXFile != null) {
        await Future.delayed(const Duration(seconds: 2));
        final uploadedImageUrl = imageXFile.path;
        final messageIndex = _messages.indexWhere((m) => m.id == userMessage.id);
        if (messageIndex != -1) {
          _messages[messageIndex] = _messages[messageIndex].copyWith(
            status: MessageStatus.sent,
            imageUrl: uploadedImageUrl,
          );
          
          if (_isPocketBaseUser && userMessagePocketBaseId != null) {
            await _updateMessageStatusInPocketBase(userMessage.id, MessageStatus.sent);
          } else {
            _saveMessages();
          }
          
          notifyListeners();
        }
      }

      // ======================================
      // CRÉATION DU MESSAGE AI
      // ======================================

      final aiMessageId = 'msg_${DateTime.now().millisecondsSinceEpoch}_ai';
      final aiMessage = Message(
        id: aiMessageId,
        content: '',
        isUser: false,
        timestamp: DateTime.now(),
        status: MessageStatus.streaming,
      );

      // ✅ CORRECTION CRITIQUE: Garder l'index initial
      final aiMessageStartIndex = _messages.length;
      _messages.add(aiMessage);
      _messageCounterService.incrementMessageCount();
      notifyListeners();

      // ======================================
      // STREAMING DE LA RÉPONSE AI
      // ======================================

      String accumulatedContent = '';
      String? finalSessionId;
      bool hasPlayedSound = false;
      int chunkCounter = 0;
      String? aiMessagePocketBaseId;

      await for (final streamEvent in RagflowService.sendMessageWithSessionStream(
        existingSessionId: _getCurrentConversationSessionId(),
        message: content.trim().isNotEmpty ? content : 'Image reçue',
      )) {
        try {
          final eventType = streamEvent['type'] as String?;
          
          if (eventType == 'session') {
            finalSessionId = streamEvent['sessionId'] as String?;
            if (finalSessionId != null) {
              await _updateCurrentConversationSessionId(finalSessionId);
            }
          } else if (eventType == 'content') {
            final newChunk = streamEvent['content'] as String?;
            if (newChunk != null && newChunk.isNotEmpty) {
              
              accumulatedContent += newChunk;
              _messageBuffers[aiMessageId] = accumulatedContent;
              _startTypewriterAnimation(aiMessageId, aiMessageStartIndex);
                    
                    // ✅ CORRECTION CRITIQUE: Utiliser l'index fixe au lieu de chercher
              if (aiMessageStartIndex < _messages.length && 
                  _messages[aiMessageStartIndex].id == aiMessageId) {
                _messages[aiMessageStartIndex] = _messages[aiMessageStartIndex].copyWith(
                  content: accumulatedContent,
                  status: MessageStatus.streaming,
                );
                
                // ✅ Sauvegarde optimisée : tous les 10 chunks OU si pas encore d'ID
                chunkCounter++;
                if (_isPocketBaseUser && chunkCounter % 10 == 0) {
                  if (aiMessagePocketBaseId == null) {
                    // Première sauvegarde
                    aiMessagePocketBaseId = await _saveMessageToPocketBase(_messages[aiMessageStartIndex]);
                    //debugPrint('🆔 AI Message ID PocketBase: $aiMessagePocketBaseId');
                  } else {
                    // Mise à jour
                    final pocketBaseId = _localToPocketBaseIds[aiMessageId] ?? aiMessagePocketBaseId;
                    await _pocketBaseService.updateMessageContent(
                      pocketBaseId,
                      accumulatedContent,
                    );
                  }
                }
                
                notifyListeners();
              }
              
              if (!hasPlayedSound && context != null) {
                _playMessageSound(context);
                hasPlayedSound = true;
              }
            }
          } else if (eventType == 'complete') {
            // ✅ CORRECTION: Utiliser l'index fixe
            if (aiMessageStartIndex < _messages.length && 
                _messages[aiMessageStartIndex].id == aiMessageId) {
              _messages[aiMessageStartIndex] = _messages[aiMessageStartIndex].copyWith(
                status: MessageStatus.sent,
              );
              
              // ✅ Sauvegarde finale
              if (_isPocketBaseUser) {
                if (aiMessagePocketBaseId == null) {
                  // Première sauvegarde (si aucun chunk n'a été sauvegardé)
                  aiMessagePocketBaseId = await _saveMessageToPocketBase(_messages[aiMessageStartIndex]);
                } else {
                  // Juste mettre à jour le statut
                  final pocketBaseId = _localToPocketBaseIds[aiMessageId] ?? aiMessagePocketBaseId;
                  await _updateMessageStatusInPocketBase(aiMessageId, MessageStatus.sent);
                }
              } else {
                _saveMessages();
              }
              
              notifyListeners();
            }
            
            if (context != null && accumulatedContent.isNotEmpty) {
              _showNotification(context, accumulatedContent);
            }
            break;
          } else if (eventType == 'error') {
            // ✅ CORRECTION: Utiliser l'index fixe
            if (aiMessageStartIndex < _messages.length && 
                _messages[aiMessageStartIndex].id == aiMessageId) {
              _messages[aiMessageStartIndex] = _messages[aiMessageStartIndex].copyWith(
                content: accumulatedContent.isNotEmpty ? accumulatedContent : 'Échec de l\'obtention de la réponse',
                status: MessageStatus.failed,
              );
              
              if (_isPocketBaseUser && aiMessagePocketBaseId != null) {
                await _updateMessageStatusInPocketBase(aiMessageId, MessageStatus.failed);
              } else {
                _saveMessages();
              }
              
              notifyListeners();
            }
            break;
          }
        } catch (streamError) {
          //print('⚠️ Erreur de traitement de l\'événement de stream: $streamError');
          continue;
        }
      }

      // ======================================
      // SAUVEGARDE CONVERSATION
      // ======================================
      
      if (_isPocketBaseUser) {
        await _saveCurrentConversationToPocketBase();
      } else {
        await _saveCurrentConversation();
      }
      
    } catch (e) {
      //debugPrint('❌ Erreur dans sendMessage: $e');
      final messageIndex = _messages.indexWhere((m) => m.id == userMessage.id);
      if (messageIndex != -1) {
        _messages[messageIndex] = _messages[messageIndex].copyWith(status: MessageStatus.failed);
        
        if (_isPocketBaseUser && userMessagePocketBaseId != null) {
          await _updateMessageStatusInPocketBase(userMessage.id, MessageStatus.failed);
        } else {
          _saveMessages();
        }
        
        notifyListeners();
      }
    } finally {
      _setTyping(false);
    }
  }

  // ✅ NOUVEAU: Fonction de retry pour la file d'attente
  Future<void> _processSyncQueue() async {
    if (_isSyncing || _syncQueue.isEmpty || !_isPocketBaseUser) return;
    
    _isSyncing = true;
    
    try {
      final messagesToSync = List<Message>.from(_syncQueue);
      
      for (final message in messagesToSync) {
        try {
          final pocketBaseId = await _pocketBaseService.saveMessage(
            message,
            _currentConversationId!,
          );
          
          if (pocketBaseId != null) {
            _localToPocketBaseIds[message.id] = pocketBaseId;
            _syncQueue.remove(message);
            //debugPrint('✅ Message synchronisé depuis la file: ${message.id}');
          }
        } catch (e) {
          //debugPrint('❌ Échec sync message ${message.id}: $e');
          // Garder dans la file pour retry ultérieur
        }
      }
    } finally {
      _isSyncing = false;
      _lastSyncTime = DateTime.now();
    }
  }

  // Reste du code existant inchangé...
  // (Toutes les autres méthodes restent identiques)

  void _setTyping(bool isTyping) {
    _isTyping = isTyping;
    notifyListeners();
  }

  String? _getCurrentConversationSessionId() {
    if (_currentConversationId == null) return null;
    return _savedConversations[_currentConversationId!]?.ragflowSessionId;
  }

  Future<void> _updateCurrentConversationSessionId(String sessionId) async {
    if (_currentConversationId == null) return;

    final currentConversation = _savedConversations[_currentConversationId!];
    if (currentConversation != null) {
      _savedConversations[_currentConversationId!] = currentConversation.copyWith(
        ragflowSessionId: sessionId,
      );

      if (_isPocketBaseUser) {
        await _saveCurrentConversationToPocketBase();
      } else {
        await _saveConversations();
      }
    }
  }

  Future<void> sendAudioMessage(
    String audioPath, {
    required int duration,
    String? transcription,
    required BuildContext context,
  }) async {
    try {
      // 🔒 VALIDATION SESSION
      if (!await _validateSession(context)) {
        return;
      }

      // 🔒 VÉRIFICATION PERMISSIONS PLAN
      if (_isPocketBaseUser) {
        final authService = PocketBaseAuthService();
        final currentUser = authService.currentUser;
        
        if (currentUser != null) {
          final canUseVoice = await _planService.canUseVoiceMessages(currentUser['id']);
          if (!canUseVoice.isAllowed) {
            _showPlanError(context, canUseVoice.errorMessage ?? 'Accès refusé');
            if (canUseVoice.requiresUpgrade) {
              _showUpgradeDialog(context);
            }
            return;
          }
        }
      }

      // ======================================
      // CRÉATION DU MESSAGE UTILISATEUR
      // ======================================
      
      final userMessage = Message(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        content: transcription ?? '',
        isUser: true,
        timestamp: DateTime.now(),
        audioUrl: audioPath, // Temporaire
        audioDuration: duration,
        status: MessageStatus.sending,
      );

      _messages.add(userMessage);
      notifyListeners();
      

      // ======================================
      // SAUVEGARDE DANS POCKETBASE AVEC UPLOAD
      // ======================================
      
      String? userMessagePocketBaseId;
      if (_isPocketBaseUser && _currentConversationId != null) {
        try {
          final authService = PocketBaseAuthService();
          final currentUser = authService.currentUser;
          
          if (currentUser != null) {
            // 🆕 Upload du fichier audio vers PocketBase
            final record = await _messageSaver.saveVoiceMessage(
              discussionId: _currentConversationId!,
              userId: currentUser['id'],
              audioPath: audioPath,
              audioDuration: duration,
              transcription: transcription,
            );
            
            userMessagePocketBaseId = record.id;
            
            // 🆕 Récupérer l'URL réelle du fichier audio
            final audioUrl = _messageSaver.getFileUrl(record, 'audio_file');
            
            // Mettre à jour le message avec la vraie URL PocketBase
            final messageIndex = _messages.indexWhere((m) => m.id == userMessage.id);
            if (messageIndex != -1) {
              _messages[messageIndex] = _messages[messageIndex].copyWith(
                audioUrl: audioUrl.toString(),
                status: MessageStatus.sent,
              );
              _localToPocketBaseIds[userMessage.id] = userMessagePocketBaseId;
              notifyListeners();
            }
            
            debugPrint('✅ Audio sauvegardé PocketBase: $userMessagePocketBaseId');
            debugPrint('✅ URL audio: $audioUrl');
          }
        } catch (e) {
          debugPrint('❌ Erreur sauvegarde audio PocketBase: $e');
          
          // Marquer comme failed
          final messageIndex = _messages.indexWhere((m) => m.id == userMessage.id);
          if (messageIndex != -1) {
            _messages[messageIndex] = _messages[messageIndex].copyWith(
              status: MessageStatus.failed,
            );
            notifyListeners();
          }
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Échec de l\'envoi du message audio'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      } else {
        // Système local pour les utilisateurs non-PocketBase
        await Future.delayed(const Duration(seconds: 1));
        final messageIndex = _messages.indexWhere((m) => m.id == userMessage.id);
        if (messageIndex != -1) {
          _messages[messageIndex] = _messages[messageIndex].copyWith(
            status: MessageStatus.sent,
          );
          _saveMessages();
          notifyListeners();
        }
      }

      // ======================================
      // CRÉATION DU MESSAGE AI
      // ======================================

      final aiMessageId = 'msg_${DateTime.now().millisecondsSinceEpoch}_ai';
      final aiMessage = Message(
        id: aiMessageId,
        content: '',
        isUser: false,
        timestamp: DateTime.now(),
        status: MessageStatus.streaming,
      );

      final aiMessageStartIndex = _messages.length;
      _messages.add(aiMessage);
      notifyListeners();
      

      // ======================================
      // STREAMING DE LA RÉPONSE AI
      // ======================================

      String accumulatedContent = '';
      String? finalSessionId;
      bool hasPlayedSound = false;
      int chunkCounter = 0;
      String? aiMessagePocketBaseId;

      // 🆕 Initialiser le buffer pour animation typewriter
      _messageBuffers[aiMessageId] = '';
      _displayedContent[aiMessageId] = '';

      await for (final streamEvent in RagflowService.sendMessageWithSessionStream(
        existingSessionId: _getCurrentConversationSessionId(),
        message: transcription?.trim().isNotEmpty == true 
            ? transcription! 
            : 'Message audio reçu',
      )) {
        try {
          final eventType = streamEvent['type'] as String?;
          
          if (eventType == 'session') {
            finalSessionId = streamEvent['sessionId'] as String?;
            if (finalSessionId != null) {
              await _updateCurrentConversationSessionId(finalSessionId);
            }
          } else if (eventType == 'content') {
            final newChunk = streamEvent['content'] as String?;
            if (newChunk != null && newChunk.isNotEmpty) {
              accumulatedContent += newChunk;
              
              // 🆕 Animation typewriter fluide
              _messageBuffers[aiMessageId] = accumulatedContent;
              _startTypewriterAnimation(aiMessageId, aiMessageStartIndex);
              
              chunkCounter++;
              if (_isPocketBaseUser && chunkCounter % 10 == 0) {
                if (aiMessagePocketBaseId == null) {
                  aiMessagePocketBaseId = await _saveMessageToPocketBase(
                    _messages[aiMessageStartIndex]
                  );
                } else {
                  final pocketBaseId = _localToPocketBaseIds[aiMessageId] ?? 
                                      aiMessagePocketBaseId;
                  await _pocketBaseService.updateMessageContent(
                    pocketBaseId,
                    accumulatedContent,
                  );
                }
              }
              
              if (!hasPlayedSound && context.mounted) {
                _playMessageSound(context);
                hasPlayedSound = true;
              }
            }
          } else if (eventType == 'complete') {
            // 🆕 Finir l'animation
            _messageBuffers[aiMessageId] = accumulatedContent;
            await _finishTypewriterAnimation(aiMessageId, aiMessageStartIndex);
            
            if (aiMessageStartIndex < _messages.length && 
                _messages[aiMessageStartIndex].id == aiMessageId) {
              _messages[aiMessageStartIndex] = _messages[aiMessageStartIndex].copyWith(
                status: MessageStatus.sent,
              );
              
              if (_isPocketBaseUser) {
                if (aiMessagePocketBaseId == null) {
                  aiMessagePocketBaseId = await _saveMessageToPocketBase(
                    _messages[aiMessageStartIndex]
                  );
                } else {
                  await _updateMessageStatusInPocketBase(
                    aiMessageId, 
                    MessageStatus.sent
                  );
                }
              } else {
                _saveMessages();
              }
              
              notifyListeners();
            }
            
            if (context.mounted && accumulatedContent.isNotEmpty) {
              _showNotification(context, accumulatedContent);
            }
            break;
          } else if (eventType == 'error') {
            _stopTypewriterAnimation(aiMessageId);
            
            if (aiMessageStartIndex < _messages.length && 
                _messages[aiMessageStartIndex].id == aiMessageId) {
              _messages[aiMessageStartIndex] = _messages[aiMessageStartIndex].copyWith(
                content: accumulatedContent.isNotEmpty 
                    ? accumulatedContent 
                    : 'Échec de l\'obtention de la réponse',
                status: MessageStatus.failed,
              );
              
              if (_isPocketBaseUser && aiMessagePocketBaseId != null) {
                await _updateMessageStatusInPocketBase(
                  aiMessageId, 
                  MessageStatus.failed
                );
              } else {
                _saveMessages();
              }
              
              notifyListeners();
            }
            break;
          }
        } catch (streamError) {
          debugPrint('⚠️ Erreur stream audio: $streamError');
          continue;
        }
      }

      // 🆕 Nettoyage typewriter
      _cleanupTypewriterData(aiMessageId);

      // ======================================
      // SAUVEGARDE CONVERSATION
      // ======================================
      
      if (_isPocketBaseUser) {
        await _saveCurrentConversationToPocketBase();
      } else {
        await _saveConversations();
      }

      // ======================================
      // INCRÉMENTATION COMPTEUR MESSAGES
      // ======================================
      
      if (_isPocketBaseUser) {
        final authService = PocketBaseAuthService();
        final currentUser = authService.currentUser;
        if (currentUser != null) {
          await _planService.incrementMessageCount(currentUser['id']);
        }
      }

      
    } catch (e) {
      debugPrint('❌ Erreur sendAudioMessage: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Future<void> startNewConversation() async {
    _messages.clear();
    _currentConversationId = 'conv_${DateTime.now().millisecondsSinceEpoch}';

    if (_isPocketBaseUser) {
      await _createNewPocketBaseConversation();
    } else {
      await _saveConversations();
    }

    notifyListeners();
  }

  Future<void> switchToConversation(String conversationId) async {
    final conversation = _savedConversations[conversationId];
    if (conversation == null) return;

    _messages.clear();
    _messages.addAll(conversation.messages);
    _currentConversationId = conversationId;

    if (_isPocketBaseUser) {
      final prefs = await SharedPreferences.getInstance();
await prefs.setString(_currentConversationKey, conversationId);
      
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentConversationKey, conversationId);
    }

    notifyListeners();
  }

  Future<void> deleteConversation(String conversationId) async {
    _savedConversations.remove(conversationId);

    if (_isPocketBaseUser) {
      await _pocketBaseService.deleteConversation(conversationId);
    } else {
      await _saveConversations();
    }

    if (_currentConversationId == conversationId) {
      _messages.clear();
      await startNewConversation();
    }

    notifyListeners();
  }

  Future<void> clearMessages() async {
    _messages.clear();
    _wasManuallyCleared = true;

    if (_isPocketBaseUser) {
      // Ne pas effacer sur PocketBase, créer nouvelle conversation
      await startNewConversation();
    } else {
      await _saveMessages();
    }

    notifyListeners();
  }

  void _playMessageSound(BuildContext context) {
    try {
      final settingsProvider = context.read<SettingsProvider>();
      if (settingsProvider.settings.messageSounds && _isAppInFocus) {
        _audioPlayer.play(AssetSource('sounds/message_received.mp3'));
      }
    } catch (e) {
      //debugPrint('Échec de la lecture du son: $e');
    }
  }

  Future<void> _showNotification(BuildContext context, String content) async {
    if (!_isAppInFocus) {
      await NotificationService().showMessageNotification(
        title: 'Réponse de l\'IA',
        body: content.length > 100 ? '${content.substring(0, 97)}...' : content,
        payload: 'chat_message',
      );
    }
  }

  Future<void> _loadMessages() async {
    try {
      _isLoadingMessages = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesKey);

      if (messagesJson != null && messagesJson != '[]') {
        final List<dynamic> messagesList = jsonDecode(messagesJson);
        if (messagesList.isNotEmpty && !_wasManuallyCleared) {
          _messages.clear();
          _messages.addAll(
            messagesList.map((json) => Message.fromJson(json)).toList(),
          );
        }
      } else {
        _messages.clear();
        await prefs.remove(_messagesKey);
      }
    } catch (e) {
      //debugPrint('Échec du chargement des messages: $e');
    } finally {
      _isInitialized = true;
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final settingsJson = prefs.getString('app_settings');
      bool autoSaveEnabled = true;

      if (settingsJson != null) {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
        autoSaveEnabled = settings['autoSaveConversations'] ?? true;
      }

      if (autoSaveEnabled) {
        final messagesJson = jsonEncode(
          _messages.map((message) => message.toJson()).toList(),
        );
        await prefs.setString(_messagesKey, messagesJson);
      } else {
        await prefs.remove(_messagesKey);
      }
    } catch (e) {
      //debugPrint('Échec de la sauvegarde des messages: $e');
    }
  }

  Future<void> _loadSavedConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationsJson = prefs.getString(_conversationsKey);

      if (conversationsJson != null) {
        final Map<String, dynamic> conversationsMap = jsonDecode(conversationsJson);
        _savedConversations.clear();

        for (final entry in conversationsMap.entries) {
          _savedConversations[entry.key] = Conversation.fromJson(entry.value);
        }
      }

      _currentConversationId = prefs.getString(_currentConversationKey);
    } catch (e) {
      //debugPrint('Échec du chargement des conversations sauvegardées: $e');
    }
  }

  Future<void> _saveConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final settingsJson = prefs.getString('app_settings');
      bool autoSaveEnabled = true;

      if (settingsJson != null) {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
        autoSaveEnabled = settings['autoSaveConversations'] ?? true;
      }

      if (autoSaveEnabled) {
        final conversationsMap = <String, dynamic>{};
        for (final entry in _savedConversations.entries) {
          conversationsMap[entry.key] = entry.value.toJson();
        }

        await prefs.setString(_conversationsKey, jsonEncode(conversationsMap));

        if (_currentConversationId != null) {
          await prefs.setString(_currentConversationKey, _currentConversationId!);
        }
      } else {
        await prefs.remove(_conversationsKey);
        await prefs.remove(_currentConversationKey);
      }
    } catch (e) {
      //debugPrint('Échec de la sauvegarde des conversations: $e');
    }
  }

  Future<void> _saveCurrentConversation() async {
    if (_messages.isEmpty || _currentConversationId == null) return;

    final now = DateTime.now();
    final conversation = Conversation(
      id: _currentConversationId!,
      title: Conversation.generateTitle(_messages),
      createdAt: _savedConversations[_currentConversationId!]?.createdAt ?? now,
      lastMessageAt: now,
      messages: List.from(_messages),
    );

    _savedConversations[_currentConversationId!] = conversation;
    await _saveConversations();
  }

  List<Conversation> getSortedConversations() {
    final conversations = _savedConversations.values.toList();
    conversations.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return conversations;
  }

  void resetClearedState() {
    _wasManuallyCleared = false;
  }

  Future<void> onAutoSaveSettingChanged(bool enabled) async {
    if (!enabled) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_messagesKey);
      } catch (e) {
        //debugPrint('Échec de la suppression des messages sauvegardés lorsque l\'auto-sauvegarde est désactivée: $e');
      }
    } else {
      await _saveMessages();
    }
  }

  Future<String?> _convertImageToBase64(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      //debugPrint('Échec de la conversion de l\'image en base64: $e');
      return null;
    }
  }

  void _scheduleStatusUpdate(String messageId, String content) {
    Timer(Duration(milliseconds: content.length * 20 + 2000), () {
      final messageIndex = _messages.indexWhere((m) => m.id == messageId);
      if (messageIndex != -1) {
        _messages[messageIndex] = _messages[messageIndex].copyWith(
          status: MessageStatus.sent,
        );
        if (_isPocketBaseUser) {
          _updateMessageStatusInPocketBase(messageId, MessageStatus.sent);
        } else {
          _saveMessages();
        }
        notifyListeners();
      }
    });
  }

  String _getFallbackResponse(String userMessage) {
    final responses = [
      "C'est une question intéressante ! Laissez-moi y réfléchir.",
      "Je comprends votre question. Voici mon point de vue à ce sujet.",
      "Excellente question ! Je serais ravi de vous aider avec cela.",
      "Je peux certainement vous aider. Voici ce que je suggère :",
      "C'est une demande réfléchie. D'après ce que vous avez partagé, je pense :",
      "J'apprécie que vous me posiez cette question. Laissez-moi vous donner quelques aperçus :",
      "C'est un sujet que je peux vous aider à explorer. Considérez ceci :",
    ];

    final baseResponse = responses[DateTime.now().millisecond % responses.length];

    if (userMessage.toLowerCase().contains('weather') || userMessage.toLowerCase().contains('météo')) {
      return "J'aurais besoin de connaître votre localisation pour vous fournir des informations météorologiques précises. Pourriez-vous partager votre ville ou autoriser l'accès à la localisation ?";
    } else if (userMessage.toLowerCase().contains('hello') ||
        userMessage.toLowerCase().contains('hi') ||
        userMessage.toLowerCase().contains('bonjour') ||
        userMessage.toLowerCase().contains('salut')) {
      return "Bonjour ! Je suis ravi de discuter avec vous. De quoi aimeriez-vous parler ?";
    } else if (userMessage.toLowerCase().contains('help') || userMessage.toLowerCase().contains('aide')) {
      return "Je suis là pour vous aider ! Vous pouvez me poser des questions sur divers sujets, me demander de l'aide pour des tâches ou simplement avoir une conversation. De quelle aide spécifique avez-vous besoin ?";
    } else if (userMessage.toLowerCase().contains('time') || userMessage.toLowerCase().contains('heure')) {
      return "L'heure actuelle est ${DateTime.now().toString().substring(11, 19)}. Y a-t-il quelque chose en rapport avec l'heure pour lequel je peux vous aider ?";
    }

    return "$baseResponse Je suis conçu pour être utile, informatif et conversationnel. N'hésitez pas à me poser n'importe quelle question !";
  }

  // ======================================
  // MÉTHODES HELPER POUR LA GESTION DES PLANS
  // ======================================

  void _showPlanError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.block, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'En savoir plus',
          textColor: Colors.white,
          onPressed: () {
            context.push('/plans');
          },
        ),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.upgrade, color: AppTheme.primaryGreen),
            const SizedBox(width: 12),
            const Text('Mise à niveau Requise'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vous avez atteint les limites de votre plan. Passez à un plan supérieur pour continuer à utiliser TGM HydroAI.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Avantages du Plan Individuel:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            _buildBenefitRow('✓ Messages illimités'),
            _buildBenefitRow('✓ Téléchargement et analyse d\'images'),
            _buildBenefitRow('✓ Messages vocaux'),
            _buildBenefitRow('✓ Exportation de données'),
            const SizedBox(height: 8),
            Text(
              'À partir de 19,99 CAD/mois ou 99 CAD/an',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/plans');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Voir les plans'),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(String benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        benefit,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  void _showQuotaWarning(BuildContext context, int remainingMessages) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Il vous reste $remainingMessages messages ce mois-ci',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  /// Alias pour compatibilité avec l'ancien code  
  Future<String> createNewConversation() async {
    await startNewConversation();
    return _currentConversationId ?? 'conv_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Efface tous les messages sauvegardés
  Future<void> clearSavedMessages() async {
    try {
      if (_isPocketBaseUser) {
        // Pour PocketBase, supprimer toutes les conversations
        final conversationIds = _savedConversations.keys.toList();
        for (final conversationId in conversationIds) {
          try {
            await _pocketBaseService.deleteConversation(conversationId);
          } catch (e) {
            debugPrint('Erreur suppression conversation $conversationId: $e');
          }
        }
        _savedConversations.clear();
      } else {
        // Système local existant
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_messagesKey);
        await prefs.remove(_conversationsKey);
      }
      
      _messages.clear();
      _wasManuallyCleared = true;
      
      // Créer une nouvelle conversation
      await startNewConversation();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Échec de l\'effacement des messages sauvegardés: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _syncTimer?.cancel();
    for (final timer in _typewriterTimers.values) {
        timer?.cancel();
      }
      _typewriterTimers.clear();
      _messageBuffers.clear();
      _displayedContent.clear();
        super.dispose();
  }

    void _startTypewriterAnimation(String messageId, int messageIndex) {
    if (_typewriterTimers[messageId] != null) return;
    _typewriterTimers[messageId] = Timer.periodic(
      Duration(milliseconds: _typewriterSpeed),
      (timer) {
        final buffer = _messageBuffers[messageId] ?? '';
        final displayed = _displayedContent[messageId] ?? '';
        if (displayed.length >= buffer.length) return;
        
        _displayedContent[messageId] = displayed + buffer[displayed.length];
        
        if (messageIndex < _messages.length && _messages[messageIndex].id == messageId) {
          _messages[messageIndex] = _messages[messageIndex].copyWith(
            content: _displayedContent[messageId]!,
            status: MessageStatus.streaming,
          );
          notifyListeners();
        }
      },
    );
  }

  Future<void> _finishTypewriterAnimation(String messageId, int messageIndex) async {
    final buffer = _messageBuffers[messageId] ?? '';
    _displayedContent[messageId] = buffer;
    if (messageIndex < _messages.length && _messages[messageIndex].id == messageId) {
      _messages[messageIndex] = _messages[messageIndex].copyWith(content: buffer);
      notifyListeners();
    }
    _stopTypewriterAnimation(messageId);
  }

  void _stopTypewriterAnimation(String messageId) {
    _typewriterTimers[messageId]?.cancel();
    _typewriterTimers.remove(messageId);
  }

  void _cleanupTypewriterData(String messageId) {
    _stopTypewriterAnimation(messageId);
    _messageBuffers.remove(messageId);
    _displayedContent.remove(messageId);
  }
}
