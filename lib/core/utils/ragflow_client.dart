import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class RagflowClient {
  final String baseUrl;
  final String apiKey;

  RagflowClient({required this.baseUrl, required this.apiKey});

  /// Parses Server-Sent Events (SSE) stream properly
  Stream<Map<String, dynamic>> _parseSSEStream(Stream<String> stream) async* {
    String buffer = '';
    int chunkCount = 0;
    bool streamCompleted = false;
    
    await for (String chunk in stream) {
      chunkCount++;
      //print('🔄 Processing chunk #$chunkCount (${chunk.length} chars)');
      
      buffer += chunk;
      
      // Split by double newlines to separate events
      List<String> events = buffer.split('\n\n');
      buffer = events.removeLast(); // Keep the last incomplete event in buffer
      
      //print('📋 Found ${events.length} complete events, buffer has ${buffer.length} chars remaining');
      
      for (String event in events) {
        if (event.trim().isEmpty) continue;
        
        Map<String, String> fields = {};
        List<String> lines = event.split('\n');
        
        for (String line in lines) {
          line = line.trim();
          if (line.isEmpty || line.startsWith(':')) continue; // Skip empty lines and comments
          
          int colonIndex = line.indexOf(':');
          if (colonIndex == -1) {
            fields[line] = '';
          } else {
            String field = line.substring(0, colonIndex);
            String value = line.substring(colonIndex + 1).trim();
            fields[field] = value;
          }
        }
        
        // Process the event
        if (fields.containsKey('data')) {
          String data = fields['data']!;
          
          //print('📨 Processing SSE data: ${data.length > 100 ? data.substring(0, 100) + "..." : data}');
          
          if (data == '[DONE]') {
            //print('🏁 Stream completed: [DONE] received after $chunkCount chunks');
            streamCompleted = true;
            return;
          }
          
          if (data.isNotEmpty) {
            try {
              Map<String, dynamic> jsonData = json.decode(data);
              //print('📦 SSE Event parsed successfully: ${jsonData.keys.join(", ")}');
              yield jsonData;
            } catch (e) {
              //print('⚠️ Failed to parse SSE JSON data: $e');
              //print('   Raw data: ${data.length > 200 ? data.substring(0, 200) + "..." : data}');
              // Try to handle partial JSON or continue
              continue;
            }
          }
        } else if (fields.isNotEmpty) {
          //print('📝 SSE event with no data field: ${fields.keys.join(", ")}');
        }
      }
    }
    
    if (!streamCompleted) {
      //print('⚠️ Stream ended without [DONE] signal after $chunkCount chunks');
    }
    
    // Handle any remaining buffer content
    if (buffer.trim().isNotEmpty) {
      //print('📝 Processing remaining buffer content');
      
      Map<String, String> fields = {};
      List<String> lines = buffer.split('\n');
      
      for (String line in lines) {
        line = line.trim();
        if (line.isEmpty || line.startsWith(':')) continue;
        
        int colonIndex = line.indexOf(':');
        if (colonIndex == -1) {
          fields[line] = '';
        } else {
          String field = line.substring(0, colonIndex);
          String value = line.substring(colonIndex + 1).trim();
          fields[field] = value;
        }
      }
      
      if (fields.containsKey('data')) {
        String data = fields['data']!;
        
        if (data != '[DONE]' && data.isNotEmpty) {
          try {
            Map<String, dynamic> jsonData = json.decode(data);
            //print('📦 Final SSE Event parsed: ${jsonData.keys.join(", ")}');
            yield jsonData;
          } catch (e) {
            //print('⚠️ Failed to parse final SSE JSON data: $e');
          }
        }
      }
    }
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'code': 0, 'message': 'Success'};
      }
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to load data: ${response.statusCode} ${response.body}');
    }
  }

  // DATASET MANAGEMENT

  Future<Map<String, dynamic>> createDataset({
    required String name,
    String? avatar,
    String? description,
    String? embeddingModel,
    String? permission,
    String? chunkMethod,
    Map<String, dynamic>? parserConfig,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/datasets'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'name': name,
        if (avatar != null) 'avatar': avatar,
        if (description != null) 'description': description,
        if (embeddingModel != null) 'embedding_model': embeddingModel,
        if (permission != null) 'permission': permission,
        if (chunkMethod != null) 'chunk_method': chunkMethod,
        if (parserConfig != null) 'parser_config': parserConfig,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> listDatasets({
    int page = 1,
    int pageSize = 30,
    String orderby = 'create_time',
    bool desc = true,
    String? name,
    String? id,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'orderby': orderby,
      'desc': desc.toString(),
      if (name != null) 'name': name,
      if (id != null) 'id': id,
    };
    final uri = Uri.parse('$baseUrl/api/v1/datasets')
        .replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateDataset(
    String datasetId, {
    String? name,
    String? avatar,
    String? description,
    String? embeddingModel,
    String? permission,
    String? chunkMethod,
    int? pagerank,
    Map<String, dynamic>? parserConfig,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/datasets/$datasetId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        if (name != null) 'name': name,
        if (avatar != null) 'avatar': avatar,
        if (description != null) 'description': description,
        if (embeddingModel != null) 'embedding_model': embeddingModel,
        if (permission != null) 'permission': permission,
        if (chunkMethod != null) 'chunk_method': chunkMethod,
        if (pagerank != null) 'pagerank': pagerank,
        if (parserConfig != null) 'parser_config': parserConfig,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteDatasets(List<String>? ids) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/v1/datasets'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({'ids': ids}),
    );
    return _handleResponse(response);
  }

  // FILE MANAGEMENT

  Future<Map<String, dynamic>> uploadDocuments(
      String datasetId, List<File> files) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/v1/datasets/$datasetId/documents'),
    );
    request.headers['Authorization'] = 'Bearer $apiKey';
    for (var file in files) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }
    final response = await request.send();
    return _handleResponse(await http.Response.fromStream(response));
  }

  Future<Map<String, dynamic>> listDocuments(
    String datasetId, {
    int page = 1,
    int pageSize = 30,
    String orderby = 'create_time',
    bool desc = true,
    String? keywords,
    String? id,
    String? name,
    int? createTimeFrom,
    int? createTimeTo,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'orderby': orderby,
      'desc': desc.toString(),
      if (keywords != null) 'keywords': keywords,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createTimeFrom != null) 'create_time_from': createTimeFrom.toString(),
      if (createTimeTo != null) 'create_time_to': createTimeTo.toString(),
    };
    final uri = Uri.parse('$baseUrl/api/v1/datasets/$datasetId/documents')
        .replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateDocument(
    String datasetId,
    String documentId, {
    String? name,
    Map<String, dynamic>? metaFields,
    String? chunkMethod,
    Map<String, dynamic>? parserConfig,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/datasets/$datasetId/documents/$documentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        if (name != null) 'name': name,
        if (metaFields != null) 'meta_fields': metaFields,
        if (chunkMethod != null) 'chunk_method': chunkMethod,
        if (parserConfig != null) 'parser_config': parserConfig,
      }),
    );
    return _handleResponse(response);
  }

  Future<void> downloadDocument(
      String datasetId, String documentId, String savePath) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/datasets/$datasetId/documents/$documentId'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    if (response.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception(
          'Failed to download file: ${response.statusCode} ${response.body}');
    }
  }

  Future<Map<String, dynamic>> deleteDocuments(
      String datasetId, List<String>? ids) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/v1/datasets/$datasetId/documents'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({'ids': ids}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> parseDocuments(
      String datasetId, List<String> documentIds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/datasets/$datasetId/chunks'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({'document_ids': documentIds}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> stopParsingDocuments(
      String datasetId, List<String> documentIds) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/v1/datasets/$datasetId/chunks'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({'document_ids': documentIds}),
    );
    return _handleResponse(response);
  }

  // CHUNK MANAGEMENT

  Future<Map<String, dynamic>> addChunk(
    String datasetId,
    String documentId, {
    required String content,
    List<String>? importantKeywords,
    List<String>? questions,
  }) async {
    final response = await http.post(
      Uri.parse(
          '$baseUrl/api/v1/datasets/$datasetId/documents/$documentId/chunks'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'content': content,
        if (importantKeywords != null) 'important_keywords': importantKeywords,
        if (questions != null) 'questions': questions,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> listChunks(
    String datasetId,
    String documentId, {
    String? keywords,
    int page = 1,
    int pageSize = 1024,
    String? id,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      if (keywords != null) 'keywords': keywords,
      if (id != null) 'id': id,
    };
    final uri = Uri.parse(
            '$baseUrl/api/v1/datasets/$datasetId/documents/$documentId/chunks')
        .replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateChunk(
    String datasetId,
    String documentId,
    String chunkId, {
    String? content,
    List<String>? importantKeywords,
    bool? available,
  }) async {
    final response = await http.put(
      Uri.parse(
          '$baseUrl/api/v1/datasets/$datasetId/documents/$documentId/chunks/$chunkId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        if (content != null) 'content': content,
        if (importantKeywords != null) 'important_keywords': importantKeywords,
        if (available != null) 'available': available,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteChunks(
      String datasetId, String documentId, List<String>? chunkIds) async {
    final response = await http.delete(
      Uri.parse(
          '$baseUrl/api/v1/datasets/$datasetId/documents/$documentId/chunks'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({'chunk_ids': chunkIds}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> retrieveChunks({
    required String question,
    List<String>? datasetIds,
    List<String>? documentIds,
    int page = 1,
    int pageSize = 30,
    double similarityThreshold = 0.2,
    double vectorSimilarityWeight = 0.3,
    int topK = 1024,
    String? rerankId,
    bool keyword = false,
    bool highlight = false,
    List<String>? crossLanguages,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/retrieval'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'question': question,
        if (datasetIds != null) 'dataset_ids': datasetIds,
        if (documentIds != null) 'document_ids': documentIds,
        'page': page,
        'page_size': pageSize,
        'similarity_threshold': similarityThreshold,
        'vector_similarity_weight': vectorSimilarityWeight,
        'top_k': topK,
        if (rerankId != null) 'rerank_id': rerankId,
        'keyword': keyword,
        'highlight': highlight,
        if (crossLanguages != null) 'cross_languages': crossLanguages,
      }),
    );
    return _handleResponse(response);
  }

  // CHAT ASSISTANT MANAGEMENT

  Future<Map<String, dynamic>> createChatAssistant({
    required String name,
    String? avatar,
    List<String>? datasetIds,
    Map<String, dynamic>? llm,
    Map<String, dynamic>? prompt,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/chats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'name': name,
        if (avatar != null) 'avatar': avatar,
        if (datasetIds != null) 'dataset_ids': datasetIds,
        if (llm != null) 'llm': llm,
        if (prompt != null) 'prompt': prompt,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> listChatAssistants({
    int page = 1,
    int pageSize = 30,
    String orderby = 'create_time',
    bool desc = true,
    String? name,
    String? id,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'orderby': orderby,
      'desc': desc.toString(),
      if (name != null) 'name': name,
      if (id != null) 'id': id,
    };
    final uri = Uri.parse('$baseUrl/api/v1/chats')
        .replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateChatAssistant(
    String chatId, {
    String? name,
    String? avatar,
    List<String>? datasetIds,
    Map<String, dynamic>? llm,
    Map<String, dynamic>? prompt,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/chats/$chatId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        if (name != null) 'name': name,
        if (avatar != null) 'avatar': avatar,
        if (datasetIds != null) 'dataset_ids': datasetIds,
        if (llm != null) 'llm': llm,
        if (prompt != null) 'prompt': prompt,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteChatAssistants(List<String>? ids) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/v1/chats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({'ids': ids}),
    );
    return _handleResponse(response);
  }

  // SESSION MANAGEMENT

  Future<Map<String, dynamic>> createSession(
    String chatId, {
    required String name,
    String? userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/chats/$chatId/sessions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'name': name,
        if (userId != null) 'user_id': userId,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> listSessions(
    String chatId, {
    int page = 1,
    int pageSize = 30,
    String orderby = 'create_time',
    bool desc = true,
    String? name,
    String? id,
    String? userId,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'orderby': orderby,
      'desc': desc.toString(),
      if (name != null) 'name': name,
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
    };
    final uri = Uri.parse('$baseUrl/api/v1/chats/$chatId/sessions')
        .replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateSession(
    String chatId,
    String sessionId, {
    String? name,
    String? userId,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/chats/$chatId/sessions/$sessionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        if (name != null) 'name': name,
        if (userId != null) 'user_id': userId,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteSessions(
      String chatId, List<String>? ids) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/v1/chats/$chatId/sessions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({'ids': ids}),
    );
    return _handleResponse(response);
  }

  Stream<Map<String, dynamic>> converseWithChatAssistant({
    required String chatId,
    required String question,
    bool stream = true,
    String? sessionId,
    String? userId,
  }) async* {
    //print('🚀 Starting conversation with chat assistant');
    //print('   Chat ID: $chatId');
    //print('   Session ID: $sessionId');
    //print('   Question: ${question.length > 100 ? question.substring(0, 100) + "..." : question}');
    
    final request = http.Request(
      'POST',
      Uri.parse('$baseUrl/api/v1/chats/$chatId/completions'),
    )
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
      })
      ..body = json.encode({
        'question': question,
        'stream': stream,
        if (sessionId != null) 'session_id': sessionId,
        if (userId != null) 'user_id': userId,
      });

    //print('📤 Sending request to: ${request.url}');
    //print('📤 Headers: ${request.headers}');
    //print('📤 Body: ${request.body}');

    final response = await request.send();
    
    //print('📥 Response status: ${response.statusCode}');
    //print('📥 Response headers: ${response.headers}');

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw Exception('HTTP ${response.statusCode}: $body');
    }

    if (stream) {
      // Use proper SSE parser for streaming responses
      yield* _parseSSEStream(response.stream.transform(utf8.decoder));
    } else {
      // Handle non-streaming response
      final body = await response.stream.bytesToString();
      try {
        yield json.decode(body);
      } catch (e) {
        //print('❌ Failed to parse non-streaming response: $e');
        //print('   Body: ${body.length > 500 ? body.substring(0, 500) + "..." : body}');
        throw Exception('Failed to parse response: $e');
      }
    }
  }

  // AGENT MANAGEMENT

  Future<Map<String, dynamic>> createAgent({
    required String title,
    String? description,
    required Map<String, dynamic> dsl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/agents'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'title': title,
        if (description != null) 'description': description,
        'dsl': dsl,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> listAgents({
    int page = 1,
    int pageSize = 30,
    String orderby = 'create_time',
    bool desc = true,
    String? name,
    String? id,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'orderby': orderby,
      'desc': desc.toString(),
      if (name != null) 'name': name,
      if (id != null) 'id': id,
    };
    final uri = Uri.parse('$baseUrl/api/v1/agents')
        .replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateAgent(
    String agentId, {
    String? title,
    String? description,
    Map<String, dynamic>? dsl,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/agents/$agentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (dsl != null) 'dsl': dsl,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteAgent(String agentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/v1/agents/$agentId'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    return _handleResponse(response);
  }

  // OpenAI-Compatible API

  Stream<Map<String, dynamic>> createChatCompletion({
    required String chatId,
    required String model,
    required List<Map<String, String>> messages,
    bool stream = true,
  }) async* {
    //print('🚀 Starting OpenAI chat completion');
    //print('   Chat ID: $chatId');
    //print('   Model: $model');
    
    final request = http.Request(
      'POST',
      Uri.parse('$baseUrl/api/v1/chats_openai/$chatId/chat/completions'),
    )
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
      })
      ..body = json.encode({
        'model': model,
        'messages': messages,
        'stream': stream,
      });

    final response = await request.send();
    
    //print('📥 OpenAI response status: ${response.statusCode}');

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw Exception('HTTP ${response.statusCode}: $body');
    }

    if (stream) {
      // Use proper SSE parser for streaming responses
      yield* _parseSSEStream(response.stream.transform(utf8.decoder));
    } else {
      // Handle non-streaming response
      final body = await response.stream.bytesToString();
      try {
        yield json.decode(body);
      } catch (e) {
        //print('❌ Failed to parse OpenAI non-streaming response: $e');
        throw Exception('Failed to parse response: $e');
      }
    }
  }

  Stream<Map<String, dynamic>> createAgentCompletion({
    required String agentId,
    required String model,
    required List<Map<String, String>> messages,
    bool stream = true,
  }) async* {
    //print('🚀 Starting agent completion');
    //print('   Agent ID: $agentId');
    //print('   Model: $model');
    
    final request = http.Request(
      'POST',
      Uri.parse('$baseUrl/api/v1/agents_openai/$agentId/chat/completions'),
    )
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
      })
      ..body = json.encode({
        'model': model,
        'messages': messages,
        'stream': stream,
      });

    final response = await request.send();
    
    //print('📥 Agent response status: ${response.statusCode}');

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw Exception('HTTP ${response.statusCode}: $body');
    }

    if (stream) {
      // Use proper SSE parser for streaming responses
      yield* _parseSSEStream(response.stream.transform(utf8.decoder));
    } else {
      // Handle non-streaming response
      final body = await response.stream.bytesToString();
      try {
        yield json.decode(body);
      } catch (e) {
        //print('❌ Failed to parse agent non-streaming response: $e');
        throw Exception('Failed to parse response: $e');
      }
    }
  }
}
