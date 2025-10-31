import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final double size;
  final bool isBot;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.initials,
    this.size = 35,
    this.isBot = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = ResponsiveUtils.isDesktop(context) ? size + 5 : size;
    
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(avatarSize / 2),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(avatarSize / 2),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? _buildImageWidget(avatarSize)
            : _buildFallbackAvatar(avatarSize),
      ),
    );
  }

  Widget _buildImageWidget(double avatarSize) {
    final url = imageUrl!;
    
    // Check if it's a local file path
    if (url.startsWith('/') || url.startsWith('file://')) {
      return Image.file(
        File(url),
        width: avatarSize,
        height: avatarSize,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(avatarSize),
      );
    }
    
    // Network image
    return Image.network(
      url,
      width: avatarSize,
      height: avatarSize,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(avatarSize),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(avatarSize / 2),
          ),
          child: Center(
            child: SizedBox(
              width: avatarSize * 0.3,
              height: avatarSize * 0.3,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallbackAvatar(double avatarSize) {
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        gradient: isBot 
            ? const LinearGradient(
                begin: Alignment(-0.707, -0.707),
                end: Alignment(0.707, 0.707),
                colors: [Color(0xFF666666), Color(0xFF888888)],
              )
            : AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(avatarSize / 2),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: avatarSize * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}