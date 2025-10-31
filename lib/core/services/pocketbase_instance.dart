import 'package:pocketbase/pocketbase.dart';

class PocketBaseInstance {
  static const String _baseUrl = 'https://hydro-ai-chat.ensolutions.ca';
  static PocketBase? _instance;
  
  static PocketBase get instance {
    _instance ??= PocketBase(_baseUrl);
    return _instance!;
  }
}