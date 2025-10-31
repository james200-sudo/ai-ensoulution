import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/utils/responsive.dart';
import 'rich_text_parser.dart';

class StreamingTextWidget extends StatefulWidget {
  final String fullText;
  final TextStyle? baseStyle;
  final TextStyle? boldStyle;
  final TextStyle? italicStyle;
  final TextStyle? codeStyle;
  final bool isStreaming;
  final Duration streamingSpeed;
  final VoidCallback? onStreamingComplete;
  final Function(TextSelection, SelectionChangedCause?)? onSelectionChanged;

  const StreamingTextWidget({
    super.key,
    required this.fullText,
    this.baseStyle,
    this.boldStyle,
    this.italicStyle,
    this.codeStyle,
    this.isStreaming = false,
    this.streamingSpeed = const Duration(milliseconds: 20),
    this.onStreamingComplete,
    this.onSelectionChanged,
  });

  @override
  State<StreamingTextWidget> createState() => _StreamingTextWidgetState();
}

class _StreamingTextWidgetState extends State<StreamingTextWidget> {
  String _displayedText = '';
  Timer? _streamingTimer;
  int _currentIndex = 0;
  bool _hasCompletedStreaming = false;

  @override
  void initState() {
    super.initState();
    _initializeStreaming();
  }

  @override
  void didUpdateWidget(StreamingTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fullText != widget.fullText) {
      _initializeStreaming();
    }
  }

  void _initializeStreaming() {
    _streamingTimer?.cancel();
    
    if (widget.isStreaming && !_hasCompletedStreaming) {
      _displayedText = '';
      _currentIndex = 0;
      _startStreaming();
    } else {
      _displayedText = widget.fullText;
      _hasCompletedStreaming = true;
    }
  }

  void _startStreaming() {
    if (_currentIndex < widget.fullText.length) {
      _streamingTimer = Timer.periodic(widget.streamingSpeed, (timer) {
        if (_currentIndex < widget.fullText.length && mounted) {
          setState(() {
            // Add characters word by word for more natural streaming
            final nextChar = widget.fullText[_currentIndex];
            _displayedText += nextChar;
            _currentIndex++;
            
            // Add a slight pause after punctuation
            if (nextChar == '.' || nextChar == '!' || nextChar == '?' || nextChar == '\n') {
              timer.cancel();
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted && _currentIndex < widget.fullText.length) {
                  _startStreaming();
                }
              });
            }
          });
        } else {
          timer.cancel();
          _hasCompletedStreaming = true;
          widget.onStreamingComplete?.call();
        }
      });
    } else {
      _hasCompletedStreaming = true;
      widget.onStreamingComplete?.call();
    }
  }

  @override
  void dispose() {
    _streamingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textToShow = _displayedText.isEmpty ? widget.fullText : _displayedText;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SelectableText.rich(
          TextSpan(
            children: [
              ...RichTextParser.parseAdvancedText(
                textToShow,
                baseStyle: widget.baseStyle ?? 
                    TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: ResponsiveUtils.getFontSize(context, 16),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Comic Sans MS',
                      fontFamilyFallback: const [
                        'Comic Sans',
                        'Chalkduster',
                        'Bradley Hand',
                        'cursive'
                      ],
                      height: 1.5,
                    ),
                boldStyle: widget.boldStyle,
                italicStyle: widget.italicStyle,
                codeStyle: widget.codeStyle,
              ),
              // Add blinking cursor while streaming
              if (widget.isStreaming && !_hasCompletedStreaming)
                WidgetSpan(
                  child: _BlinkingCursor(),
                ),
            ],
          ),
          onSelectionChanged: _hasCompletedStreaming ? widget.onSelectionChanged : null,
          contextMenuBuilder: _hasCompletedStreaming 
              ? null 
              : (context, editableTextState) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 2,
            height: 20,
            color: Theme.of(context).colorScheme.onSurface,
            margin: const EdgeInsets.only(left: 2),
          ),
        );
      },
    );
  }
}