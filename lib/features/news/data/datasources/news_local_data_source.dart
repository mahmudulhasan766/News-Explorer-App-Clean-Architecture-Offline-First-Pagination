import 'package:hive/hive.dart';
import '../models/article_model.dart';

abstract class NewsLocalDataSource {
  Future<List<ArticleModel>> getCachedNews(String category);
  Future<void> cacheNews(List<ArticleModel> articles, String category);
  Future<List<ArticleModel>> searchCachedNews(String query);
  Future<void> clearExpiredCache();
}

class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  static const String boxName = 'news_cache';

  @override
  Future<List<ArticleModel>> getCachedNews(String category) async {
    final box = await Hive.openBox<ArticleModel>(boxName);
    final articles = box.values
        .where((article) =>
    article.modelCategory == category &&
        !article.isExpired)
        .toList();
    return articles;
  }

  @override
  Future<void> cacheNews(List<ArticleModel> articles, String category) async {
    final box = await Hive.openBox<ArticleModel>(boxName);

    // Clear old articles from this category
    final keysToDelete = box.keys
        .where((key) {
      final article = box.get(key);
      return article?.modelCategory == category;
    })
        .toList();

    await box.deleteAll(keysToDelete);

    // Add new articles
    for (var article in articles) {
      await box.add(article);
    }
  }

  @override
  Future<List<ArticleModel>> searchCachedNews(String query) async {
    final box = await Hive.openBox<ArticleModel>(boxName);
    final lowerQuery = query.toLowerCase();

    return box.values
        .where((article) =>
    !article.isExpired &&
        (article.modelTitle.toLowerCase().contains(lowerQuery) ||
            (article.modelDescription?.toLowerCase().contains(lowerQuery) ?? false)))
        .toList();
  }

  @override
  Future<void> clearExpiredCache() async {
    final box = await Hive.openBox<ArticleModel>(boxName);
    final expiredKeys = box.keys
        .where((key) {
      final article = box.get(key);
      return article?.isExpired ?? false;
    })
        .toList();

    await box.deleteAll(expiredKeys);
  }
}