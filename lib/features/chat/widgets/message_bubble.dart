import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../models/message.dart';
import 'audio_wave_animation.dart';
import 'streaming_text_widget.dart';
import 'package:flutter/services.dart';
import '../providers/chat_provider.dart';
import 'dart:convert';

class MessageBubble extends StatefulWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isPlaying = false;
  AudioPlayer? _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String _selectedText = '';
  bool _showExplainButton = false;

  @override
  void initState() {
    super.initState();
    if (widget.message.audioUrl != null) {
      _initializeAudioPlayer();
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();

    _audioPlayer!.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _audioPlayer!.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioPlayer!.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message.isUser) {
      return _buildUserMessage(context);
    } else {
      return _buildAIMessage(context);
    }
  }

  Widget _buildUserMessage(BuildContext context) {
    // Check message type
    final hasText = widget.message.content.isNotEmpty;
    final hasImage = widget.message.imageUrl != null || widget.message.imageData != null;
    final hasAudio = widget.message.audioUrl != null;
    final isTextOnly = hasText && !hasImage && !hasAudio;
    final hasImageWithText = hasImage && hasText;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Image without bubble (when there's both image and text)
                if (hasImageWithText) ...[
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveUtils.isDesktop(context)
                          ? 280
                          : MediaQuery.sizeOf(context).width * 0.7,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18.r),
                      child: _buildMessageImage(widget.message),
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
                // Container for text bubble and other content
                Container(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveUtils.isDesktop(context)
                        ? 280
                        : MediaQuery.sizeOf(context).width * 0.7,
                  ),
                  padding: (isTextOnly || hasImageWithText)
                      ? EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h)
                      : EdgeInsets.zero,
                  decoration: (isTextOnly || hasImageWithText)
                      ? BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18.r),
                            topRight: Radius.circular(18.r),
                            bottomLeft: Radius.circular(18.r),
                            bottomRight: Radius.circular(4.r),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        )
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image with bubble (when there's no text or only image)
                      if (hasImage && !hasImageWithText) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(18.r),
                            bottom: Radius.circular(
                                widget.message.content.isEmpty ? 18.r : 0),
                          ),
                          child: _buildMessageImage(widget.message),
                        ),
                        if (widget.message.content.isNotEmpty)
                          SizedBox(height: 8.h),
                      ],
                      if (widget.message.audioUrl != null) ...[
                        _buildAudioPlayer(isUserMessage: true),
                        if (widget.message.content.isNotEmpty)
                          SizedBox(height: 8.h),
                      ],
                      if (widget.message.content.isNotEmpty)
                        Text(
                          widget.message.content,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveUtils.getFontSize(context, 14),
                            height: 1.4,
                          ),
                        ),
                      if (isTextOnly || hasImageWithText)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(widget.message.timestamp),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: ResponsiveUtils.getFontSize(context, 11),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                _getStatusIcon(widget.message.status),
                                size: 12.sp,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIMessage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                if (widget.message.audioUrl != null) ...[
                  _buildAudioPlayer(isUserMessage: false),
                  SizedBox(height: 8.h),
                ],
                if (widget.message.content.isNotEmpty)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      StreamingTextWidget(
                        fullText: widget.message.content,
                        isStreaming:
                            widget.message.status == MessageStatus.streaming,
                        baseStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: ResponsiveUtils.getFontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                        boldStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: ResponsiveUtils.getFontSize(context, 16),
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Comic Sans MS',
                          fontFamilyFallback: const [
                            'Comic Sans',
                            'Chalkduster',
                            'Bradley Hand',
                            'cursive'
                          ],
                          height: 1.5,
                        ),
                        italicStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: ResponsiveUtils.getFontSize(context, 16),
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Comic Sans MS',
                          fontFamilyFallback: const [
                            'Comic Sans',
                            'Chalkduster',
                            'Bradley Hand',
                            'cursive'
                          ],
                          height: 1.5,
                        ),
                        codeStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: ResponsiveUtils.getFontSize(context, 14),
                          fontWeight: FontWeight.w400,
                          fontFamily: 'monospace',
                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                          height: 1.3,
                        ),
                        onSelectionChanged: (selection, cause) {
                          if (selection.isValid && !selection.isCollapsed) {
                            setState(() {
                              _selectedText =
                                  selection.textInside(widget.message.content);
                              _showExplainButton =
                                  _selectedText.trim().isNotEmpty;
                            });
                            //debugPrint('Text selected: "$_selectedText"');
                          } else {
                            setState(() {
                              _selectedText = '';
                              _showExplainButton = false;
                            });
                          }
                        },
                      ),
                      // Custom floating button for all platforms
                      if (_showExplainButton)
                        Positioned(
                          top: -40,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: _selectedText));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Text copied to clipboard'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy,
                                      color: Colors.white, size: 16),
                                  tooltip: 'Copy',
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await _explainSelectedText(
                                        context, _selectedText);
                                    setState(() {
                                      _showExplainButton = false;
                                      _selectedText = '';
                                    });
                                  },
                                  icon: const Icon(Icons.auto_awesome,
                                      color: Colors.white, size: 16),
                                  tooltip: 'Explain with AI',
                                  constraints: const BoxConstraints(
                                      minWidth: 32, minHeight: 32),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                SizedBox(height: 4.h),
                Text(
                  _formatTime(widget.message.timestamp),
                  style: TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: ResponsiveUtils.getFontSize(context, 11),
                  ),
                ),
              ],
      ),
    );
  }

  Widget _buildAudioPlayer({required bool isUserMessage}) {
    // Check if this is a transparent audio-only message
    final isTransparentAudioMessage = isUserMessage &&
        widget.message.audioUrl != null &&
        widget.message.content.isEmpty;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isTransparentAudioMessage
            ? AppTheme
                .primaryGreen // Use primary color for transparent audio messages
            : (isUserMessage
                ? Colors.white.withValues(alpha: 0.1)
                : Theme.of(context).cardColor),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: isTransparentAudioMessage
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _toggleAudioPlayback,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isUserMessage
                    ? Colors.white.withValues(alpha: 0.2)
                    : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: (isUserMessage || isTransparentAudioMessage)
                    ? Colors.white
                    : Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AudioWaveAnimation(
                  isPlaying: _isPlaying,
                  color: (isUserMessage || isTransparentAudioMessage)
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                  height: 20,
                  width: 120,
                ),
                if (widget.message.audioDuration != null)
                  Text(
                    _formatDuration(widget.message.audioDuration!),
                    style: TextStyle(
                      color: (isUserMessage || isTransparentAudioMessage)
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppTheme.textGrey,
                      fontSize: ResponsiveUtils.getFontSize(context, 10),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAudioPlayback() async {
    if (_audioPlayer == null || widget.message.audioUrl == null) {
      //debugPrint('No audio player or URL available');
      return;
    }

    try {
      if (_isPlaying) {
        // Pause audio
        await _audioPlayer!.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        // Play audio
        if (_position == _duration && _duration != Duration.zero) {
          // Restart from beginning if completed
          await _audioPlayer!.seek(Duration.zero);
        }

        // Try to play the audio file
        final audioUrl = widget.message.audioUrl!;
        //debugPrint('Attempting to play audio file: $audioUrl');

        try {
          if (kIsWeb) {
            // On web, try to play as a URL source
            //debugPrint( 'Web platform detected - attempting URL source playback');
            await _audioPlayer!.play(UrlSource(audioUrl));
          } else {
            // For mobile/desktop platforms
            final file = File(audioUrl);
            if (await file.exists()) {
              //debugPrint('File exists, playing audio file: $audioUrl');
              await _audioPlayer!.play(DeviceFileSource(audioUrl));
            } else {
              //debugPrint('File does not exist: $audioUrl');
              throw Exception('Audio file not found at: $audioUrl');
            }
          }

          setState(() {
            _isPlaying = true;
          });
          //debugPrint('Successfully started playing audio file');
        } catch (playError) {
          //debugPrint('Failed to play audio file: $playError');
          throw Exception('Audio playback failed: $playError');
        }
      }
    } catch (e) {
      //debugPrint('Error with real audio playback, falling back to simulation: $e');

      // Safe fallback: simulate playback for demo purposes
      if (mounted) {
        setState(() {
          _isPlaying = !_isPlaying;
        });

        if (_isPlaying) {
          // Simulate audio duration
          final duration = widget.message.audioDuration ?? 3;
          Future.delayed(Duration(seconds: duration), () {
            if (mounted) {
              setState(() {
                _isPlaying = false;
              });
            }
          });
        }
      }
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildMessageImage(Message message) {
    // Priority: imageData (for web persistence) > imageUrl (for fresh images)
    if (kIsWeb && message.imageData != null) {
      // ✅ Vérifier si c'est une base64 ou une URL
      if (message.imageData!.startsWith('data:image')) {
        // Décoder base64
        try {
          final base64String = message.imageData!.split(',')[1];
          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to imageUrl if base64 fails
              if (message.imageUrl != null) {
                return Image.network(
                  message.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              }
              return Container(
                height: 150,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              );
            },
          );
        } catch (e) {
          //debugPrint('Erreur décodage base64: $e');
          // Fallback to imageUrl
          if (message.imageUrl != null) {
            return Image.network(
              message.imageUrl!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            );
          }
        }
      } else {
        // C'est une URL classique
        return Image.network(
          message.imageData!,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            if (message.imageUrl != null) {
              return Image.network(
                message.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              );
            }
            return Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            );
          },
        );
      }
    } else if (message.imageUrl != null) {
      return kIsWeb
          ? Image.network(
              message.imageUrl!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Image.file(
              File(message.imageUrl!),
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            );
    }

    // Fallback if no image data available
    return Container(
      height: 150,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }


  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
      case MessageStatus.streaming:
        return Icons.more_horiz;
    }
  }

  Future<void> _explainSelectedText(
      BuildContext context, String selectedText) async {
    if (selectedText.trim().isEmpty) return;

    final chatProvider = context.read<ChatProvider>();

    // Send the explanation request as a new message
    await chatProvider.sendMessage(selectedText, context: context);
  }
}
