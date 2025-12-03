import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:news_explorer_app/core/utils/constants.dart';
import '../models/article_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<ArticleModel>> getNewsByCategory(String category, String? nextPage);
  Future<List<ArticleModel>> searchNews(String query, String? nextPage);
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final Dio dio;

  NewsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ArticleModel>> getNewsByCategory(String category, String? nextPage) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/latest',
        queryParameters: {
          'apikey': AppConstants.apiKey,
       /*   'category': category,
          'language': 'en',
          if (nextPage != null) 'page': nextPage,*/
        },
      );
      log("----------------- ${response.data}");
      if (response.statusCode == 200) {
        final results = response.data['results'] as List;
        log("-----------------22 ${results.length}");
        return results.map((json) => ArticleModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load news');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<List<ArticleModel>> searchNews(String query, String? nextPage) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/latest',
        queryParameters: {
          'apikey': AppConstants.apiKey,
          'q': query,
          'language': 'en',
          if (nextPage != null) 'page': nextPage,
        },
      );

      if (response.statusCode == 200) {
        final results = response.data['results'] as List;
        return results.map((json) => ArticleModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search news');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}