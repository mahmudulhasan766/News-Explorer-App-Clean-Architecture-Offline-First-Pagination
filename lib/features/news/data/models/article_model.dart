import 'package:hive/hive.dart';
import 'package:news_explorer_app/core/utils/constants.dart';
import '../../domain/entities/article.dart';

part 'article_model.g.dart';

@HiveType(typeId: 0)
class ArticleModel extends Article {
  @HiveField(0)
  final String? modelArticleId;

  @HiveField(1)
  final String modelTitle;

  @HiveField(2)
  final String? modelDescription;

  @HiveField(3)
  final String? modelImageUrl;

  @HiveField(4)
  final String? modelSourceUrl;

  @HiveField(5)
  final DateTime modelPubDate;

  @HiveField(6)
  final String? modelCategory;

  @HiveField(7)
  final DateTime cachedAt;

  ArticleModel({
    this.modelArticleId,
    required this.modelTitle,
    this.modelDescription,
    this.modelImageUrl,
    this.modelSourceUrl,
    required this.modelPubDate,
    this.modelCategory,
    DateTime? cachedAt,
  }) : cachedAt = cachedAt ?? DateTime.now(),
        super(
        articleId: modelArticleId,
        title: modelTitle,
        description: modelDescription,
        imageUrl: modelImageUrl,
        sourceUrl: modelSourceUrl,
        pubDate: modelPubDate,
        category: modelCategory,
      );

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      modelArticleId: json['article_id'],
      modelTitle: json['title'] ?? 'No Title',
      modelDescription: json['description'],
      modelImageUrl: json['image_url'],
      modelSourceUrl: json['link'],
      modelPubDate: DateTime.parse(json['pubDate'] ?? DateTime.now().toIso8601String()),
      modelCategory: json['category']?[0],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'article_id': modelArticleId,
      'title': modelTitle,
      'description': modelDescription,
      'image_url': modelImageUrl,
      'link': modelSourceUrl,
      'pubDate': modelPubDate.toIso8601String(),
      'category': modelCategory != null ? [modelCategory] : null,
    };
  }

  bool get isExpired {
    final expirationTime = cachedAt.add(
      const Duration(hours: AppConstants.cacheExpirationHours),
    );
    return DateTime.now().isAfter(expirationTime);
  }
}