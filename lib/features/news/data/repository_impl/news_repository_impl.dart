
import 'package:dartz/dartz.dart';
import 'package:news_explorer_app/core/utils/app_print_log.dart';
import 'package:news_explorer_app/features/news/domain/repository/news_repository.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/article.dart';
import '../datasources/news_local_data_source.dart';
import '../datasources/news_remote_data_source.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Article>>> getNewsByCategory(
      String category,
      String? nextPage,
      ) async {
    try {
      final articles = await remoteDataSource.getNewsByCategory(category, nextPage);

      // Cache only first page
      if (nextPage == null) {
        await localDataSource.cacheNews(articles, category);
      }
      printLog("------------------1 $articles");
      return Right(articles);
    } catch (e) {
      // If network fails, try to get cached data
      try {
        final cachedArticles = await localDataSource.getCachedNews(category);
        if (cachedArticles.isNotEmpty) {
          return Right(cachedArticles);
        }
        return Left(NetworkFailure('No internet and no cached data'));
      } catch (cacheError) {
        return Left(CacheFailure('Failed to load cached data'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Article>>> searchNews(
      String query,
      String? nextPage,
      ) async {
    try {
      final articles = await remoteDataSource.searchNews(query, nextPage);
      return Right(articles);
    } catch (e) {
      // Fallback to local search
      try {
        final cachedArticles = await localDataSource.searchCachedNews(query);
        if (cachedArticles.isNotEmpty) {
          return Right(cachedArticles);
        }
        return Left(NetworkFailure('No results found'));
      } catch (cacheError) {
        return Left(ServerFailure('Search failed'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Article>>> getCachedNews(String category) async {
    try {
      final articles = await localDataSource.getCachedNews(category);
      printLog("------------------$articles");
      return Right(articles);
    } catch (e) {
      return Left(CacheFailure('Failed to load cached news'));
    }
  }
}