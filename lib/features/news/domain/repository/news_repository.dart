import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/article.dart';

abstract class NewsRepository {
  Future<Either<Failure, List<Article>>> getNewsByCategory(String category, String? nextPage);
  Future<Either<Failure, List<Article>>> searchNews(String query, String? nextPage);
  Future<Either<Failure, List<Article>>> getCachedNews(String category);
}