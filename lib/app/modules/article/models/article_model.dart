class Article {
  final int id;
  final String title;
  final String content;
  final String imageUrl;
  final String category;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.category,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? 'Edukasi',
    );
  }
}