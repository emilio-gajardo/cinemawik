import 'package:dio/dio.dart';

import 'package:cinemawik/config/constants/environment.dart';
import 'package:cinemawik/domain/datasources/movies_datasource.dart';

import 'package:cinemawik/infrastructure/models/models.dart';
import 'package:cinemawik/infrastructure/mappers/mappers.dart';

import 'package:cinemawik/domain/entities/entities.dart';

class MoviedbDatasource extends MoviesDatasource {
  final dio = Dio(
    BaseOptions(
      baseUrl: Environment.urlBase,
      queryParameters: {
        'api_key': Environment.theMovieDBKey,
        'language': Environment.language,
      }
    ),
  );

  List<Movie> _jsonToMovies(Map<String, dynamic> json) {

    final MovieDbResponse movieDbResponse = MovieDbResponse.fromJson(json);

    final List<Movie> movies = movieDbResponse
        .results
        // .where((moviedb) => moviedb.posterPath != 'no-poster')
        .map((moviedb) => MovieMapper.movieDBToEntity(moviedb))
        .toList();
    return movies;
  }

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    final response = await dio.get('movie/now_playing', queryParameters: {'page': page});
    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getPopular({int page = 1}) async {
    final response = await dio.get('movie/popular', queryParameters: {'page': page});
    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getTopRated({int page = 1}) async {
    final response = await dio.get('movie/top_rated', queryParameters: {'page': page});
    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Movie>> getUpcoming({int page = 1}) async {
    final response = await dio.get('movie/upcoming', queryParameters: {'page': page});
    return _jsonToMovies(response.data);
  }

  @override
  Future<Movie> getMovieById(String id) async {
    final response = await dio.get('movie/$id');
    if(response.statusCode !=200) throw Exception('Movie with id: $id not found');
    final MovieDetails movieDetails = MovieDetails.fromJson(response.data);
    final Movie movie = MovieMapper.movieDetailsToEntity(movieDetails);
    return movie;
  }
  
  @override
  Future<List<Movie>> searchMovies(String query) async {

    final trimmedQuery = query.trim();
    if (trimmedQuery.isNotEmpty){
      final response = await dio.get('search/movie', queryParameters: {'query': trimmedQuery});
      return _jsonToMovies(response.data);
    } else {
      return [];
    }
  }

  @override
  Future<List<Movie>> getSimilarMovies(int movieId) async {
    final response = await dio.get('/movie/$movieId/similar');
    return _jsonToMovies(response.data);
  }

  @override
  Future<List<Video>> getYoutubeVideosById(int movieId) async {
    final response = await dio.get('/movie/$movieId/videos');
    final moviedbVideosReponse = MoviedbVideosResponse.fromJson(response.data);
    final videos = <Video>[];

    for (final moviedbVideo in moviedbVideosReponse.results) {
      if ( moviedbVideo.site == 'YouTube' ) {
        final video = VideoMapper.moviedbVideoToEntity(moviedbVideo);
        videos.add(video);
      }
    }

    return videos;
  }

}
