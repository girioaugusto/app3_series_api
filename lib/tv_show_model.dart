import 'package:app3_series_api/tv_show_service.dart';
import 'package:flutter/material.dart';

class TvShow {
  int id;
  String imageUrl;
  String name;
  String webChannel;
  double rating;
  String summary;

  TvShow({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.webChannel,
    required this.rating,
    required this.summary,
  });

  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      id: json['id'],
      imageUrl: json['image']?['medium'] ?? '',
      name: json['name'],
      webChannel: json['webChannel']?['name'] ?? 'N/A',
      rating: json['rating']?['average']?.toDouble() ?? 0.0,
      summary: json['summary'] ?? 'Sem resumo disponível',
    );
  }
}

class TvShowModel extends ChangeNotifier {
  final TvShowService _tvShowService = TvShowService();

  final List<TvShow> _tvShows = [];
  List<TvShow> get tvShows => _tvShows;

  Future<TvShow> getTvShowById(int id) async {
    try {
      return await _tvShowService.fetchTvShowById(id);
    } catch (e) {
      throw Exception('Falha ao carregar séries: ${e.toString()}');
    }
  }

  Future<List<TvShow>> searchTvShows(String querry) async {
    try {
      return await _tvShowService.fetchTvShows(querry);
    } catch (e) {
      throw Exception('Falha em buscar séries: ${e.toString()}');
    }
  }

  void addTvShow(TvShow tvShow, BuildContext context) {
    tvShows.add(tvShow);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Série adicionada com sucesso!',
          textAlign: TextAlign.center,
        ),
        duration: Duration(seconds: 2),
      ),
    );
    notifyListeners();
  }

  void removeTvShow(TvShow tvShow, BuildContext context) {
    final index = tvShows.indexWhere(
      (show) => show.name.toLowerCase() == tvShow.name.toLowerCase(),
    );
    tvShows.removeAt(index);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${tvShow.name} excluída!'),
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'DESFAZER',
          onPressed: () {
            tvShows.insert(index, tvShow);
            notifyListeners();
          },
        ),
      ),
    );
    notifyListeners();
  }

  void editTvShow(TvShow oldTvShow, TvShow newTvShow, BuildContext context) {
    final index = tvShows.indexOf(oldTvShow);
    tvShows[index] = newTvShow;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Série ${index + 1} atualizada!'),
        duration: Duration(seconds: 2),
      ),
    );
    notifyListeners();
  }
}
