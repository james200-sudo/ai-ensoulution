import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:tgm_ai_chat/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/auth_guard.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../../profile/providers/profile_provider.dart';
import '../../../core/services/audio_recording_service.dart';
import 'package:tgm_ai_chat/l10n/app_localizations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'package:tgm_ai_chat/core/services/plan_enforcement_service.dart';
import 'package:tgm_ai_chat/features/chat/widgets/plan_quota_widget.dart';
import 'package:tgm_ai_chat/core/services/pocketbase_auth_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final _keyboardFocusNode =
      FocusNode(); // Dedicated focus node for keyboard listener
  XFile? _selectedImage;
  bool _isRecording = false;
  bool _hasText = false;
  bool _isFocused = false;
  bool _showScrollToBottomButton = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _suggestionSeed = 0;
  final AudioRecordingService _audioRecordingService = AudioRecordingService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Audio recording UI state
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndInitialize();
    // Initialize with a random seed
    _suggestionSeed = DateTime.now().millisecondsSinceEpoch;

    // Listen to text changes
    _messageController.addListener(_onTextChanged);

    // Listen to focus changes
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _onFocusChanged() {
    final isFocused = _focusNode.hasFocus;
    if (isFocused != _isFocused) {
      setState(() {
        _isFocused = isFocused;
      });
    }
  }


  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildScrollToBottomButton() {
    return AnimatedScale(
      scale: _showScrollToBottomButton ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6), // Transparent dark grey
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: _scrollToBottom,
            child: const Icon(
              Icons.arrow_downward,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _playSoundFeedback() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/message_notification.wav'));
    } catch (e) {
      //debugPrint('Failed to play sound feedback: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _startRecordingTimer() {
    _recordingDuration = Duration.zero;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordingDuration = Duration(seconds: timer.tick);
        });
      }
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  Future<void> _checkAuthenticationAndInitialize() async {
    // Check authentication first
    final isAuthenticated = await AuthGuard.checkAuthAndRedirect(context);

    if (isAuthenticated && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await context.read<ChatProvider>().initialize();
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _keyboardFocusNode.dispose();
    _recordingTimer?.cancel();
    // Cancel any ongoing recording
    _audioRecordingService.cancelRecording();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      // ✅ NOUVEAU: Ferme le clavier quand on tap ailleurs
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _buildAppBar(l10n),
        drawer: _buildDrawer(l10n),
        resizeToAvoidBottomInset: true,
        body: ResponsiveWidget(
          mobile: _buildMobileLayout(context, l10n),
          tablet: _buildTabletLayout(context, l10n),
          desktop: _buildDesktopLayout(context, l10n),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.notes),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: const SizedBox(),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_comment_outlined),
          onPressed: _createNewConversation,
          tooltip: l10n.newConversation,
        ),
      ],
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
      elevation: 0,
      systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  Widget _buildDrawer(AppLocalizations l10n) {
    return Drawer(
      child: Column(
        children: [
          // Header with conversation history title
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
            child: Row(
              children: [
                const Icon(Icons.history, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.conversationHistory,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Conversation history list
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final conversations = chatProvider.getSortedConversations();

                if (conversations.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        l10n.noConversationsInHistory,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    final isCurrentConversation =
                        conversation.id == chatProvider.currentConversationId;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCurrentConversation
                            ? Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.chat_bubble_outline,
                          size: 20,
                          color: isCurrentConversation
                              ? Theme.of(context).primaryColor
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                        ),
                        title: Text(
                          conversation.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrentConversation
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          _formatDate(conversation.lastMessageAt, l10n),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: isCurrentConversation
                            ? Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              )
                            : null,
                        onTap: isCurrentConversation
                            ? null
                            : () async {
                                await chatProvider
                                    .switchToConversation(conversation.id);
                                if (mounted) {
                                  Navigator.pop(context);
                                }
                              },
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // View Full History button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/history');
                },
                icon: const Icon(Icons.history, size: 18),
                label: Text(l10n.viewFullHistory),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),

          // Profile settings at the bottom
          Container(
            //ajout du padding inférieur dynamique
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.paddingOf(context).bottom, 
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                final userProfile = profileProvider.userProfile;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: userProfile?.avatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              userProfile!.avatarUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  userProfile.initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                );
                              },
                            ),
                          )
                        : Text(
                            userProfile?.initials ?? 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                  title: Text(
                    userProfile?.name ?? 'User',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    l10n.profile,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  trailing: const Icon(Icons.settings),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/profile');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // ========================================
        // WIDGET DE QUOTA (NOUVEAU)
        // ========================================
        Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            if (chatProvider.isPocketBaseUser) {
              final authService = PocketBaseAuthService();
              final userId = authService.currentUser?['id'];
              
              if (userId != null) {
                return PlanQuotaWidget(userId: userId);
              }
            }
            return const SizedBox.shrink();
          },
        ),
        // ========================================
        // FIN WIDGET DE QUOTA
        // ========================================
        
        Expanded(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(child: _buildMessagesArea(l10n)),
                  if (_selectedImage != null) _buildImagePreview(l10n),
                ],
              ),
              // Scroll to bottom button positioned just above message input
              Positioned(
                bottom: 20, // Much closer to the message input area
                left: 0,
                right: 0,
                child: Center(
                  child: _buildScrollToBottomButton(),
                ),
              ),
            ],
          ),
        ),
        _buildMessageInput(l10n),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            // ========================================
            // WIDGET DE QUOTA (NOUVEAU)
            // ========================================
            Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isPocketBaseUser) {
                  final authService = PocketBaseAuthService();
                  final userId = authService.currentUser?['id'];
                  
                  if (userId != null) {
                    return PlanQuotaWidget(userId: userId);
                  }
                }
                return const SizedBox.shrink();
              },
            ),
            // ========================================
            
            Expanded(
              child: Stack(
                children: [
                  _buildMessagesArea(l10n),
                  // Scroll to bottom button positioned above message input
                  Positioned(
                    bottom: 80, // Position above the message input area
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _buildScrollToBottomButton(),
                    ),
                  ),
                ],
              ),
            ),
            _buildMessageInput(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        // ========================================
        // WIDGET DE QUOTA (NOUVEAU)
        // ========================================
        Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            if (chatProvider.isPocketBaseUser) {
              final authService = PocketBaseAuthService();
              final userId = authService.currentUser?['id'];
              
              if (userId != null) {
                return PlanQuotaWidget(userId: userId);
              }
            }
            return const SizedBox.shrink();
          },
        ),
        // ========================================
        
        Expanded(
          child: Stack(
            children: [
              _buildMessagesArea(l10n),
              // Scroll to bottom button positioned just above message input
              Positioned(
                bottom: 20, // Much closer to the message input area
                left: 0,
                right: 0,
                child: Center(
                  child: _buildScrollToBottomButton(),
                ),
              ),
            ],
          ),
        ),
        _buildMessageInput(l10n),
      ],
    );
  }

  Widget _buildMessagesArea(AppLocalizations l10n) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        // Show loading indicator while messages are loading
        if (chatProvider.isLoadingMessages) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Show welcome message when no messages
        if (chatProvider.messages.isEmpty && !chatProvider.isTyping) {
          return SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.3,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.whatCanIHelpYouWith,
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: ResponsiveUtils.getFontSize(context, 24),
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.9),
                        height: 1.3,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),
                    _buildSuggestionButtons(),
                  ],
                ),
              ),
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && !_showScrollToBottomButton) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification is ScrollUpdateNotification || notification is ScrollEndNotification) {
              final maxScrollExtent = notification.metrics.maxScrollExtent;
              final currentPosition = notification.metrics.pixels;
              const threshold = 100.0; // Show button when 100px away from bottom
              
              final distanceFromBottom = maxScrollExtent - currentPosition;
              final shouldShowButton = distanceFromBottom > threshold;
              
              if (shouldShowButton != _showScrollToBottomButton) {
                setState(() {
                  _showScrollToBottomButton = shouldShowButton;
                });
              }
            }
            return false; // Allow the notification to continue
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
              itemCount:
                  chatProvider.messages.length + (chatProvider.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatProvider.messages.length &&
                    chatProvider.isTyping) {
                  return const TypingIndicator();
                }

                final message = chatProvider.messages[index];
                return MessageBubble(
                  key: ValueKey(message.id), // Ajoutez cette ligne
                  message: message,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecordingWidget(AppLocalizations l10n) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isRecording ? 50 : 0,
      child: _isRecording
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Animated recording dot with pulsing effect
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween<double>(begin: 0.8, end: 1.2),
                    builder: (context, double scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    onEnd: () {
                      // Restart animation if still recording
                      if (mounted && _isRecording) {
                        setState(() {
                          // This will trigger the animation to restart
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  // Recording text and duration
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          l10n.recording,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDuration(_recordingDuration),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Waveform animation
                  Row(
                    children: List.generate(4, (index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        height: [12.0, 18.0, 15.0, 14.0][index],
                        width: 2,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 12),
                  // Cancel button
                  GestureDetector(
                    onTap: () async {
                      await _audioRecordingService.cancelRecording();
                      _stopRecordingTimer();
                      setState(() {
                        _isRecording = false;
                        _recordingDuration = Duration.zero;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildMessageInput(AppLocalizations l10n) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _buildRecordingWidget(l10n),
      Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(
              color: AppTheme.borderGrey.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          minimum: EdgeInsets.zero,
          child: Row(
            children: [
              _buildAttachmentButton(l10n),
              const SizedBox(width: 10),
              Expanded(
                child: KeyboardListener(
                  focusNode: _keyboardFocusNode,
                  onKeyEvent: (KeyEvent event) {
                    if (event is KeyDownEvent &&
                        event.logicalKey == LogicalKeyboardKey.enter &&
                        !HardwareKeyboard.instance.isShiftPressed) {
                      _sendMessage(l10n);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: _isFocused
                            ? AppTheme.primaryGreen
                            : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            focusNode: _focusNode,
                            maxLines: null,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.send,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (value) => _sendMessage(l10n),
                            decoration: InputDecoration(
                              hintText: l10n.typeYourMessage,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        _buildActionButton(l10n),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  Widget _buildActionButton(AppLocalizations l10n) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final buttonSize = ResponsiveUtils.isDesktop(context) ? 40.0 : 36.0;
        final iconSize = ResponsiveUtils.isDesktop(context) ? 20.0 : 18.0;

        return Container(
          margin: EdgeInsets.only(right: 8.w),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },
            child: _hasText
                ? _buildSendButton(chatProvider, buttonSize, iconSize, l10n)
                : _buildMicrophoneButton(buttonSize, iconSize, l10n),
          ),
        );
      },
    );
  }

  Widget _buildSendButton(
      ChatProvider chatProvider, double buttonSize, double iconSize, AppLocalizations l10n) {
    final loaderSize = ResponsiveUtils.isDesktop(context) ? 18.0 : 16.0;

    return Container(
      key: const ValueKey('send'),
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(buttonSize / 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(buttonSize / 2),
          onTap: chatProvider.isTyping ? null : () => _sendMessage(l10n),
          child: Center(
            child: chatProvider.isTyping
                ? SizedBox(
                    width: loaderSize,
                    height: loaderSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.arrow_upward,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: iconSize,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildMicrophoneButton(
      double buttonSize, double iconSize, AppLocalizations l10n) {
    return Container(
      key: const ValueKey('microphone'),
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: _isRecording
            ? Colors.red.withValues(alpha: 0.2)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(buttonSize / 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(buttonSize / 2),
          onTap: () => _toggleVoiceRecording(l10n),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              key: ValueKey(_isRecording),
              color: _isRecording
                  ? Colors.red
                  : Theme.of(context).colorScheme.onSurface,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentButton(AppLocalizations l10n) {
    final buttonSize = ResponsiveUtils.isDesktop(context) ? 44.0 : 41.0;
    final iconSize = ResponsiveUtils.isDesktop(context) ? 22.0 : 20.0;

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: Builder(builder: (buttonContext) {
        return Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(buttonSize / 2),
          child: InkWell(
            borderRadius: BorderRadius.circular(buttonSize / 2),
            onTap: () => _showAttachmentMenu(buttonContext, l10n),
            child: Icon(
              Icons.add,
              color: AppTheme.textGrey,
              size: iconSize,
            ),
          ),
        );
      }),
    );
  }

  static final List<Map<String, dynamic>> _allSuggestions = [
    // Turbine & Generator Systems (20 suggestions)
    {
      'text': 'Explain how hydroelectric turbines work',
      'icon': Icons.precision_manufacturing
    },
    {
      'text': 'Compare Pelton vs Francis turbines',
      'icon': Icons.compare_arrows
    },
    {'text': 'Calculate turbine efficiency formulas', 'icon': Icons.calculate},
    {
      'text': 'Design considerations for Kaplan turbines',
      'icon': Icons.settings
    },
    {'text': 'Generator synchronization in hydro plants', 'icon': Icons.sync},
    {'text': 'Turbine blade design optimization', 'icon': Icons.architecture},
    {'text': 'Water flow rate calculations', 'icon': Icons.water_drop},
    {'text': 'Power coefficient optimization', 'icon': Icons.trending_up},
    {'text': 'Turbine selection criteria', 'icon': Icons.checklist},
    {
      'text': 'Runner design for maximum efficiency',
      'icon': Icons.precision_manufacturing
    },
    {'text': 'Wicket gate control mechanisms', 'icon': Icons.tune},
    {'text': 'Draft tube design principles', 'icon': Icons.view_in_ar},
    {'text': 'Turbine cavitation prevention', 'icon': Icons.bubble_chart},
    {'text': 'Speed regulation systems', 'icon': Icons.speed},
    {'text': 'Turbine startup procedures', 'icon': Icons.play_arrow},
    {'text': 'Generator cooling systems', 'icon': Icons.ac_unit},
    {'text': 'Excitation system design', 'icon': Icons.flash_on},
    {'text': 'Turbine vibration analysis', 'icon': Icons.vibration},
    {'text': 'Governor system operation', 'icon': Icons.tune},
    {'text': 'Penstock velocity calculations', 'icon': Icons.trending_up},

    // Dam & Civil Engineering (20 suggestions)
    {
      'text': 'Design considerations for dam construction',
      'icon': Icons.architecture
    },
    {'text': 'Concrete dam stress analysis', 'icon': Icons.analytics},
    {'text': 'Earth dam seepage control', 'icon': Icons.water_damage},
    {'text': 'Dam foundation requirements', 'icon': Icons.foundation},
    {'text': 'Spillway design calculations', 'icon': Icons.water},
    {'text': 'Embankment dam stability', 'icon': Icons.landscape},
    {'text': 'Reservoir capacity estimation', 'icon': Icons.storage},
    {'text': 'Dam safety monitoring systems', 'icon': Icons.security},
    {'text': 'Uplift pressure calculations', 'icon': Icons.arrow_upward},
    {'text': 'Buttress dam design principles', 'icon': Icons.construction},
    {'text': 'Rockfill dam construction', 'icon': Icons.terrain},
    {'text': 'Dam instrumentation systems', 'icon': Icons.sensors},
    {'text': 'Seismic analysis of dams', 'icon': Icons.waves},
    {'text': 'Concrete mix design for dams', 'icon': Icons.blender},
    {'text': 'Dam deformation monitoring', 'icon': Icons.straighten},
    {'text': 'Outlet works design', 'icon': Icons.outbound},
    {'text': 'Fish ladder construction', 'icon': Icons.stairs},
    {'text': 'Dam rehabilitation techniques', 'icon': Icons.build},
    {'text': 'Grouting procedures for dams', 'icon': Icons.format_paint},
    {'text': 'Dam break analysis methods', 'icon': Icons.broken_image},

    // Power & Energy Calculations (20 suggestions)
    {
      'text': 'Calculate power output for a hydro plant',
      'icon': Icons.calculate
    },
    {'text': 'Energy production forecasting', 'icon': Icons.timeline},
    {
      'text': 'Head loss calculations in penstocks',
      'icon': Icons.trending_down
    },
    {'text': 'Plant capacity factor analysis', 'icon': Icons.pie_chart},
    {
      'text': 'Economic analysis of hydro projects',
      'icon': Icons.monetization_on
    },
    {'text': 'Load duration curve analysis', 'icon': Icons.show_chart},
    {
      'text': 'Peak power demand calculations',
      'icon': Icons.electrical_services
    },
    {
      'text': 'Energy storage system sizing',
      'icon': Icons.battery_charging_full
    },
    {'text': 'Grid integration requirements', 'icon': Icons.grid_on},
    {'text': 'Power quality assessment', 'icon': Icons.high_quality},
    {'text': 'Transmission line design', 'icon': Icons.power},
    {'text': 'Transformer sizing calculations', 'icon': Icons.transform},
    {'text': 'Reactive power compensation', 'icon': Icons.balance},
    {'text': 'Harmonic analysis in power systems', 'icon': Icons.graphic_eq},
    {'text': 'Protection system design', 'icon': Icons.shield},
    {'text': 'SCADA system implementation', 'icon': Icons.computer},
    {'text': 'Power factor correction methods', 'icon': Icons.auto_fix_high},
    {'text': 'Voltage regulation techniques', 'icon': Icons.tune},
    {'text': 'Frequency control in isolated grids', 'icon': Icons.radio},
    {'text': 'Economic dispatch optimization', 'icon': Icons.auto_awesome},

    // Efficiency & Optimization (20 suggestions)
    {'text': 'Efficiency optimization in water turbines', 'icon': Icons.speed},
    {'text': 'Plant performance monitoring', 'icon': Icons.monitor},
    {'text': 'Maintenance scheduling optimization', 'icon': Icons.schedule},
    {'text': 'Wear analysis of turbine components', 'icon': Icons.timeline},
    {'text': 'Condition monitoring systems', 'icon': Icons.health_and_safety},
    {'text': 'Predictive maintenance strategies', 'icon': Icons.psychology},
    {'text': 'Energy loss minimization', 'icon': Icons.minimize},
    {'text': 'Operational efficiency metrics', 'icon': Icons.assessment},
    {'text': 'Performance curve analysis', 'icon': Icons.insights},
    {'text': 'Plant automation systems', 'icon': Icons.smart_toy},
    {'text': 'Remote monitoring solutions', 'icon': Icons.wifi},
    {
      'text': 'Diagnostic system implementation',
      'icon': Icons.medical_services
    },
    {'text': 'Efficiency testing procedures', 'icon': Icons.fact_check},
    {'text': 'Performance improvement strategies', 'icon': Icons.trending_up},
    {'text': 'Energy audit methodologies', 'icon': Icons.energy_savings_leaf},
    {'text': 'Plant upgrade considerations', 'icon': Icons.upgrade},
    {'text': 'Modern control system benefits', 'icon': Icons.smart_button},
    {'text': 'Digital twin implementation', 'icon': Icons.account_tree},
    {'text': 'AI-based optimization techniques', 'icon': Icons.psychology},
    {
      'text': 'Machine learning for predictive maintenance',
      'icon': Icons.model_training
    },

    // Environmental & Sustainability (20 suggestions)
    {'text': 'Environmental impact of hydropower systems', 'icon': Icons.eco},
    {'text': 'Fish migration solutions', 'icon': Icons.pets},
    {'text': 'Sediment management strategies', 'icon': Icons.grain},
    {'text': 'Water quality monitoring', 'icon': Icons.water_drop},
    {'text': 'Ecosystem restoration methods', 'icon': Icons.forest},
    {'text': 'Carbon footprint of hydro plants', 'icon': Icons.co2},
    {'text': 'Biodiversity impact assessment', 'icon': Icons.bug_report},
    {'text': 'Sustainable construction practices', 'icon': Icons.nature},
    {'text': 'Renewable energy integration', 'icon': Icons.solar_power},
    {'text': 'Climate change adaptation', 'icon': Icons.thermostat},
    {'text': 'Environmental monitoring systems', 'icon': Icons.eco_outlined},
    {'text': 'Waste management in construction', 'icon': Icons.recycling},
    {'text': 'Green building certification', 'icon': Icons.verified},
    {'text': 'Ecological flow requirements', 'icon': Icons.stream},
    {'text': 'Habitat connectivity solutions', 'icon': Icons.link},
    {'text': 'Noise pollution mitigation', 'icon': Icons.volume_off},
    {'text': 'Visual impact assessment', 'icon': Icons.visibility},
    {'text': 'Stakeholder engagement strategies', 'icon': Icons.groups},
    {'text': 'Environmental compliance requirements', 'icon': Icons.gavel},
    {'text': 'Sustainability reporting standards', 'icon': Icons.assignment},
  ];

  Widget _buildSuggestionButtons() {
    // Get 5 random suggestions using the seed for consistent regeneration
    final random = math.Random(_suggestionSeed);
    final selectedSuggestions = <Map<String, dynamic>>[];
    final availableIndices =
        List.generate(_allSuggestions.length, (index) => index);

    for (int i = 0; i < 5 && availableIndices.isNotEmpty; i++) {
      final randomIndex = random.nextInt(availableIndices.length);
      final suggestionIndex = availableIndices.removeAt(randomIndex);
      selectedSuggestions.add(_allSuggestions[suggestionIndex]);
    }

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      alignment: WrapAlignment.center,
      children: selectedSuggestions
          .map((suggestion) => _buildSuggestionButton(
              suggestion['text'] as String, suggestion['icon'] as IconData))
          .toList(),
    );
  }

  Widget _buildSuggestionButton(String suggestion, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onSuggestionTapped(suggestion),
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .shadow
                    .withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  suggestion,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 14),
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                icon,
                size: 18,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSuggestionTapped(String suggestion) {
    // Set the suggestion as the message and send it
    _messageController.text = suggestion;
    final l10n = AppLocalizations.of(context)!;
    _sendMessage(l10n);
  }

  void _showAttachmentMenu(BuildContext menuContext, AppLocalizations l10n) {
    showModalBottomSheet(
      context: menuContext,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l10n.gallery),
                onTap: () {
                  _pickImage(ImageSource.gallery, menuContext);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(l10n.camera),
                onTap: () {
                  _pickImage(ImageSource.camera, menuContext);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    final picker = ImagePicker();
    
    final pickedFile = await picker.pickImage(
      source: source,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${l10n.today} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays.toString());
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _toggleVoiceRecording(AppLocalizations l10n) async {
    // Add haptic feedback for better user experience
    HapticFeedback.lightImpact();

    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      // Play feedback sound first
      _playSoundFeedback();

      // Wait a brief moment and stop audio player to ensure resources are free
      await Future.delayed(const Duration(milliseconds: 100));
      try {
        await _audioPlayer.stop();
      } catch (e) {
        // Ignore errors when stopping audio player
      }

      // Start recording
      _startRecordingTimer();
      await _startVoiceRecording(l10n);
    } else {
      // Stop recording and send
      _stopRecordingTimer();
      await _stopVoiceRecording(l10n);

      // Play feedback sound after stopping recording
      _playSoundFeedback();
    }
  }

  Future<void> _startVoiceRecording(AppLocalizations l10n) async {
    try {
      //debugPrint('Starting voice recording...');

      // Check and request permissions first
      bool hasPermission = await _audioRecordingService.hasPermission();
      if (!hasPermission) {
        hasPermission = await _audioRecordingService.requestPermission();
        if (!hasPermission) {
          //debugPrint('Recording permission denied');
          _showPermissionDeniedDialog(l10n);
          setState(() {
            _isRecording = false;
          });
          return;
        }
      }

      // Start recording
      final success = await _audioRecordingService.startRecording();
      if (!success) {
        //debugPrint('Failed to start recording');
        _stopRecordingTimer();
        setState(() {
          _isRecording = false;
        });
      } else {
        //debugPrint('Recording started successfully');
      }
    } catch (e) {
      //debugPrint('Failed to start recording: $e');
      _stopRecordingTimer();
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _stopVoiceRecording(AppLocalizations l10n) async {
    try {
      //debugPrint('Stopping voice recording...');

      // Stop recording and get result
      final recordingResult = await _audioRecordingService.stopRecording();

      if (recordingResult != null && mounted) {
        //debugPrint('Recording saved to: ${recordingResult.path}, duration: ${recordingResult.duration}s');

        // Send the real audio message
        context.read<ChatProvider>().sendAudioMessage(
          recordingResult.path,
          duration: recordingResult.duration,
          transcription: null,
          context: context,
        );
      } else {
        //debugPrint('Failed to stop recording or get result');
        // Show error message to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToSaveRecording),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      //debugPrint('Failed to stop recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.recordingError(e.toString())),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showPermissionDeniedDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permissionDenied),
        content: Text(l10n.permissionDeniedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  void _createNewConversation() async {
    // Create a new conversation (this will save the current one automatically)
    await context.read<ChatProvider>().createNewConversation();

    // Clear any selected image and regenerate suggestions
    setState(() {
      _selectedImage = null;
      _messageController.clear();
      // Generate new seed to get different suggestions
      _suggestionSeed = DateTime.now().millisecondsSinceEpoch;
    });
  }

  void _sendMessage(AppLocalizations l10n) {
    if (_messageController.text.trim().isEmpty && _selectedImage == null) {
      return;
    }
    context.read<ChatProvider>().sendMessage(
          _messageController.text,
          imageXFile: _selectedImage,
          context: context,
        );
    setState(() {
      _selectedImage = null;
      _messageController.clear();
    });
    _focusNode.requestFocus();
  }

  Widget _buildImagePreview(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: kIsWeb
                ? Image.network(
                    _selectedImage!.path,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(_selectedImage!.path),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.photoLibrary,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _selectedImage = null;
              });
            },
          ),
        ],
      ),
    );
  }
}