import 'package:flutter/material.dart';
import 'dart:math' as math;

class AudioWaveAnimation extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final double height;
  final double width;

  const AudioWaveAnimation({
    super.key,
    required this.isPlaying,
    required this.color,
    this.height = 20,
    this.width = 100,
  });

  @override
  State<AudioWaveAnimation> createState() => _AudioWaveAnimationState();
}

class _AudioWaveAnimationState extends State<AudioWaveAnimation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_animationController);
  }

  @override
  void didUpdateWidget(AudioWaveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _animationController.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: WavePainter(
              animation: _animation.value,
              color: widget.color,
              isPlaying: widget.isPlaying,
            ),
            size: Size(widget.width, widget.height),
          );
        },
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animation;
  final Color color;
  final bool isPlaying;

  WavePainter({
    required this.animation,
    required this.color,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerY = size.height / 2;

    if (!isPlaying) {
      // Draw straight line when not playing
      path.moveTo(0, centerY);
      path.lineTo(size.width, centerY);
    } else {
      // Draw animated wave when playing
      const waveCount = 3;
      const amplitude = 6.0;
      
      for (int i = 0; i < size.width.toInt(); i++) {
        final x = i.toDouble();
        final normalizedX = x / size.width;
        
        // Create multiple sine waves with different frequencies for a richer effect
        final wave1 = math.sin((normalizedX * waveCount * 2 * math.pi) + animation) * amplitude * 0.5;
        final wave2 = math.sin((normalizedX * waveCount * 3 * math.pi) + (animation * 1.3)) * amplitude * 0.3;
        final wave3 = math.sin((normalizedX * waveCount * 4 * math.pi) + (animation * 0.8)) * amplitude * 0.2;
        
        final y = centerY + wave1 + wave2 + wave3;
        
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
    }

    canvas.drawPath(path, paint);
    
    // Add some dots to simulate sound bars
    if (isPlaying) {
      final dotPaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
        
      const dotCount = 5;
      for (int i = 0; i < dotCount; i++) {
        final x = (size.width / (dotCount + 1)) * (i + 1);
        final intensity = math.sin(animation + (i * 0.5)) * 0.5 + 0.5;
        final radius = 1.5 + (intensity * 2);
        final y = centerY + (math.sin(animation + (i * 1.2)) * 6.0 * 0.3);
        
        canvas.drawCircle(Offset(x, y), radius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animation != animation || 
           oldDelegate.isPlaying != isPlaying;
  }
}