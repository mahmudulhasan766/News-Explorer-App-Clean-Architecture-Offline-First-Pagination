import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String? articleId;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? sourceUrl;
  final DateTime pubDate;
  final String? category;

  const Article({
    this.articleId,
    required this.title,
    this.description,
    this.imageUrl,
    this.sourceUrl,
    required this.pubDate,
    this.category,
  });

  @override
  List<Object?> get props => [
    articleId,
    title,
    description,
    imageUrl,
    sourceUrl,
    pubDate,
    category,
  ];
}
