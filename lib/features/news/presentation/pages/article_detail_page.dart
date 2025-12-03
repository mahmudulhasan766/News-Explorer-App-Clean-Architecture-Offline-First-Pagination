import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/article.dart';

class ArticleDetailPage extends StatelessWidget {
  final Article? article;

  const ArticleDetailPage({super.key, this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                '${article?.title ?? ""}\n\n${article?.sourceUrl ?? ""}',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article?.imageUrl != null)
              CachedNetworkImage(
                imageUrl: article?.imageUrl ?? "",
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article?.title ?? "",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMMM dd, yyyy').format(article!.pubDate),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (article?.category != null) ...[
                    const SizedBox(height: 8),
                    Chip(
                      label: Text((article?.category ?? "").toUpperCase()),
                      backgroundColor: Colors.blue[100],
                    ),
                  ],
                  if (article?.description != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      article?.description ?? "",
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
