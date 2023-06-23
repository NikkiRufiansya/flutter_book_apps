

class Book {
  final int? id;
  final String code;
  final String isbn;
  final String title;
  final String description;
  final String category;
  final String publishDate;
  final double price;
  final bool hardCover;

  Book({
    this.id,
    required this.code,
    required this.isbn,
    required this.title,
    required this.description,
    required this.category,
    required this.publishDate,
    required this.price,
    required this.hardCover,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'isbn': isbn,
      'title': title,
      'description': description,
      'category': category,
      'publishDate': publishDate,
      'price': price,
      'hardCover': hardCover ? 1 : 0,
    };
  }
}
