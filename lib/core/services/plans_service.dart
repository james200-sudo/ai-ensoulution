import 'package:pocketbase/pocketbase.dart';
import '../../features/plans/models/plan_model.dart';

class PlansService {
  final PocketBase _pb = PocketBase('https://hydro-ai-chat.ensolutions.ca');
  
  // Récupérer tous les plans avec leurs perks (version finale optimisée)
  Future<List<Plan>> getAllPlans({bool forceRefresh = false}) async {
    try {
      //print('🔄 PlansService: Récupération des plans...');
      
      // 1. Récupérer tous les plans
      final planRecords = await _pb.collection('plans').getFullList(
        sort: 'MonthlyPrice',
      );
      //print('📦 Plans récupérés: ${planRecords.length}');
      
      // 2. Récupérer tous les perks en une seule requête
      final allPerks = await _pb.collection('plan_perks').getFullList();
      //print('📦 Perks récupérés: ${allPerks.length}');
      
      // 3. Créer une map pour un accès rapide aux perks par ID
      final perksMap = <String, String>{};
      for (final perk in allPerks) {
        perksMap[perk.id] = perk.data['name']?.toString() ?? 'Perk sans nom';
      }
      //print('🗺️ Map des perks créée: ${perksMap.length} entrées');
      
      // 4. Construire les plans avec les noms des perks
      List<Plan> plans = [];
      
      for (int i = 0; i < planRecords.length; i++) {
        final record = planRecords[i];
        //print('🔧 Traitement du plan ${i + 1}/${planRecords.length}: ${record.data['Name']}');
        
        // Récupérer les IDs des perks depuis le champ perks
        final perkIds = <String>[];
        if (record.data['perks'] != null) {
          final perksField = record.data['perks'];
          if (perksField is List) {
            perkIds.addAll(perksField.map((e) => e.toString()));
          }
        }
        //print('  - IDs perks: $perkIds');
        
        // Convertir les IDs en noms de perks
        final perkNames = perkIds
            .map((id) => perksMap[id] ?? 'Perk introuvable ($id)')
            .toList();
        //print('  - Noms perks: $perkNames');
        
        // Créer les données du plan avec les noms des perks
        final planData = record.toJson();
        planData['perks'] = perkNames; // Remplacer les IDs par les noms
        
        final plan = Plan.fromJson(planData);
        plans.add(plan);
        //print('✅ Plan ajouté: ${plan.name} - ${plan.perks.length} perks');
      }
      
      //print('🎉 Total des plans traités: ${plans.length}');
      return plans;
      
    } catch (e) {
      //print('❌ Erreur lors de la récupération des plans: $e');
      throw Exception('Impossible de récupérer les plans: $e');
    }
  }
  
  // Récupérer un plan spécifique par son ID
  Future<Plan?> getPlanById(String id) async {
    try {
      final record = await _pb.collection('plans').getOne(id);
      
      // Récupérer les IDs des perks
      final perkIds = <String>[];
      if (record.data['perks'] != null) {
        final perksField = record.data['perks'];
        if (perksField is List) {
          perkIds.addAll(perksField.map((e) => e.toString()));
        }
      }
      
      if (perkIds.isNotEmpty) {
        // Récupérer les noms des perks
        final filter = perkIds.map((id) => 'id="$id"').join(' || ');
        final perkRecords = await _pb.collection('plan_perks').getFullList(
          filter: '($filter)',
        );
        
        final perkNames = perkRecords
            .map((perk) => perk.data['name']?.toString() ?? 'Perk sans nom')
            .toList();
        
        final planData = record.toJson();
        planData['perks'] = perkNames;
        
        return Plan.fromJson(planData);
      } else {
        final planData = record.toJson();
        planData['perks'] = <String>[];
        return Plan.fromJson(planData);
      }
    } catch (e) {
      //print('❌ Erreur lors de la récupération du plan $id: $e');
      return null;
    }
  }
  
  // Récupérer un plan par son nom
  Future<Plan?> getPlanByName(String name) async {
    try {
      final record = await _pb.collection('plans').getFirstListItem(
        'Name="$name"',
      );
      
      return getPlanById(record.id);
    } catch (e) {
      //print('❌ Erreur lors de la récupération du plan $name: $e');
      return null;
    }
  }
  
  // Récupérer les plans par gamme de prix
  Future<List<Plan>> getPlansByPriceRange(double minPrice, double maxPrice, bool isYearly) async {
    try {
      final priceField = isYearly ? 'yearlyPrice' : 'MonthlyPrice';
      final filter = '$priceField >= $minPrice && $priceField <= $maxPrice';
      
      final records = await _pb.collection('plans').getFullList(
        sort: priceField,
        filter: filter,
      );
      
      // Utiliser la même logique que getAllPlans pour traiter les perks
      final allPerks = await _pb.collection('plan_perks').getFullList();
      final perksMap = <String, String>{};
      for (final perk in allPerks) {
        perksMap[perk.id] = perk.data['name']?.toString() ?? 'Perk sans nom';
      }
      
      List<Plan> plans = [];
      for (final record in records) {
        final perkIds = <String>[];
        if (record.data['perks'] != null) {
          final perksField = record.data['perks'];
          if (perksField is List) {
            perkIds.addAll(perksField.map((e) => e.toString()));
          }
        }
        
        final perkNames = perkIds
            .map((id) => perksMap[id] ?? 'Perk introuvable ($id)')
            .toList();
        
        final planData = record.toJson();
        planData['perks'] = perkNames;
        
        plans.add(Plan.fromJson(planData));
      }
      
      return plans;
    } catch (e) {
      //print('❌ Erreur lors de la récupération des plans par prix: $e');
      throw Exception('Impossible de récupérer les plans par prix: $e');
    }
  }
}