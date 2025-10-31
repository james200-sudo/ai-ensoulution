class UserStats {
  final int messageCount;
  final int daysActive;
  final double rating;
  final DateTime joinDate;
  final int conversationsCount;

  const UserStats({
    required this.messageCount,
    required this.daysActive,
    required this.rating,
    required this.joinDate,
    required this.conversationsCount,
  });

  UserStats copyWith({
    int? messageCount,
    int? daysActive,
    double? rating,
    DateTime? joinDate,
    int? conversationsCount,
  }) {
    return UserStats(
      messageCount: messageCount ?? this.messageCount,
      daysActive: daysActive ?? this.daysActive,
      rating: rating ?? this.rating,
      joinDate: joinDate ?? this.joinDate,
      conversationsCount: conversationsCount ?? this.conversationsCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageCount': messageCount,
      'daysActive': daysActive,
      'rating': rating,
      'joinDate': joinDate.toIso8601String(),
      'conversationsCount': conversationsCount,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      messageCount: json['messageCount'],
      daysActive: json['daysActive'],
      rating: json['rating'],
      joinDate: DateTime.parse(json['joinDate']),
      conversationsCount: json['conversationsCount'],
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final UserStats stats;
  final DateTime lastActive;
  final String currentPlan;
  final DateTime? planExpiryDate;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.stats,
    required this.lastActive,
    this.currentPlan = 'Free',
    this.planExpiryDate,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    UserStats? stats,
    DateTime? lastActive,
    String? currentPlan,
    DateTime? planExpiryDate,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      stats: stats ?? this.stats,
      lastActive: lastActive ?? this.lastActive,
      currentPlan: currentPlan ?? this.currentPlan,
      planExpiryDate: planExpiryDate ?? this.planExpiryDate,
    );
  }

  String get initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names.first[0]}${names.last[0]}'.toUpperCase();
    }
    return names.first.length >= 2 
        ? names.first.substring(0, 2).toUpperCase()
        : names.first[0].toUpperCase();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'stats': stats.toJson(),
      'lastActive': lastActive.toIso8601String(),
      'currentPlan': currentPlan,
      'planExpiryDate': planExpiryDate?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      stats: UserStats.fromJson(json['stats']),
      lastActive: DateTime.parse(json['lastActive']),
      currentPlan: json['currentPlan'] ?? 'Free',
      planExpiryDate: json['planExpiryDate'] != null 
          ? DateTime.parse(json['planExpiryDate'])
          : null,
    );
  }
}