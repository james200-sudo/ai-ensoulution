import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/chat_provider.dart';
import '../models/conversation.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation History'),
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
                    'No conversations in history',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Start chatting to see your conversation history here',
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
                        '${conversation.messages.length} messages',
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
                        _formatDate(conversation.lastMessageAt),
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
                          'Current',
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
                        const PopupMenuItem<String>(
                          value: 'switch',
                          child: Row(
                            children: [
                              Icon(Icons.chat, size: 18),
                              SizedBox(width: 8),
                              Text('Switch to this conversation'),
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
                              'Delete conversation',
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

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ChatProvider chatProvider,
    Conversation conversation,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this conversation?'),
            SizedBox(height: 8.h),
            Text(
              '"${conversation.title}"',
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await chatProvider.deleteConversation(conversation.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Conversation deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
