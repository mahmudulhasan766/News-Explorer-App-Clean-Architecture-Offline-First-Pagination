import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static final String apiKey = dotenv.get("API_KEY");
  static const String baseUrl = 'https://newsdata.io/api/1';
  static const int cacheExpirationHours = 1;
  static const int pageSize = 10;
}