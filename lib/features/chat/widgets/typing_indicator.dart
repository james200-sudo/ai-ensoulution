import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/user_avatar.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
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
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
                bottomLeft: Radius.circular(4.r),
                bottomRight: Radius.circular(18.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                SizedBox(width: 4.w),
                _buildDot(1),
                SizedBox(width: 4.w),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return UserAvatar(
      initials: 'AI',
      size: ResponsiveUtils.isDesktop(context) ? 35 : 32,
      isBot: true,
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final delay = index * 0.2;
        final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
        final opacity = (animationValue * 2).clamp(0.0, 1.0);

        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.textGrey.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(3.r),
          ),
        );
      },
    );
  }
}
