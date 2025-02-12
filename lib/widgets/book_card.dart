// widgets/book_card.dart
import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;

  BookCard({required this.title, required this.author});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(author),
      ),
    );
  }
}
