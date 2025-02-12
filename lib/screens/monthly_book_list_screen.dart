import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class MonthlyListScreen extends StatefulWidget {
  @override
  _MonthlyListScreenState createState() => _MonthlyListScreenState();
}

class _MonthlyListScreenState extends State<MonthlyListScreen> {
  List<Book> monthlyBooks = [];
  Map<String, String> bookImageMap = {}; // Kitap-resim eşleştirmesi için
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

  // Aylık listeden kitapları çekme
  Future<void> fetchMonthlyBooks() async {
    try {
      final snapshot = await _firestore.collection('monthly_books').get();
      setState(() {
        monthlyBooks = snapshot.docs.map((doc) {
          final book = Book.fromFirestore(doc.data(), doc.id);
          return book;
        }).toList();

        // Resim eşleşmesini kontrol et ve eksikse ekle
        for (int i = 0; i < monthlyBooks.length; i++) {
          final book = monthlyBooks[i];
          if (!bookImageMap.containsKey(book.id)) {
            bookImageMap[book.id] = images[i % images.length];
          }
        }
      });
    } catch (e) {
      print("Aylık liste kitaplarını çekerken hata oluştu: $e");
    }
  }

  // Kitabı aylık listeden silme
  Future<void> removeFromMonthlyList(String bookId) async {
    try {
      await _firestore.collection('monthly_books').doc(bookId).delete();
      setState(() {
        monthlyBooks.removeWhere((book) => book.id == bookId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kitap aylık listeden çıkarıldı.")),
      );
    } catch (e) {
      print("Kitap aylık listeden çıkarılırken hata oluştu: $e");
    }
  }

  String getBookImage(Book book) {
    return bookImageMap[book.id] ?? images[0]; // Kitap resmini getir
  }

  @override
  void initState() {
    super.initState();
    fetchMonthlyBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aylık Liste',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: monthlyBooks.isNotEmpty
          ? ListView.builder(
              itemCount: monthlyBooks.length,
              itemBuilder: (context, index) {
                final book = monthlyBooks[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                          width: 100,
                          height: 130,
                        ),
                      ),
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
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 10),
                              // Aksiyon Düğmesi
                              Row(
                                children: [
                                  // Listeden Çıkarma Butonu
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () =>
                                        removeFromMonthlyList(book.id),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          : Center(
              child: Text(
                'Henüz aylık listeye kitap eklenmemiş.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
    );
  }
}
