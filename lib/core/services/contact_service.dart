import 'package:pocketbase/pocketbase.dart';
import 'package:tgm_ai_chat/core/services/pocketbase_instance.dart';

class ContactService {
  final PocketBase _pb = PocketBaseInstance.instance;

  /// Soumet une demande de contact pour Enterprise/Hydropower
  Future<void> submitContactRequest({
    required String company,
    required String name,
    required String email,
    required String phone,
    required String message,
    String? planInterested, // "Enterprise", "Hydropower Utilities", etc.
  }) async {
    try {
      //print('📤 ContactService: Envoi de la demande de contact...');
      
      // Récupérer l'utilisateur connecté (si disponible)
      String? userId;
      try {
        userId = _pb.authStore.model?.id;
      } catch (e) {
        //print('⚠️ Utilisateur non connecté, demande anonyme');
      }

      // Créer la demande de contact dans PocketBase
      final record = await _pb.collection('contact_requests').create(
        body: {
          'company': company,
          'name': name,
          'email': email,
          'phone': phone,
          'message': message,
          'status': 'new',
          if (planInterested != null) 'plan_interested': planInterested,
          if (userId != null) 'user': userId,
        },
      );

      //print('✅ ContactService: Demande créée avec succès - ID: ${record.id}');
    } catch (e) {
      //print('❌ ContactService: Erreur lors de l\'envoi de la demande: $e');
      rethrow;
    }
  }

  /// Récupère toutes les demandes de contact (admin seulement)
  Future<List<Map<String, dynamic>>> getAllContactRequests() async {
    try {
      final records = await _pb.collection('contact_requests').getFullList(
        sort: '-created',
      );

      return records.map((record) => record.toJson()).toList();
    } catch (e) {
      //print('❌ ContactService: Erreur lors de la récupération des demandes: $e');
      rethrow;
    }
  }

  /// Met à jour le statut d'une demande (admin seulement)
  Future<void> updateContactRequestStatus(
    String requestId,
    String newStatus,
  ) async {
    try {
      await _pb.collection('contact_requests').update(
        requestId,
        body: {'status': newStatus},
      );

      //print('✅ ContactService: Statut mis à jour pour $requestId: $newStatus');
    } catch (e) {
      //print('❌ ContactService: Erreur lors de la mise à jour du statut: $e');
      rethrow;
    }
  }
}