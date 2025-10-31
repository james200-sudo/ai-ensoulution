import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/chat_provider.dart';
import '../models/conversation.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.conversationHistory),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          final conversations = chatProvider.getSortedConversations();

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64.sp,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    l10n.noConversationsInHistory,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    l10n.startChattingToSeeHistory,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final isCurrentConversation =
                  conversation.id == chatProvider.currentConversationId;

              return Card(
                margin: EdgeInsets.only(bottom: 8.h),
                elevation: 1,
                child: ListTile(
                  dense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCurrentConversation
                          ? AppTheme.primaryGreen
                          : AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      _getConversationIcon(conversation),
                      color: isCurrentConversation
                          ? Colors.white
                          : AppTheme.primaryGreen,
                      size: 14,
                    ),
                  ),
                  title: Text(
                    conversation.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color:
                          isCurrentConversation ? AppTheme.primaryGreen : null,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        l10n.messagesCount(conversation.messages.length.toString()),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        _formatDate(context, conversation.lastMessageAt),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey,
                        ),
                      ),
                      if (isCurrentConversation) ...[
                        Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          l10n.current,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'switch') {
                        await chatProvider
                            .switchToConversation(conversation.id);
                        if (context.mounted) {
                          context.pop();
                        }
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(
                            context, chatProvider, conversation);
                      }
                    },
                    itemBuilder: (context) => [
                      if (!isCurrentConversation)
                        PopupMenuItem<String>(
                          value: 'switch',
                          child: Row(
                            children: [
                              const Icon(Icons.chat, size: 18),
                              const SizedBox(width: 8),
                              Text(l10n.switchToConversation),
                            ],
                          ),
                        ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.deleteConversation,
                              style: TextStyle(
                                color: Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.grey.shade600,
                      size: 14.sp,
                    ),
                  ),
                  onTap: isCurrentConversation
                      ? () => context.pop()
                      : () async {
                          await chatProvider
                              .switchToConversation(conversation.id);
                          if (context.mounted) {
                            context.pop();
                          }
                        },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getConversationIcon(Conversation conversation) {
    // Check if conversation starts with an audio message
    if (conversation.messages.isNotEmpty) {
      final firstUserMessage = conversation.messages.firstWhere(
        (message) => message.isUser,
        orElse: () => conversation.messages.first,
      );

      if (firstUserMessage.audioUrl != null) {
        return Icons.mic;
      }

      if (firstUserMessage.imageUrl != null ||
          firstUserMessage.imageData != null) {
        return Icons.image;
      }
    }

    return Icons.chat_bubble_outline;
  }

  String _formatDate(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes.toString());
    } else if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours.toString());
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays.toString());
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ChatProvider chatProvider,
    Conversation conversation,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteConversation),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deleteConversationConfirmation),
            SizedBox(height: 8.h),
            Text(
              '"${conversation.title}"',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.thisActionCannotBeUndone,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await chatProvider.deleteConversation(conversation.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.conversationDeleted),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}
