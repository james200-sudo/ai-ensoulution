import '../utils/constants.dart';
import '../utils/ragflow_client.dart';

class RagflowService {
  static RagflowClient? _client;
  
  static RagflowClient get client {
    _client ??= RagflowClient(
      baseUrl: AppConstants.ragflowApiUrl,
      apiKey: AppConstants.ragflowApiKey,
    );
    return _client!;
  }

  /// Creates a new Ragflow session
  /// Returns the session ID or null if creation fails
  static Future<String?> createSession() async {
    try {
      //print('🔗 Creating Ragflow session with chatId: ${AppConstants.ragflowChatId}');
      
      final result = await client.createSession(
        AppConstants.ragflowChatId,
        name: 'Chat Session ${DateTime.now().millisecondsSinceEpoch}',
      );
      
      //print('📥 Create session result: $result');
      
      if (result['code'] == 0 && result['data'] != null) {
        final sessionId = result['data']['id'] as String?;
        //print('✅ Session created successfully: $sessionId');
        return sessionId;
      } else {
        //print('❌ Failed to create Ragflow session: ${result['message']}');
        return null;
      }
    } catch (e) {
      //print('❌ Error creating Ragflow session: $e');
      return null;
    }
  }

  /// Sends a message to Ragflow using an existing session
  /// Returns a stream of partial responses as they arrive
  static Stream<String> sendMessageStream({
    required String sessionId,
    required String message,
  }) async* {
    try {
      //print('💬 Sending message to Ragflow with sessionId: $sessionId');
      //print('📤 Message: $message');
      
      String accumulatedResponse = '';
      
      // Use the streaming API and yield chunks as they arrive
      final streamWithTimeout = client.converseWithChatAssistant(
        chatId: AppConstants.ragflowChatId,
        question: message,
        sessionId: sessionId,
        stream: true,
      ).timeout(
        Duration(seconds: 120), // 2 minute timeout
        onTimeout: (sink) {
          //print('⏰ Stream timeout after 2 minutes');
          sink.close();
        }
      );

      await for (final chunk in streamWithTimeout) {
        try {
          //print('📥 Raw chunk received (length: ${chunk.toString().length})');
          
          String? newContent;
          
          // Handle different response formats
          if (chunk is Map<String, dynamic>) {
            // OpenAI-style streaming format
            if (chunk['choices'] != null && chunk['choices'].isNotEmpty) {
              final delta = chunk['choices'][0]['delta'];
              if (delta != null && delta['content'] != null) {
                newContent = delta['content'] as String;
                accumulatedResponse += newContent;
                //print('🔸 [OpenAI] Added content chunk: "${newContent.length > 50 ? newContent.substring(0, 50) + "..." : newContent}"');
              }
            }
            // Ragflow native format - complete response
            else if (chunk['data'] != null && chunk['data']['answer'] != null) {
              final fullAnswer = chunk['data']['answer'] as String;
              if (fullAnswer.length > accumulatedResponse.length) {
                // Yield the new part only
                newContent = fullAnswer.substring(accumulatedResponse.length);
                accumulatedResponse = fullAnswer;
                //print('🔸 [Ragflow] Added incremental content: "${newContent.length > 50 ? newContent.substring(0, 50) + "..." : newContent}"');
              }
            }
            // Ragflow streaming format - incremental content
            else if (chunk['data'] != null && chunk['data']['content'] != null) {
              newContent = chunk['data']['content'] as String;
              accumulatedResponse += newContent;
              //print('🔸 [Ragflow] Added streaming content: "${newContent.length > 50 ? newContent.substring(0, 50) + "..." : newContent}"');
            }
            // Handle other response formats
            else if (chunk['content'] != null) {
              newContent = chunk['content'] as String;
              accumulatedResponse += newContent;
              //print('🔸 [Direct] Added content: "${newContent.length > 50 ? newContent.substring(0, 50) + "..." : newContent}"');
            }
          }
          
          // Yield the new content if any
          if (newContent != null && newContent.isNotEmpty) {
            yield newContent;
          }
        } catch (chunkError) {
          //print('⚠️ Error processing chunk: $chunkError');
          // Continue processing other chunks
          continue;
        }
      }
      
      //print('🔚 Stream processing completed');
      //print('📊 Final accumulated response length: ${accumulatedResponse.length}');
    } catch (e) {
      //print('❌ Error sending message to Ragflow: $e');
      if (e is FormatException) {
        //print('   This appears to be a JSON parsing error - the response may be too large or malformed');
        //print('   Error details: ${e.message}');
        //print('   At offset: ${e.offset}');
      }
      // Don't yield anything on error - let the caller handle it
    }
  }

  /// Sends a message and creates a session if one doesn't exist
  /// Returns a stream of partial responses and the session ID
  static Stream<Map<String, dynamic>> sendMessageWithSessionStream({
    String? existingSessionId,
    required String message,
  }) async* {
    String? sessionId = existingSessionId;

    // Create session if it doesn't exist
    if (sessionId == null) {
      sessionId = await createSession();
      if (sessionId == null) {
        yield {
          'type': 'error',
          'message': 'Failed to create session',
          'sessionId': null,
        };
        return;
      }
    }

    // Yield session info first
    yield {
      'type': 'session',
      'sessionId': sessionId,
    };

    // Send message using the session and stream responses
    await for (final chunk in sendMessageStream(
      sessionId: sessionId,
      message: message,
    )) {
      yield {
        'type': 'content',
        'content': chunk,
        'sessionId': sessionId,
      };
    }

    // Signal completion
    yield {
      'type': 'complete',
      'sessionId': sessionId,
    };
  }
}