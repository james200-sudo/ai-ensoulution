import 'package:flutter/material.dart';

class RichTextParser {
  static List<TextSpan> parseText(
    String text, {
    required TextStyle baseStyle,
    TextStyle? boldStyle,
  }) {
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    
    int lastEnd = 0;
    
    for (final match in boldPattern.allMatches(text)) {
      // Add text before the bold section
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }
      
      // Add bold text
      spans.add(TextSpan(
        text: match.group(1) ?? '',
        style: boldStyle ?? baseStyle.copyWith(fontWeight: FontWeight.bold),
      ));
      
      lastEnd = match.end;
    }
    
    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: baseStyle,
      ));
    }
    
    // If no bold patterns found, return the whole text
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: baseStyle));
    }
    
    return spans;
  }
  
  static List<TextSpan> parseAdvancedText(
    String text, {
    required TextStyle baseStyle,
    TextStyle? boldStyle,
    TextStyle? italicStyle,
    TextStyle? codeStyle,
  }) {
    final List<TextSpan> spans = [];
    
    // Extended patterns for bold, italic, and inline code
    final RegExp patterns = RegExp(r'\*\*(.*?)\*\*|\*(.*?)\*|`(.*?)`');
    
    int lastEnd = 0;
    
    for (final match in patterns.allMatches(text)) {
      // Add text before the formatted section
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }
      
      // Determine the type of formatting
      String matchedText = match.group(0) ?? '';
      String content = '';
      TextStyle style = baseStyle;
      
      if (matchedText.startsWith('**') && matchedText.endsWith('**')) {
        // Bold text
        content = match.group(1) ?? '';
        style = boldStyle ?? baseStyle.copyWith(fontWeight: FontWeight.bold);
      } else if (matchedText.startsWith('*') && matchedText.endsWith('*')) {
        // Italic text
        content = match.group(2) ?? '';
        style = italicStyle ?? baseStyle.copyWith(fontStyle: FontStyle.italic);
      } else if (matchedText.startsWith('`') && matchedText.endsWith('`')) {
        // Inline code
        content = match.group(3) ?? '';
        style = codeStyle ?? baseStyle.copyWith(
          fontFamily: 'monospace',
          backgroundColor: Colors.grey.withValues(alpha: 0.2),
        );
      }
      
      spans.add(TextSpan(text: content, style: style));
      lastEnd = match.end;
    }
    
    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: baseStyle,
      ));
    }
    
    // If no patterns found, return the whole text
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text, style: baseStyle));
    }
    
    return spans;
  }
}