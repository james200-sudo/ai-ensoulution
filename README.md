# TGM HydroAI Chat

A cross-platform AI-powered chat application built with Flutter, featuring intelligent conversations, multi-language support, and advanced authentication options.

## 📱 Overview

TGM HydroAI Chat is an intelligent chat assistant application that supports multiple platforms (iOS, Android, Web, Windows, Linux, macOS) with a responsive design that adapts to different screen sizes.

## ✨ Features

### 🔐 Authentication
- **Email/Password Login** ✅ (Implemented)
- **Social Login** 🔄 (UI implemented, backend integration needed)
  - Google Sign-in
  - Facebook Sign-in  
  - Apple Sign-in
- **Biometric Authentication** ✅ (Conditional based on device capability)
  - Fingerprint
  - Face ID / Face Recognition
  - Only shown on devices with biometric hardware

### 💬 Chat System
- **Real-time Messaging** ✅ (Implemented with mock responses)
- **Typing Indicators** ✅ (Implemented)
- **Message History** ✅ (Local storage)
- **Responsive UI** ✅ (Mobile, Tablet, Desktop layouts)
- **Message Sounds** ✅ (Configurable audio notifications)
- **Smart Notifications** ✅ (Background notifications only)
  - Web/Desktop: Always show notifications
  - Mobile: Only when app is backgrounded

### 🎨 User Interface
- **Responsive Design** ✅ (Adapts to all screen sizes)
- **Split Screen Login** ✅ (Tablet/Desktop with branded image)
- **Dark/Light Mode** ✅ (User configurable)
- **Font Size Control** ✅ (Accessibility support)
- **Custom App Logo** ✅ (Consistent branding across platforms)

### 🌍 Internationalization
- **Multi-language Support** ✅ (Complete implementation)
  - English (US)
  - Français (French)
  - Español (Spanish)
- **Auto-detection** ✅ (Based on device language)
- **Manual Language Selection** ✅ (In settings)

### ⚙️ Settings & Preferences
- **Push Notifications** ✅ (Platform-aware)
- **Message Sounds** ✅ (Audio feedback)
- **Auto-save Conversations** ✅ (Setting available)
- **Biometric Authentication** ✅ (Conditional display)
- **Privacy Settings** 🔄 (Placeholder implementation)
- **Data Management** 🔄 (Clear history, reset settings)

### 👤 User Profile
- **Profile Management** ✅ (Name, email, avatar)
- **Avatar Selection** ✅ (Camera, gallery, remove)
- **Usage Statistics** ✅ (Messages, days active, rating)
- **Profile Persistence** ✅ (Local storage)

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── router/
│   │   └── app_router.dart           # GoRouter configuration
│   ├── services/
│   │   └── notification_service.dart # Cross-platform notifications
│   ├── theme/
│   │   └── app_theme.dart           # App theming & colors
│   ├── utils/
│   │   └── responsive.dart          # Responsive design utilities
│   └── widgets/
│       └── user_avatar.dart         # Reusable avatar component
│
├── features/
│   ├── auth/
│   │   └── screens/
│   │       └── login_screen.dart    # Authentication UI
│   │
│   ├── chat/
│   │   ├── models/
│   │   │   └── message.dart         # Message data model
│   │   ├── providers/
│   │   │   └── chat_provider.dart   # Chat state management
│   │   ├── screens/
│   │   │   └── chat_screen.dart     # Main chat interface
│   │   └── widgets/
│   │       ├── message_bubble.dart  # Message UI component
│   │       └── typing_indicator.dart # Typing animation
│   │
│   ├── profile/
│   │   ├── models/
│   │   │   └── user_stats.dart      # User statistics model
│   │   ├── providers/
│   │   │   └── profile_provider.dart # Profile state management
│   │   ├── screens/
│   │   │   └── profile_screen.dart  # User profile interface
│   │   └── widgets/
│   │       └── profile_image_picker.dart # Avatar selection
│   │
│   ├── settings/
│   │   ├── models/
│   │   │   └── app_settings.dart    # Settings data model
│   │   ├── providers/
│   │   │   └── settings_provider.dart # Settings state management
│   │   ├── screens/
│   │   │   └── settings_screen.dart # Settings interface
│   │   └── widgets/
│   │       └── setting_toggle.dart  # Reusable setting components
│   │
│   └── splash/
│       └── screens/
│           └── splash_screen.dart   # App loading screen
│
├── l10n/                            # Internationalization
│   ├── app_en.arb                   # English translations
│   ├── app_fr.arb                   # French translations
│   └── app_es.arb                   # Spanish translations
│
└── main.dart                        # App entry point
```

## 🖥️ Platform Support

| Platform | Status | Notes |
|----------|--------|--------|
| **Android** | ✅ Full Support | All features working |
| **iOS** | ✅ Full Support | All features working |
| **Web** | ✅ Full Support | Optimized for browsers |
| **Windows** | ✅ Full Support | Native notifications |
| **Linux** | ✅ Full Support | Native notifications |
| **macOS** | ✅ Full Support | Native notifications |

## 📱 Screens Overview

### 1. Splash Screen ✅
- **Purpose**: App loading and initialization
- **Features**: Animated logo, localized loading text
- **Status**: Complete

### 2. Login Screen ✅
- **Purpose**: User authentication
- **Features**: 
  - Responsive layout (mobile vs desktop/tablet split)
  - Email/password authentication
  - Social login buttons
  - Biometric authentication (when available)
  - Form validation with localized error messages
- **Status**: Complete (backend integration needed for social login)

### 3. Chat Screen ✅
- **Purpose**: Main chat interface
- **Features**:
  - Real-time messaging with AI
  - Responsive layouts (mobile/tablet/desktop)
  - Message history
  - Typing indicators
  - Sound notifications
  - Push notifications (background only)
  - Enter key to send messages
  - Keyboard shortcuts support
- **Status**: Complete (mock AI responses)

### 4. Profile Screen ✅
- **Purpose**: User profile management
- **Features**:
  - Profile editing (name, email, avatar)
  - Usage statistics display
  - Avatar selection (camera/gallery)
  - Profile persistence
- **Status**: Complete

### 5. Settings Screen ✅
- **Purpose**: App configuration
- **Features**:
  - Categorized settings sections
  - Push notifications toggle
  - Message sounds toggle
  - Biometric auth (conditional)
  - Language selection
  - Font size adjustment
  - Dark mode toggle
  - Data management options
- **Status**: Complete (some features need backend)

## 🔧 Dependencies

### Core Dependencies
- `flutter`: Framework
- `flutter_screenutil`: Responsive design
- `provider`: State management
- `go_router`: Navigation
- `shared_preferences`: Local storage
- `http`: HTTP requests

### Feature Dependencies
- `local_auth`: Biometric authentication
- `audioplayers`: Sound notifications  
- `flutter_local_notifications`: Push notifications
- `image_picker`: Profile image selection
- `flutter_localizations`: Internationalization

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (≥3.3.0)
- Dart SDK
- Platform-specific development tools

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tgm_ai_chat
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate localization files**
   ```bash
   flutter gen-l10n
   ```

4. **Run the application**
   ```bash
   # Development
   flutter run
   
   # Web
   flutter run -d chrome
   
   # Specific platform
   flutter run -d windows
   flutter run -d linux
   flutter run -d macos
   ```

### Building for Production

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Desktop
flutter build windows --release
flutter build linux --release
flutter build macos --release
```

## ⚠️ Implementation Status

### ✅ Fully Implemented
- User interface and responsive design
- Authentication system (UI complete)
- Chat interface with mock AI
- Profile management
- Settings system
- Internationalization
- Local notifications
- Sound system
- Biometric authentication
- Data persistence

### 🔄 Needs Backend Integration
- **Social Login Authentication**
  - Google OAuth integration
  - Facebook OAuth integration  
  - Apple Sign-in integration
- **Real AI Chat System**
  - Replace mock responses with actual AI API
  - Implement proper conversation context
  - Add message persistence to backend
- **User Account System**
  - Server-side user management
  - Profile synchronization
  - Cross-device data sync

### 📝 Placeholder Implementations
- **Privacy Settings Dialog**: Basic placeholder
- **Help & Support**: Static dialog
- **About Dialog**: Basic app information
- **Clear Chat History**: Local only
- **Reset Settings**: Local only
- **Social Login Handlers**: Show snackbar only

### 🔮 Future Enhancements
- [ ] Message encryption
- [ ] Voice messages
- [ ] Image sharing
- [ ] Chat export functionality
- [ ] Advanced AI features
- [ ] Group chat support
- [ ] Message search
- [ ] Custom themes
- [ ] Widget support

## 🎯 Next Steps

1. **Backend Integration**
   - Set up authentication server
   - Implement real AI chat API
   - Add user management system

2. **Enhanced Features**
   - Add message search
   - Implement chat export
   - Add voice message support

3. **Testing & Quality**
   - Add comprehensive unit tests
   - Implement integration tests
   - Set up CI/CD pipeline

## 🤝 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Note**: This is a feature-complete frontend application with mock data. Backend integration is required for production deployment.