import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_explorer_app/core/error/failures.dart';
import 'package:news_explorer_app/features/news/domain/entities/article.dart';
import 'package:news_explorer_app/features/news/domain/repository/news_repository.dart';
import 'package:news_explorer_app/features/news/domain/usecases/get_news_by_category.dart';
import 'package:news_explorer_app/features/news/domain/usecases/search_news.dart';

class MockNewsRepository extends Mock implements NewsRepository {}

void main() {
  late GetNewsByCategory getNewsByCategory;
  late SearchNews searchNews;
  late MockNewsRepository mockRepository;

  setUp(() {
    mockRepository = MockNewsRepository();
    getNewsByCategory = GetNewsByCategory(mockRepository);
    searchNews = SearchNews(mockRepository);
  });

  final tArticles = <Article>[
    Article(
      articleId: '1',
      title: 'Test Article',
      pubDate: DateTime.now(),
    ),
  ];

  group('GetNewsByCategory UseCase', () {
    const tCategory = 'technology';
    const tNextPage = '2';
    final tParamsFirstPage = NewsCategoryParams(category: tCategory);
    final tParamsWithPage = NewsCategoryParams(category: tCategory, nextPage: tNextPage);

    test('should return articles from repository when called with first page params', () async {
      when(() => mockRepository.getNewsByCategory(tCategory, null))
          .thenAnswer((_) async => Right(tArticles));

      final result = await getNewsByCategory(tParamsFirstPage);

      expect(result, Right(tArticles));
      verify(() => mockRepository.getNewsByCategory(tCategory, null)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should forward nextPage parameter correctly', () async {
      when(() => mockRepository.getNewsByCategory(tCategory, tNextPage))
          .thenAnswer((_) async => Right(tArticles));

      final result = await getNewsByCategory(tParamsWithPage);

      expect(result, Right(tArticles));
      verify(() => mockRepository.getNewsByCategory(tCategory, tNextPage)).called(1);
    });

    test('should forward failure from repository', () async {
      when(() => mockRepository.getNewsByCategory(any(), any()))
          .thenAnswer((_) async => Left(ServerFailure('Server error')));

      final result = await getNewsByCategory(tParamsFirstPage);

      expect(result.isLeft(), isTrue);
      expect(result, isA<Left<Failure, List<Article>>>());
      expect(result.fold((l) => l, (r) => null), isA<ServerFailure>());

      verify(() => mockRepository.getNewsByCategory(tCategory, null)).called(1);
    });
  });

  group('SearchNews UseCase', () {
    const tQuery = 'flutter';
    const tNextPage = '3';
    final tParamsFirstPage = SearchParams(query: tQuery);
    final tParamsWithPage = SearchParams(query: tQuery, nextPage: tNextPage);

    test('should return search results from repository', () async {
      when(() => mockRepository.searchNews(tQuery, null))
          .thenAnswer((_) async => Right(tArticles));

      final result = await searchNews(tParamsFirstPage);

      expect(result, Right(tArticles));
      verify(() => mockRepository.searchNews(tQuery, null)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass nextPage to repository when provided', () async {
      when(() => mockRepository.searchNews(tQuery, tNextPage))
          .thenAnswer((_) async => Right(tArticles));

      final result = await searchNews(tParamsWithPage);

      expect(result, Right(tArticles));
      verify(() => mockRepository.searchNews(tQuery, tNextPage)).called(1);
    });

    test('should forward NetworkFailure when repository returns it', () async {
      when(() => mockRepository.searchNews(any(), any()))
          .thenAnswer((_) async => Left(NetworkFailure('No internet')));

      final result = await searchNews(tParamsFirstPage);

      expect(result.isLeft(), true);
      final failure = result.fold((l) => l, (_) => null);
      expect(failure, isA<NetworkFailure>());
      expect((failure as NetworkFailure).message, 'No internet');
    });
  });
}