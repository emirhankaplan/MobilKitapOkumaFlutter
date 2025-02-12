import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobilproje/screens/EditBookScreen.dart';
import '../models/book.dart';
import 'add_book_screen.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addBook(Book book) async {
    try {
      await _firestore.collection('books').add({
        'title': book.title,
        'author': book.author,
        'pageCount': book.pageCount,
        'publishYear': book.publishYear,
        'category': book.category,
        'imageUrl': book.imagePath,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kitap başarıyla eklendi!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kitap eklenirken bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteBook(String bookId) async {
    try {
      await _firestore.collection('books').doc(bookId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kitap başarıyla silindi!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {}); // Listeyi yenile
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kitap silinirken bir hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<Book>> _fetchBooks() async {
    try {
      final snapshot = await _firestore.collection('books').get();
      return snapshot.docs.map((doc) {
        return Book.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print('Kitapları çekerken hata oluştu: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Paneli',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context); // Çıkış yap
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Başlık
            Text(
              'Hoş Geldiniz, Admin!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Yeni bir kitap ekleyebilir veya mevcut kitapları düzenleyebilirsiniz.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            // Kitap Ekle Butonu
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final Book? book = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddBookScreen(),
                    ),
                  );
                  if (book != null) {
                    _addBook(book);
                  }
                },
                icon: Icon(Icons.add, size: 24),
                label: Text(
                  'Kitap Ekle',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: FutureBuilder<List<Book>>(
                future: _fetchBooks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'Mevcut kitap bulunamadı.',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }
                  final books = snapshot.data!;
                  return ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(book.title),
                          subtitle: Text(book.author),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditBookScreen(book: book),
                                    ),
                                  ).then((value) {
                                    if (value == true) {
                                      setState(() {}); // Listeyi yenile
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteBook(book.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
