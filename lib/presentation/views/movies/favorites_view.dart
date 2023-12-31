import 'package:cinemawik/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemawik/domain/entities/movie.dart';

import 'package:cinemawik/presentation/providers/providers.dart';
import 'package:go_router/go_router.dart';

class FavoritesView extends ConsumerStatefulWidget {
  const FavoritesView({super.key});

  @override
  FavoritesViewState createState() => FavoritesViewState();
}

class FavoritesViewState extends ConsumerState<FavoritesView> with AutomaticKeepAliveClientMixin {
  bool isLastPage = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadNextPage(); // aquí se cargan las siguientes peliculas
  }

  void loadNextPage() async {
    if(isLoading || isLastPage) return;
    isLoading = true;
    final movies = await ref.read(favoriteMoviesProvider.notifier).loadNextPage();
    isLoading = false;
    if(movies.isEmpty) {
      isLastPage = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Map<int, Movie> favoriteMoviesMap = ref.watch(favoriteMoviesProvider);
    final List<Movie> favoriteMovies = favoriteMoviesMap.values.toList();

    // En el caso que no existan peliculas favoritas
    if(favoriteMovies.isEmpty) {
      final colors = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.star, size: 60, color: colors.primary),
            Text('Sin favoritos', style: TextStyle(fontSize: 30, color: colors.primary)),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: () => context.go('/home/0'),
              child: const Text('Ver cartelera')
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: MovieMasonry(
        loadNextPage: loadNextPage,
        movies: favoriteMovies
      )
    );
  }

  /// true = establece que si se mantenga el estado actual del widget incluso si no esta en la pantalla actual
  @override
  bool get wantKeepAlive => true;
}