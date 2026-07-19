class Article {
  final int id;
  final String title;
  final String content;
  final String category;
  final String imageUrl;
  final String? sourceName;
  final String? sourceUrl;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.imageUrl,
    this.sourceName,
    this.sourceUrl,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      imageUrl: json['image_url'] ?? '',
      sourceName: json['source_name'],
      sourceUrl: json['source_url'],
    );
  }
}