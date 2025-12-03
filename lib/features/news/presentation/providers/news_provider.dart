import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:news_explorer_app/features/news/data/repository_impl/news_repository_impl.dart';
import '../../data/datasources/news_local_data_source.dart';
import '../../data/datasources/news_remote_data_source.dart';

import '../../domain/usecases/get_news_by_category.dart';
import '../../domain/usecases/search_news.dart';
import 'news_state.dart';

// Dependency injection
final dioProvider = Provider<Dio>((ref) => Dio());

final remoteDataSourceProvider = Provider<NewsRemoteDataSource>(
      (ref) => NewsRemoteDataSourceImpl(ref.watch(dioProvider)),
);

final localDataSourceProvider = Provider<NewsLocalDataSource>(
      (ref) => NewsLocalDataSourceImpl(),
);

final newsRepositoryProvider = Provider(
      (ref) => NewsRepositoryImpl(
    remoteDataSource: ref.watch(remoteDataSourceProvider),
    localDataSource: ref.watch(localDataSourceProvider),
  ),
);

final getNewsByCategoryProvider = Provider(
      (ref) => GetNewsByCategory(ref.watch(newsRepositoryProvider)),
);

final searchNewsProvider = Provider(
      (ref) => SearchNews(ref.watch(newsRepositoryProvider)),
);

// State notifier
class NewsNotifier extends StateNotifier<NewsState> {
  final GetNewsByCategory getNewsByCategory;
  final SearchNews searchNews;

  String? _nextPage;
  String _currentCategory = 'business';

  NewsNotifier({
    required this.getNewsByCategory,
    required this.searchNews,
  }) : super(NewsInitial());

  Future<void> loadNews(String category) async {
    _currentCategory = category;
    _nextPage = null;
    state = NewsLoading();

    final result = await getNewsByCategory(
      NewsCategoryParams(category: category),
    );

    result.fold(
          (failure) => state = NewsError(failure.message),
          (articles) {
        if (articles.isEmpty) {
          state = NewsEmpty();
        } else {
          state = NewsLoaded(articles: articles, hasMore: true);
        }
      },
    );
  }

  Future<void> loadMore() async {
    if (state is! NewsLoaded) return;

    final currentState = state as NewsLoaded;
    if (!currentState.hasMore || currentState.isPaginating) return;

    state = currentState.copyWith(isPaginating: true);

    final result = await getNewsByCategory(
      NewsCategoryParams(category: _currentCategory, nextPage: _nextPage),
    );

    result.fold(
          (failure) => state = currentState.copyWith(isPaginating: false),
          (newArticles) {
        if (newArticles.isEmpty) {
          state = currentState.copyWith(hasMore: false, isPaginating: false);
        } else {
          state = currentState.copyWith(
            articles: [...currentState.articles, ...newArticles],
            hasMore: true,
            isPaginating: false,
          );
        }
      },
    );
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      loadNews(_currentCategory);
      return;
    }

    state = NewsLoading();

    final result = await searchNews(SearchParams(query: query));

    result.fold(
          (failure) => state = NewsError(failure.message),
          (articles) {
        if (articles.isEmpty) {
          state = NewsEmpty();
        } else {
          state = NewsLoaded(articles: articles, hasMore: false);
        }
      },
    );
  }
}

final newsNotifierProvider = StateNotifierProvider<NewsNotifier, NewsState>(
      (ref) => NewsNotifier(
    getNewsByCategory: ref.watch(getNewsByCategoryProvider),
    searchNews: ref.watch(searchNewsProvider),
  ),
);
