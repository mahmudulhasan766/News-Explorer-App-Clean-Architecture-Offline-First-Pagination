import 'package:equatable/equatable.dart';
import '../../domain/entities/article.dart';

abstract class NewsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<Article> articles;
  final bool hasMore;
  final bool isPaginating;

  NewsLoaded({
    required this.articles,
    this.hasMore = true,
    this.isPaginating = false,
  });

  NewsLoaded copyWith({
    List<Article>? articles,
    bool? hasMore,
    bool? isPaginating,
  }) {
    return NewsLoaded(
      articles: articles ?? this.articles,
      hasMore: hasMore ?? this.hasMore,
      isPaginating: isPaginating ?? this.isPaginating,
    );
  }

  @override
  List<Object?> get props => [articles, hasMore, isPaginating];
}

class NewsEmpty extends NewsState {}

class NewsError extends NewsState {
  final String message;

  NewsError(this.message);

  @override
  List<Object?> get props => [message];
}