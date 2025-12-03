import 'package:dartz/dartz.dart';
import 'package:news_explorer_app/features/news/domain/repository/news_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/article.dart';

class GetNewsByCategory implements UseCase<List<Article>, NewsCategoryParams> {
  final NewsRepository repository;

  GetNewsByCategory(this.repository);

  @override
  Future<Either<Failure, List<Article>>> call(NewsCategoryParams params) async {
    return await repository.getNewsByCategory(params.category, params.nextPage);
  }
}

class NewsCategoryParams {
  final String category;
  final String? nextPage;

  NewsCategoryParams({required this.category, this.nextPage});
}