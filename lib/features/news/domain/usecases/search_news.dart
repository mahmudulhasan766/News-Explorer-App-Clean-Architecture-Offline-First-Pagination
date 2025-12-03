import 'package:dartz/dartz.dart';
import 'package:news_explorer_app/features/news/domain/repository/news_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article.dart';

class SearchNews implements UseCase<List<Article>, SearchParams> {
  final NewsRepository repository;

  SearchNews(this.repository);

  @override
  Future<Either<Failure, List<Article>>> call(SearchParams params) async {
    return await repository.searchNews(params.query, params.nextPage);
  }
}

class SearchParams {
  final String query;
  final String? nextPage;

  SearchParams({required this.query, this.nextPage});
}