import 'package:shared_preferences/shared_preferences.dart';

class MessageCounterService {
  static const String _messageCountKey = 'messageCount';

  Future<int> getMessageCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_messageCountKey) ?? 0;
  }

  Future<void> incrementMessageCount({int by = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    int currentCount = await getMessageCount();
    await prefs.setInt(_messageCountKey, currentCount + by);
  }
}
