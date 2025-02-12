import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Book> favoriteBooks = [];
  Map<String, String> bookImageMap = {}; // Her kitap için resim eşleştirme

  // Sabit resim listesi
  final List<String> images = [
    'assets/book1.jpeg',
    'assets/book2.jpeg',
    'assets/book3.jpeg',
    'assets/book4.jpeg',
    'assets/book5.jpeg',
    'assets/book6.jpeg',
    'assets/book7.jpeg',
    'assets/book8.jpeg',
    'assets/book9.jpeg',
    'assets/book10.jpeg',
  ];

  // Firestore'dan favori kitapları çekme
  Future<void> fetchFavoriteBooks() async {
    try {
      final snapshot = await _firestore.collection('favorites').get();
      setState(() {
        favoriteBooks = snapshot.docs.map((doc) {
          final book = Book.fromFirestore(doc.data(), doc.id);
          return book;
        }).toList();

        // Resim eşleşmesini kontrol et ve eksikse ekle
        for (int i = 0; i < favoriteBooks.length; i++) {
          final book = favoriteBooks[i];
          if (!bookImageMap.containsKey(book.id)) {
            bookImageMap[book.id] = images[i % images.length];
          }
        }
      });
    } catch (e) {
      print("Favori kitapları çekerken hata oluştu: $e");
    }
  }

  // Favorilerden kitap çıkarma
  Future<void> removeFromFavorites(String bookId) async {
    try {
      await _firestore.collection('favorites').doc(bookId).delete();
      setState(() {
        favoriteBooks.removeWhere((book) => book.id == bookId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kitap favorilerden çıkarıldı.")),
      );
    } catch (e) {
      print("Favorilerden çıkarılırken hata oluştu: $e");
    }
  }

  String getBookImage(Book book) {
    return bookImageMap[book.id] ?? images[0]; // Resim eşleşmesi varsa döndür
  }

  @override
  void initState() {
    super.initState();
    fetchFavoriteBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favoriler'),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: favoriteBooks.isNotEmpty
          ? ListView.builder(
              itemCount: favoriteBooks.length,
              itemBuilder: (context, index) {
                final book = favoriteBooks[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      // Kitap Resmi
                      ClipRRect(
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(15),
                        ),
                        child: Image.asset(
                          getBookImage(book),
                          fit: BoxFit.cover,
                          width: 100,
                          height: 120,
                        ),
                      ),
                      // Kitap Bilgileri
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 5),
                              Text(
                                book.author,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Favorilerden Çıkarma Butonu
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeFromFavorites(book.id),
                      ),
                    ],
                  ),
                );
              },
            )
          : Center(
              child: Text(
                'Henüz favorilere eklenmiş kitap yok.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
    );
  }
}
