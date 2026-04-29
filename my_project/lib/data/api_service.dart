import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project/domain/bin_event_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = 'https://69e385763327837a15534032.mockapi.io/events';
  final String cacheKey = 'cached_history_events';

  Future<List<BinEvent>> getHistory({bool useFirestore = false}) async {
    final conn = await Connectivity().checkConnectivity();
    if (conn.contains(ConnectivityResult.none)) {
      return _getCachedHistory();
    }

    try {
      if (useFirestore) {
        print('🐞 1. Спроба доступу до Firebase...');
        final snapshot = await FirebaseFirestore.instance
            .collection('events')
            .get();
        print(
          '🐞 2. Дані успішно завантажено! Документів: ${snapshot.docs.length}',
        );

        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return BinEvent.fromJson(data);
        }).toList();
      } else {
        final response = await _dio.get<dynamic>(baseUrl);
        final data = response.data as List<dynamic>;
        final events = data
            .map((e) => BinEvent.fromJson(e as Map<String, dynamic>))
            .toList();

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(cacheKey, jsonEncode(data));

        return events;
      }
    } catch (e) {
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

    throw Exception('Немає інтернету і кешу.');
  }
}
