import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_explorer_app/core/utils/constants.dart';
import 'package:news_explorer_app/features/news/data/datasources/news_remote_data_source.dart';
import 'package:news_explorer_app/features/news/data/models/article_model.dart';

@GenerateMocks([Dio])
import 'news_remote_data_source_test.mocks.dart';

void main() async{
  await dotenv.load(fileName: ".env");
  late NewsRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = NewsRemoteDataSourceImpl(mockDio);
    reset(mockDio);
  });

  group('NewsRemoteDataSourceImpl - getNewsByCategory', () {
    const category = 'technology';
    const nextPage = '2';

    final mockApiResponse = {
      "results": [
        {
          "article_id": "12345",
          "title": "Flutter 3.22 Released!",
          "description": "Amazing new features",
          "link": "https://flutter.dev/news",
          "image_url": "https://example.com/flutter.jpg",
          "pubDate": "2025-12-01T10:00:00Z",
          "category": ["technology"]
        },
        {
          "article_id": "67890",
          "title": "Dart 3.5 is Here",
          "description": "Faster than ever",
          "link": "https://dart.dev",
          "image_url": null,
          "pubDate": "2025-12-01T08:00:00Z",
          "category": ["programming", "technology"]
        }
      ],
      "nextPage": "3"
    };

    test('should return List<ArticleModel> when API call is successful', () async {

      when(
        mockDio.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        ),
      ).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: '${AppConstants.baseUrl}/latest'),
        data: mockApiResponse,
        statusCode: 200,
      ));

      final result = await dataSource.getNewsByCategory(category, nextPage);

      expect(result, isA<List<ArticleModel>>());
      expect(result.length, 2);
      expect(result[0].title, 'Flutter 3.22 Released!');
      expect(result[1].title, 'Dart 3.5 is Here');
      expect(result[0].modelArticleId, '12345');
      expect(result[1].modelImageUrl, null);

      verify(mockDio.get(
        '${AppConstants.baseUrl}/latest',
        queryParameters: {
          'apikey': AppConstants.apiKey,
          'category': category,
          'language': 'en',
          'page': nextPage,
        },
      )).called(1);
    });

    test('should return articles without page parameter when nextPage is null', () async {
      when(
        mockDio.get(any, queryParameters: anyNamed('queryParameters')),
      ).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: mockApiResponse,
        statusCode: 200,
      ));

      await dataSource.getNewsByCategory(category, null);

      verify(mockDio.get(
        '${AppConstants.baseUrl}/latest',
        queryParameters: {
          'apikey': AppConstants.apiKey,
          'category': category,
          'language': 'en',
          // 'page' should NOT be present
        },
      )).called(1);
    });

    test('should throw Exception when status code is not 200', () async {
      when(
        mockDio.get(any, queryParameters: anyNamed('queryParameters')),
      ).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: {'error': 'Not found'},
        statusCode: 404,
      ));

      expect(
            () => dataSource.getNewsByCategory(category, null),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw Exception on DioException (network error)', () async {
      when(
        mockDio.get(any, queryParameters: anyNamed('queryParameters')),
      ).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        message: 'Connection timeout',
        type: DioExceptionType.connectionTimeout,
      ));

      expect(
            () => dataSource.getNewsByCategory(category, null),
        throwsA(predicate<Exception>((e) => e.toString().contains('Network error'))),
      );
    });
  });

  group('NewsRemoteDataSourceImpl - searchNews', () {
    const query = 'flutter';
    const nextPage = '3';

    final searchResponse = {
      "results": [
        {
          "article_id": "flutter001",
          "title": "Top 10 Flutter Tips",
          "link": "https://medium.com/flutter",
          "pubDate": "2025-11-30T00:00:00Z"
        }
      ]
    };

    test('should return search results successfully', () async {
      when(
        mockDio.get(any, queryParameters: anyNamed('queryParameters')),
      ).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: searchResponse,
        statusCode: 200,
      ));

      final result = await dataSource.searchNews(query, nextPage);

      expect(result.length, 1);
      expect(result[0].title, 'Top 10 Flutter Tips');

      verify(mockDio.get(
        '${AppConstants.baseUrl}/latest',
        queryParameters: {
          'apikey': AppConstants.apiKey,
          'q': query,
          'language': 'en',
          'page': nextPage,
        },
      )).called(1);
    });
  });
}