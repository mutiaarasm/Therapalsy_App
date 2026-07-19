import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article_model.dart';

class ArticleDetailView extends StatelessWidget {
  final Article article;

  const ArticleDetailView({
    super.key,
    required this.article,
  });

  Future<void> openSource() async {
    if (article.sourceUrl == null ||
        article.sourceUrl!.isEmpty) return;

    final uri = Uri.parse(article.sourceUrl!);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: CustomScrollView(
        slivers: [

          // ===== HEADER IMAGE =====
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF316B5C),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    article.imageUrl,
                    fit: BoxFit.cover,
                  ),

                  // 🔥 GRADIENT OVERLAY BIAR GAK TABRAKAN
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),

                  // OPTIONAL: kalau mau title di image (bagus banget UX-nya)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Text(
                      article.title,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== CONTENT =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF316B5C,
                      ).withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    article.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ===== SUMBER =====
                  if (article.sourceName != null &&
                      article.sourceName!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          const Row(
                            children: [
                              Icon(
                                Icons.library_books,
                                size: 20,
                                color: Color(0xFF316B5C),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Sumber Referensi",
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Text(
                            article.sourceName!,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 10),

                          ElevatedButton.icon(
                            onPressed: openSource,
                            icon: const Icon(
                              Icons.open_in_new,
                            ),
                            label:
                                const Text("Buka Sumber"),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}