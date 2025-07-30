import 'dart:convert';

import 'package:app3_series_api/tv_show_model.dart';
import 'package:http/http.dart' as http;

class TvShowService {
  Future<TvShow> fetchTvShowById(int id) async {
    final response = await http.get(
      Uri.parse('https://api.tvmaze.com/shows/$id'),
    );
    if (response.statusCode == 200) {
      return TvShow.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falha ao carregar série');
    }
  }

  Future<List<TvShow>> fetchTvShows(String querry) async {
    final response = await http.get(
      Uri.parse('https://api.tvmaze.com/search/shows?q=$querry'),
    );

    if (response.statusCode == 200) {
      final List<TvShow> tvShows = [];
      json.decode(response.body).forEach((item) {
        tvShows.add(TvShow.fromJson(item['show']));
      });
      return tvShows;
    } else {
      throw Exception('Falha ao carregar séries');
    }
  }
}
