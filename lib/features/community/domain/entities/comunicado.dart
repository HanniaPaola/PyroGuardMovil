class Comunicado {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final DateTime publishDate;
  final DateTime expirationDate;

  const Comunicado({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.publishDate,
    required this.expirationDate,
  });
}
