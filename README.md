📰 News Explorer App

Clean Architecture + Offline-First + Pagination + Riverpod

A lightweight, modular Flutter application that fetches categorized news from a free API, supports offline caching, and provides infinite scrolling. Built with Clean Architecture and testability in mind.

🚀 Features
✅ 1. Fetch News by Category

Uses the NewsData.io free API.
Example Endpoint:

https://newsdata.io/api/1/news?apikey=<API_KEY>&category=business

✅ 2. Infinite Pagination
Scroll to the end → next page loads automatically.
✅ 3. Offline-First Caching (with Hive/Drift)
Shows cached articles when offline
Auto-refreshes local DB when online
Cached data expires after 1 hour
Local DB supports category + search queries
✅ 4. Search
Online search via API
Fallback to local DB when offline
✅ 5. Article Details Page

Includes:
Image
Title
Description
Publication date
Share button

✅ 6. Clean Architecture + Riverpod

Fully modular, testable, and scalable.

🧱 Project Structure
lib/
├── core/
│   ├── error/
│   ├── usecase/
│   └── utils/
│
├── features/
│   └── news/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── news_local_data_source.dart
│       │   │   └── news_remote_data_source.dart
│       │   ├── models/
│       │   │   ├── article_model.dart
│       │   │   └── article_model.g.dart
│       │   └── repository_impl/
│       │       └── news_repository_impl.dart
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   └── article.dart
│       │   ├── repository/
│       │   │   └── news_repository.dart
│       │   └── usecases/
│       │       ├── get_news_by_category.dart
│       │       └── search_news.dart
│       │
│       └── presentation/
│           ├── pages/
│           │   ├── article_detail_page.dart
│           │   └── news_list_page.dart
│           ├── providers/
│           │   ├── news_provider.dart
│           │   └── news_state.dart
│           └── widgets/
│               └── build_article_card.dart
│
└── main.dart

🧩 Clean Architecture Overview
Domain Layer
Pure business logic:
Entities
Repositories (abstract)
Use cases
Example use cases:
GetNewsByCategoryUsecase
SearchNewsUsecase
Data Layer
Handles data sources:
RemoteDataSource → Dio, NewsData.io
LocalDataSource → Hive
flutter pub run build_runner build --delete-conflicting-outputs
Repository implementation using Either pattern (Failure / Success)
Presentation Layer

Riverpod Notifiers managing UI states:
Loading
Data
Empty
Error
Paginating

📡 Data Flow Diagram
+----------------------+
|   Presentation       |
| (Riverpod Notifiers) |
+----------+-----------+
|
|  calls
v
+----------------------+
|       Domain         |
|   (Use Cases)        |
+----------+-----------+
|
|  requests
v
+----------------------+
|        Data          |
| Repository Impl      |
+----+-----------+-----+
|           |
fetches |           | reads/writes
v           v
+----------------+   +----------------+
| Remote Source  |   | Local Source   |
| (API via Dio)  |   | (Hive/Drift)   |
+----------------+   +----------------+

📦 Offline Caching Logic
1. On App Startup
   Load cached news
   If expired (> 1 hour), fetch new data
   Save updated data locally
2. During Pagination
   If online → fetch page N
   If offline → load next batch from cache
3. During Search
   If online → call API
   If offline → run local DB query
4. Cache Expiration
   Each article stored with:
   timestamp: DateTime
   Expired if:

DateTime.now().difference(timestamp) > 1 hour

🧪 Unit Testing
Minimum 4 required tests are implemented:
✔ Usecase Test
news_usecase_test.dart
✔ Repository Test
news_repository_test.dart
✔ Remote Data Source Test
news_remote_data_source_test.dart
✔ Local Data Source Test
news_local_data_source_test.dart

🔐 Environment Variables
Create a .env file in the project root:

API_KEY=NEWS_API_KEY_HERE
BASE_URL=https://newsdata.io/api/1
CACHE_EXPIRATION_MINUTES=60

Add to pubspec.yaml:
flutter_dotenv: ^5.1.0

Load it in main.dart:
await dotenv.load(fileName: ".env");

📸 Screenshots / Recordings
https://drive.google.com/file/d/1mBi2iQCrr21SK1_a7NLIZvDWzsWBg9xC/view?usp=sharing

https://drive.google.com/file/d/1aY2ZiEwqXPshxpQ4CJd_wjREAobr8Ybh/view?usp=sharing

https://drive.google.com/file/d/1rPOcZuPOisw7H_BN1uf7ukrAGTU6I_zo/view?usp=sharing

https://drive.google.com/file/d/1CGteS1AHufrOf5nezo6JR5MR-GChDl7e/view?usp=sharing

Apk: 
https://drive.google.com/file/d/11PNo6TxO6jcxIVHE_qiVZKp_rDyFYjfm/view?usp=sharing

Add before submitting:
Home Page
Pagination demo
Offline mode demo
Search results
Detail page

🛠 Tech Stack
Flutter
Riverpod
Dio
Hive

Free News API (NewsData.io)
Clean Architecture


1. Install dependencies
   flutter pub get
2. Add .env file
   (from section above)
3. Run the app
   flutter run
4. Unit Tests
   📄 How to Run
   flutter pub add --dev mocktail
   flutter pub run build_runner build --delete-conflicting-outputs
   flutter test test/news_remote_data_source_test.dart
   flutter test test/news_local_data_source_test.dart
   flutter test test/news_repository_test.dart
   flutter test test/news_usecase_tast.dart

   