class AppSettings {
  final bool pushNotifications;
  final bool messageSounds;
  final bool autoSaveConversations;
  final bool darkMode;
  final String language;
  final double fontSize;
  final bool biometricAuth;
  final String? companyCode;

  const AppSettings({
    this.pushNotifications = true,
    this.messageSounds = false,
    this.autoSaveConversations = true,
    this.darkMode = false,
    this.language = 'en',
    this.fontSize = 14.0,
    this.biometricAuth = false,
    this.companyCode,
  });

  AppSettings copyWith({
    bool? pushNotifications,
    bool? messageSounds,
    bool? autoSaveConversations,
    bool? darkMode,
    String? language,
    double? fontSize,
    bool? biometricAuth,
    String? companyCode,
  }) {
    return AppSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      messageSounds: messageSounds ?? this.messageSounds,
      autoSaveConversations: autoSaveConversations ?? this.autoSaveConversations,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      fontSize: fontSize ?? this.fontSize,
      biometricAuth: biometricAuth ?? this.biometricAuth,
      companyCode: companyCode ?? this.companyCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNotifications': pushNotifications,
      'messageSounds': messageSounds,
      'autoSaveConversations': autoSaveConversations,
      'darkMode': darkMode,
      'language': language,
      'fontSize': fontSize,
      'biometricAuth': biometricAuth,
      'companyCode': companyCode,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      pushNotifications: json['pushNotifications'] ?? true,
      messageSounds: json['messageSounds'] ?? false,
      autoSaveConversations: json['autoSaveConversations'] ?? true,
      darkMode: json['darkMode'] ?? false,
      language: json['language'] ?? 'en',
      fontSize: json['fontSize'] ?? 14.0,
      biometricAuth: json['biometricAuth'] ?? false,
      companyCode: json['companyCode'],
    );
  }
}