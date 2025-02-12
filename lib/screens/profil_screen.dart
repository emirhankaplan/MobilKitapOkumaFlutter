import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Book> profileBooks = [];
  Map<String, String> bookImageMap = {}; // Her kitabı resimle eşleştirmek için
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> fetchProfileBooks() async {
    try {
      final snapshot = await _firestore.collection('profile_books').get();
      setState(() {
        profileBooks = snapshot.docs.map((doc) {
          final book = Book.fromFirestore(doc.data(), doc.id);
          return book;
        }).toList();

        for (int i = 0; i < profileBooks.length; i++) {
          final book = profileBooks[i];
          if (!bookImageMap.containsKey(book.id)) {
            bookImageMap[book.id] = images[i % images.length];
          }
        }
      });
    } catch (e) {
      print("Profil kitaplarını çekerken hata oluştu: $e");
    }
  }

  Future<void> removeFromProfile(String bookId) async {
    try {
      await _firestore.collection('profile_books').doc(bookId).delete();
      setState(() {
        profileBooks.removeWhere((book) => book.id == bookId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kitap profilden silindi.")),
      );
    } catch (e) {
      print("Kitap silinirken hata oluştu: $e");
    }
  }

  Future<void> addToMonthlyList(Book book) async {
    try {
      await _firestore
          .collection('monthly_books')
          .doc(book.id)
          .set(book.toFirestore());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${book.title} aylık listeye eklendi!")),
      );
    } catch (e) {
      print("Kitap aylık listeye eklenirken hata oluştu: $e");
    }
  }

  String getBookImage(Book book) {
    return bookImageMap[book.id] ?? images[0]; // Kitap resmini getir
  }

  @override
  void initState() {
    super.initState();
    fetchProfileBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Kitaplarım',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Stack(
        children: [
          // Arka Plan Renk Geçişi
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          profileBooks.isNotEmpty
              ? ListView.builder(
                  itemCount: profileBooks.length,
                  itemBuilder: (context, index) {
                    final book = profileBooks[index];
                    return Container(
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Kitap Resmi
                            ClipRRect(
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(15),
                              ),
                              child: Image.asset(
                                getBookImage(book),
                                fit: BoxFit.cover,
                                width: 120,
                                height: 150,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Kitap Başlığı
                                    Text(
                                      book.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8),
                                    // Yazar
                                    Text(
                                      book.author,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    // Aksiyon Butonları
                                    Row(
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              addToMonthlyList(book),
                                          icon: Icon(Icons.calendar_today),
                                          label: Text('Aylık Liste'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent,
                                            textStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              removeFromProfile(book.id),
                                          icon: Icon(Icons.delete),
                                          label: Text('Sil'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                            textStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Text(
                    'Profil kitaplarınız yok.',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ),
        ],
      ),
    );
  }
}
