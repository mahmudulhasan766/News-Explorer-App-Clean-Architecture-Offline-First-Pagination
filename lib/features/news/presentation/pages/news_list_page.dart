import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:news_explorer_app/core/utils/app_string.dart';
import 'package:news_explorer_app/features/news/presentation/widgets/build_article_card.dart';
import '../providers/news_provider.dart';
import '../providers/news_state.dart';
import 'article_detail_page.dart';

class NewsListPage extends ConsumerStatefulWidget {
  const NewsListPage({super.key});

  @override
  ConsumerState<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends ConsumerState<NewsListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'business';

  final List<String> _categories = [
    'business',
    'technology',
    'sports',
    'entertainment',
    'health',
    'science',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(newsNotifierProvider.notifier).loadNews(_selectedCategory);
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(newsNotifierProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newsState = ref.watch(newsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.newsExplorer),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search news...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(newsNotifierProvider.notifier)
                            .loadNews(_selectedCategory);
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (query) {
                    ref.read(newsNotifierProvider.notifier).search(query);
                  },
                ),
              ),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(
                          category.toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = category);
                            _searchController.clear();
                            ref.read(newsNotifierProvider.notifier)
                                .loadNews(category);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(newsState),
    );
  }

  Widget _buildBody(NewsState state) {
    if (state is NewsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is NewsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(newsNotifierProvider.notifier)
                  .loadNews(_selectedCategory),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is NewsEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No articles found'),
          ],
        ),
      );
    }

    if (state is NewsLoaded) {
      return RefreshIndicator(
        onRefresh: () async {
          ref.read(newsNotifierProvider.notifier).loadNews(_selectedCategory);
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: state.articles.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.articles.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final article = state.articles[index];
            return  BuildArticleCard(article: article);
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
