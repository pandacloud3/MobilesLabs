import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../domain/bin_event_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://69e385763327837a15534032.mockapi.io/events';
  final String cacheKey = 'cached_history_events';

  Future<List<BinEvent>> getHistory() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = !connectivityResult.contains(ConnectivityResult.none);

    if (hasInternet) {
      try {
        final response = await _dio.get<dynamic>(baseUrl);
        final data = response.data as List<dynamic>;

        final List<BinEvent> events = data
            .map((e) => BinEvent.fromJson(e as Map<String, dynamic>))
            .toList();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, jsonEncode(data));

        return events;
      } catch (e) {
        return _getCachedHistory();
      }
    } else {
      return _getCachedHistory();
    }
  }

  Future<List<BinEvent>> _getCachedHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(cacheKey);

    if (cachedData != null) {
      final data = jsonDecode(cachedData) as List<dynamic>;
      return data
          .map((e) => BinEvent.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Немає інтернету і збережених даних.');
  }
}
