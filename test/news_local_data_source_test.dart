import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:news_explorer_app/features/news/data/datasources/news_local_data_source.dart';
import 'package:news_explorer_app/features/news/data/models/article_model.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  late NewsLocalDataSource localDataSource;
  late Box<ArticleModel> box;

  // Helper function to create articles
  ArticleModel createArticle({
    String? id,
    required String title,
    String? description,
    String? category,
    DateTime? cachedAt,
  }) {
    return ArticleModel(
      modelArticleId: id,
      modelTitle: title,
      modelDescription: description,
      modelSourceUrl: 'https://example.com',
      modelImageUrl: null,
      modelPubDate: DateTime.now(),
      modelCategory: category ?? 'general',
      cachedAt: cachedAt ?? DateTime.now(),
    );
  }

  setUp(() async {
    await setUpTestHive();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ArticleModelAdapter());
    }

    box = await Hive.openBox<ArticleModel>(NewsLocalDataSourceImpl.boxName);
    localDataSource = NewsLocalDataSourceImpl();
  });

  tearDown(() async {
    await box.clear();
    await box.close();
    await tearDownTestHive();
  });

  group('NewsLocalDataSourceImpl', () {
    test('getCachedNews returns cached articles for the requested category (non-expired)', () async {
      final freshTech = createArticle(
        id: '1',
        title: 'Fresh Tech News',
        category: 'technology',
        cachedAt: DateTime.now(), // ensure not expired
      );

      final freshSports = createArticle(
        id: '2',
        title: 'Sports Update',
        category: 'sports',
        cachedAt: DateTime.now(),
      );

      await box.addAll([freshTech, freshSports]);

      final result = await localDataSource.getCachedNews('technology');

      expect(result.length, 1);
      expect(result[0].title, 'Fresh Tech News');
    });
    test('getCachedNews filters out expired articles', () async {
      final expired = createArticle(
        id: 'expired1',
        title: 'Old Tech News',
        category: 'technology',
        cachedAt: DateTime.now().subtract(const Duration(days: 30)),
      );

      final fresh = createArticle(
        id: 'fresh1',
        title: 'New Tech',
        category: 'technology',
      );

      await box.addAll([expired, fresh]);

      final result = await localDataSource.getCachedNews('technology');

      expect(result.length, 1);
      expect(result[0].title, 'New Tech');
      expect(result.any((a) => a.title == 'Old Tech News'), false);
    });

    test('cacheNews clears old articles of the same category and saves new ones', () async {
      final oldArticles = [
        createArticle(id: 'old1', title: 'Old Tech 1', category: 'technology'),
        createArticle(id: 'old2', title: 'Old Tech 2', category: 'technology'),
        createArticle(id: 'sports1', title: 'Sports', category: 'sports'),
      ];
      await box.addAll(oldArticles);

      final newArticles = [
        createArticle(id: 'new1', title: 'Flutter 3.24', category: 'technology'),
        createArticle(id: 'new2', title: 'Dart 3.6', category: 'technology'),
      ];

      await localDataSource.cacheNews(newArticles, 'technology');

      final cached = await localDataSource.getCachedNews('technology');
      expect(cached.length, 2);
      expect(cached.map((a) => a.title), containsAll(['Flutter 3.24', 'Dart 3.6']));

      final sports = await localDataSource.getCachedNews('sports');
      expect(sports.length, 1);
      expect(sports[0].title, 'Sports');
    });

    test('searchCachedNews finds articles by title or description (case-insensitive)', () async {
      final articles = [
        createArticle(title: 'Flutter is Awesome', description: 'Best framework', category: 'technology'),
        createArticle(title: 'React vs Flutter', description: 'Comparison', category: 'technology'),
        createArticle(title: 'SwiftUI News', description: 'Apple framework', category: 'technology'),
      ];
      await box.addAll(articles);

      final result = await localDataSource.searchCachedNews('flutter');

      expect(result.length, 2);
      expect(result.any((a) => a.title.contains('Awesome')), true);
      expect(result.any((a) => a.title.contains('React')), true);
      expect(result.any((a) => a.title.contains('SwiftUI')), false);
    });

    test('searchCachedNews ignores expired articles', () async {
      final expired = createArticle(
        title: 'Expired Flutter News',
        cachedAt: DateTime.now().subtract(const Duration(days: 100)),
      );
      final fresh = createArticle(title: 'Fresh Flutter News');

      await box.addAll([expired, fresh]);

      final result = await localDataSource.searchCachedNews('flutter');

      expect(result.length, 1);
      expect(result[0].title, 'Fresh Flutter News');
    });

    test('clearExpiredCache removes only expired articles', () async {
      final expired1 = createArticle(
        id: 'e1',
        title: 'Expired 1',
        cachedAt: DateTime.now().subtract(const Duration(days: 60)),
      );
      final expired2 = createArticle(
        id: 'e2',
        title: 'Expired 2',
        cachedAt: DateTime.now().subtract(const Duration(days: 60)),
      );
      final fresh = createArticle(id: 'f1', title: 'Fresh');

      await box.addAll([expired1, expired2, fresh]);

      await localDataSource.clearExpiredCache();

      final remaining = box.values.toList();
      expect(remaining.length, 1);
      expect(remaining[0].title, 'Fresh');
    });

    test('cacheNews works with empty list (clears category)', () async {
      await box.add(createArticle(title: 'Old', category: 'business'));

      await localDataSource.cacheNews([], 'business');

      final result = await localDataSource.getCachedNews('business');
      expect(result, isEmpty);
    });
  });
}
