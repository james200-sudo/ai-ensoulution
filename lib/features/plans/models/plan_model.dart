class Plan {
  final String id;
  final String name;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> perks;
  final DateTime created;
  final DateTime updated;

  Plan({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.perks,
    required this.created,
    required this.updated,
  });

  // Factory constructor pour créer un Plan depuis PocketBase
  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] ?? '',
      name: json['Name'] ?? '',
      monthlyPrice: (json['MonthlyPrice'] ?? 0).toDouble(),
      yearlyPrice: (json['yearlyPrice'] ?? 0).toDouble(),
      perks: List<String>.from(json['perks'] ?? []),
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
    );
  }

  // Méthode pour obtenir le prix formaté selon la période
  String getPriceFormatted({required bool isYearly}) {
    if (monthlyPrice == 0 && yearlyPrice == 0) {
      return '\$0';
    }
    if (isYearly) {
      return '\$${yearlyPrice.toStringAsFixed(0)}';
    } else {
      return '\$${monthlyPrice.toStringAsFixed(0)}';
    }
  }

  // Méthode pour obtenir le prix selon la période de facturation
  String getFormattedPrice(bool isYearly) {
    return getPriceFormatted(isYearly: isYearly);
  }

  // Calculer la réduction annuelle en valeur absolue
  double get yearlyDiscount {
    if (monthlyPrice == 0 || yearlyPrice == 0) return 0;
    final monthlyCost = monthlyPrice * 12;
    return monthlyCost - yearlyPrice;
  }

  // Calculer le pourcentage de réduction annuelle
  double get yearlyDiscountPercentage {
    if (monthlyPrice == 0 || yearlyPrice == 0) return 0;
    final monthlyCost = monthlyPrice * 12;
    if (monthlyCost == 0) return 0;
    return ((monthlyCost - yearlyPrice) / monthlyCost) * 100;
  }

  // Méthode pour vérifier si c'est un plan gratuit
  bool get isFree => monthlyPrice == 0 && yearlyPrice == 0;

  // Méthode pour vérifier si c'est un plan Enterprise
  bool get isEnterprise {
    final planName = name.toLowerCase();
    return planName.contains('enterprise') || 
           planName.contains('entreprise') || 
           planName.contains('empresarial');
  }

  // Méthode pour vérifier si c'est un plan populaire (Premium par exemple)
  bool get isPopular {
    final planName = name.toLowerCase();
    return planName.contains('premium') || 
           planName.contains('pro');
  }

  // Obtenir la période d'affichage pour le prix
  String getPricePeriod(bool isYearly) {
    if (isFree || isEnterprise) {
      return '';
    }
    return isYearly ? '/year' : '/month';
  }

  // Méthode pour obtenir le prix numérique selon la période
  double getPriceValue(bool isYearly) {
    return isYearly ? yearlyPrice : monthlyPrice;
  }

  // Méthode pour comparer les plans par prix
  int compareByPrice(Plan other, bool isYearly) {
    final thisPrice = getPriceValue(isYearly);
    final otherPrice = other.getPriceValue(isYearly);
    return thisPrice.compareTo(otherPrice);
  }

  // Méthode pour obtenir une description courte du plan
  String get shortDescription {
    if (perks.isEmpty) return 'Plan sans fonctionnalités spécifiées';
    if (perks.length <= 2) return perks.join(', ');
    return '${perks.take(2).join(', ')} et ${perks.length - 2} autres';
  }

  // Convertir en Map pour l'envoi à l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Name': name,
      'MonthlyPrice': monthlyPrice,
      'yearlyPrice': yearlyPrice,
      'perks': perks,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  // Créer une copie du plan avec certains champs modifiés
  Plan copyWith({
    String? id,
    String? name,
    double? monthlyPrice,
    double? yearlyPrice,
    List<String>? perks,
    DateTime? created,
    DateTime? updated,
  }) {
    return Plan(
      id: id ?? this.id,
      name: name ?? this.name,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      yearlyPrice: yearlyPrice ?? this.yearlyPrice,
      perks: perks ?? this.perks,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  @override
  String toString() {
    return 'Plan{id: $id, name: $name, monthlyPrice: $monthlyPrice, yearlyPrice: $yearlyPrice, perks: ${perks.length}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Plan && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}