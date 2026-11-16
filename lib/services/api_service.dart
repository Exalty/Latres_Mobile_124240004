import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tv_show.dart';

class ApiService {
  static const String _baseUrl = 'https://api.tvmaze.com';

  /// Fetch list of all TV shows
  static Future<List<TvShow>> fetchShows() async {
    final response = await http.get(Uri.parse('$_baseUrl/shows'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => TvShow.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load shows');
    }
  }

  /// Fetch detail of a single TV show by ID
  static Future<TvShow> fetchShowDetail(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/shows/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return TvShow.fromJson(jsonData);
    } else {
      throw Exception('Failed to load show detail');
    }
  }
}
