class Book {
  final String id;
  final String title;
  final String author;
  final int pageCount;
  final int publishYear;
  final String category;
  final String? imagePath;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.pageCount,
    required this.publishYear,
    required this.category,
    this.imagePath,
  });
  factory Book.fromMap(Map<String, dynamic> data, String documentId) {
    return Book(
      id: documentId,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      pageCount: data['pageCount'] ?? 0,
      publishYear: data['publishYear'] ?? 0,
      category: data['category'] ?? '',
      imagePath: data['imageUrl'],
    );
  }

  factory Book.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Book(
      id: documentId,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      pageCount: data['pageCount'] ?? 0,
      publishYear: data['publishYear'] ?? 0,
      category: data['category'] ?? '',
      imagePath: data['imagePath'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'pageCount': pageCount,
      'publishYear': publishYear,
      'category': category,
      'imagePath': imagePath,
    };
  }
}
