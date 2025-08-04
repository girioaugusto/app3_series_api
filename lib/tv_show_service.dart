import 'dart:convert';

import 'package:app3_series_api/database_service.dart';
import 'package:app3_series_api/tv_show_model.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class TvShowService {
  // Instância do serviço de banco de dados
  late final DatabaseService _databaseService = DatabaseService();

  // Retorna todas as séries favoritas salvas no banco
  Future<List<TvShow>> getAll() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('tv_shows');
    return _convertToList(maps);
  }

  // Converte os dados do banco para objetos TvShow
  List<TvShow> _convertToList(List<Map<String, dynamic>> maps) {
    return maps
        .map(
          (map) => TvShow(
            id: map['id'] as int,
            imageUrl: map['imageUrl'] as String? ?? '',
            name: map['name'] as String? ?? 'Desconhecido',
            webChannel: map['webChannel'] as String? ?? 'N/A',
            rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
            summary: map['summary'] as String? ?? 'Sem resumo disponível.',
          ),
        )
        .toList();
  }

  // Insere ou substitui uma série no banco
  Future<void> insert(TvShow tvShow) async {
    final db = await _databaseService.database;
    await db.insert(
      'tv_shows',
      tvShow.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Remove uma série do banco pelo ID
  Future<void> delete(int id) async {
    final db = await _databaseService.database;
    await db.delete('tv_shows', where: 'id = ?', whereArgs: [id]);
  }

  // Verifica se uma série está na lista de favoritos
  Future<bool> isFavorite(TvShow tvShow) async {
    final tvShows = await getAll();
    return tvShows.any((show) => show.id == tvShow.id);
  }

  // ==========================================
  // ============== API =======================
  // ==========================================

  // Busca uma série específica pelo ID na API
  Future<TvShow> fetchTvShowById(int id) async {
    final response = await http.get(
      Uri.parse('https://api.tvmaze.com/shows/$id'),
    );

    if (response.statusCode == 200) {
      return TvShow.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falha ao carregar série!');
    }
  }

  // Busca uma lista de séries com base no nome
  Future<List<TvShow>> fetchTvShows(String query) async {
    final response = await http.get(
      Uri.parse('https://api.tvmaze.com/search/shows?q=$query'),
    );

    if (response.statusCode == 200) {
      final List<TvShow> tvShows = [];
      json.decode(response.body).forEach((item) {
        tvShows.add(TvShow.fromJson(item['show']));
      });
      return tvShows;
    } else {
      throw Exception('Falha ao carregar séries!');
    }
  }
}
