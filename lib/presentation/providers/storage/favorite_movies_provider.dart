import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemawik/domain/entities/movie.dart';
import 'package:cinemawik/domain/repositories/local_storage_repository.dart';
import 'package:cinemawik/presentation/providers/providers.dart';

final favoriteMoviesProvider = StateNotifierProvider<StorageMoviesNotifier, Map <int, Movie>>((ref) {
  final localStorageRepository = ref.watch(localStorageRepositoryProvider);
  return StorageMoviesNotifier(localStorageRepository: localStorageRepository);
});

class StorageMoviesNotifier extends StateNotifier<Map<int, Movie>> {
  int page = 0;
  final LocalStorageRepository localStorageRepository;
  
  StorageMoviesNotifier({
    required this.localStorageRepository
  }): super({});

  /// - Permite cargar las siguientes peliculas
  Future<List<Movie>> loadNextPage() async {
    final movies = await localStorageRepository.loadMovies(offset: page * 10, limit: 20);
    // print('>> localStorageRepository.loadMovies: $movies');
    page++;

    final Map<int, Movie> tempMoviesMap = <int, Movie>{};

    for(final movie in movies) {
      tempMoviesMap[movie.id] = movie;
    }
    state = {...state, ...tempMoviesMap};
    return movies;
  }

  Future<void> toggleFavorite(Movie movie) async {
    await localStorageRepository.toggleFavorite(movie);
    final bool isMovieInFavorites = state[movie.id] != null;
    if(isMovieInFavorites) {
      state.remove(movie.id);
      state = {...state};
    } else {
      state = {...state, movie.id: movie};
    }
  }
}
