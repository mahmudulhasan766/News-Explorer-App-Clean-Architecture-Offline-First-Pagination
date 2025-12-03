import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_explorer_app/core/error/failures.dart';
import 'package:news_explorer_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_explorer_app/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_explorer_app/features/news/data/models/article_model.dart';
import 'package:news_explorer_app/features/news/data/repository_impl/news_repository_impl.dart';
import 'package:news_explorer_app/features/news/domain/repository/news_repository.dart';

class MockRemoteDataSource extends Mock implements NewsRemoteDataSource {}
class MockLocalDataSource extends Mock implements NewsLocalDataSource {}

void main() {
  late NewsRepository repository;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();

    repository = NewsRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  final tArticles = [
    ArticleModel(
      modelArticleId: '1',
      modelTitle: 'Breaking News',
      modelPubDate: DateTime.now(),
      modelCategory: 'general',
    ),
  ];

  final tEmptyList = <ArticleModel>[];

  group('getNewsByCategory', () {
    const category = 'technology';

    test('should return remote articles and cache them when successful (first page)', () async {
      when(() => mockRemote.getNewsByCategory(category, null))
          .thenAnswer((_) async => tArticles);
      when(() => mockLocal.cacheNews(any(), category))
          .thenAnswer((_) async {});

      final result = await repository.getNewsByCategory(category, null);

      expect(result, Right(tArticles));
      verify(() => mockRemote.getNewsByCategory(category, null)).called(1);
      verify(() => mockLocal.cacheNews(tArticles, category)).called(1);
    });

    test('should NOT cache when nextPage is not null (pagination)', () async {
      when(() => mockRemote.getNewsByCategory(category, '2'))
          .thenAnswer((_) async => tArticles);

      await repository.getNewsByCategory(category, '2');

      verify(() => mockRemote.getNewsByCategory(category, '2')).called(1);
      verifyNever(() => mockLocal.cacheNews(any(), any()));
    });

    test('should fallback to cached data when remote fails and cache has data', () async {
      when(() => mockRemote.getNewsByCategory(any(), any()))
          .thenThrow(Exception('Network error'));
      when(() => mockLocal.getCachedNews(category))
          .thenAnswer((_) async => tArticles);

      final result = await repository.getNewsByCategory(category, null);

      expect(result, Right(tArticles));
      verify(() => mockLocal.getCachedNews(category)).called(1);
    });

    test('should return NetworkFailure when remote fails and cache is empty', () async {
      when(() => mockRemote.getNewsByCategory(any(), any()))
          .thenThrow(Exception());
      when(() => mockLocal.getCachedNews(category))
          .thenAnswer((_) async => tEmptyList);

      final result = await repository.getNewsByCategory(category, null);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<NetworkFailure>());
      expect((result.fold((l) => l, (r) => null) as NetworkFailure).message,
          'No internet and no cached data');
    });

    test('should return CacheFailure when both remote and local fail', () async {
      when(() => mockRemote.getNewsByCategory(any(), any()))
          .thenThrow(Exception());
      when(() => mockLocal.getCachedNews(any()))
          .thenThrow(Exception());

      final result = await repository.getNewsByCategory(category, null);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<CacheFailure>());
    });
  });

  group('searchNews', () {
    const query = 'flutter';

    test('should return remote search results when successful', () async {
      when(() => mockRemote.searchNews(query, null))
          .thenAnswer((_) async => tArticles);

      final result = await repository.searchNews(query, null);

      expect(result, Right(tArticles));
      verify(() => mockRemote.searchNews(query, null)).called(1);
    });

    test('should fallback to cached search when remote fails and has results', () async {
      when(() => mockRemote.searchNews(any(), any()))
          .thenThrow(Exception());
      when(() => mockLocal.searchCachedNews(query))
          .thenAnswer((_) async => tArticles);

      final result = await repository.searchNews(query, null);

      expect(result, Right(tArticles));
      verify(() => mockLocal.searchCachedNews(query)).called(1);
    });

    test('should return NetworkFailure when remote fails and no cached results', () async {
      when(() => mockRemote.searchNews(any(), any()))
          .thenThrow(Exception());
      when(() => mockLocal.searchCachedNews(query))
          .thenAnswer((_) async => tEmptyList);

      final result = await repository.searchNews(query, null);

      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (r) => null) as NetworkFailure;
      expect(failure.message, 'No results found');
    });

    test('should return ServerFailure when both remote and local search fail', () async {
      when(() => mockRemote.searchNews(any(), any()))
          .thenThrow(Exception());
      when(() => mockLocal.searchCachedNews(any()))
          .thenThrow(Exception());

      final result = await repository.searchNews(query, null);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());
    });
  });

  group('getCachedNews', () {
    const category = 'sports';

    test('should return cached articles successfully', () async {
      when(() => mockLocal.getCachedNews(category))
          .thenAnswer((_) async => tArticles);

      final result = await repository.getCachedNews(category);

      expect(result, Right(tArticles));
      verify(() => mockLocal.getCachedNews(category)).called(1);
    });

    test('should return CacheFailure when getCachedNews throws', () async {
      when(() => mockLocal.getCachedNews(any()))
          .thenThrow(Exception());

      final result = await repository.getCachedNews(category);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<CacheFailure>());
      expect((result.fold((l) => l, (r) => null) as CacheFailure).message,
          'Failed to load cached news');
    });
  });
}