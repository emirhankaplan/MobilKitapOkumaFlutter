import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication import
import 'book_detail_screen.dart';
import 'favorites_screen.dart';
import 'monthly_book_list_screen.dart';
import 'profil_screen.dart';
import '../models/book.dart';
import 'login_screen.dart'; // Login ekranına geri dönüş için gerekli

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Book> books = [];
  Map<String, String> bookImageMap = {}; // Her kitabı resimle eşleştirmek için
  String selectedCategory = 'Tümü';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance

  // Fixed list of images
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

  Future<void> fetchBooks() async {
    try {
      final snapshot = await _firestore.collection('books').get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          books = snapshot.docs.map((doc) {
            final book = Book.fromFirestore(doc.data(), doc.id);
            return book;
          }).toList();

          // Eşleşmemiş kitapları resimle eşleştir
          for (int i = 0; i < books.length; i++) {
            final book = books[i];
            if (!bookImageMap.containsKey(book.id)) {
              bookImageMap[book.id] = images[i % images.length];
            }
          }
        });
      } else {
        print("Kitap Yok.");
      }
    } catch (e) {
      print("Hata: $e");
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginScreen()), // Login ekranına yönlendirme
    );
  }

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  List<String> get categories {
    if (books.isEmpty) {
      return ['Tümü'];
    }
    final allCategories = books.map((book) => book.category).toSet().toList();
    allCategories.insert(0, 'Tümü');
    return allCategories;
  }

  List<Book> get filteredBooks {
    if (selectedCategory == 'Tümü') {
      return books;
    }
    return books.where((book) => book.category == selectedCategory).toList();
  }

  String getBookImage(Book book) {
    return bookImageMap[book.id] ?? images[0];
  }

  Future<void> addToFavorites(Book book) async {
    try {
      await _firestore
          .collection('favorites')
          .doc(book.id)
          .set(book.toFirestore());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${book.title} Favorilere Eklendi!")),
      );
    } catch (e) {
      print("Favorilere Eklenirken Hata Olustu: $e");
    }
  }

  Future<void> addToProfile(Book book) async {
    try {
      await _firestore
          .collection('profile_books')
          .doc(book.id)
          .set(book.toFirestore());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${book.title} Profile Eklendi!")),
      );
    } catch (e) {
      print("Profile Eklenirken Hata Olustu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Kitap Kurdu',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Çıkış Yap',
          ),
          IconButton(
            icon: Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightBlueAccent, Colors.purpleAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 100),
              // Categories Section
              Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: selectedCategory == category,
                          selectedColor: Colors.deepPurpleAccent,
                          backgroundColor: Colors.grey.shade200,
                          onSelected: (isSelected) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Book Grid Section
              Expanded(
                child: filteredBooks.isNotEmpty
                    ? GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: filteredBooks.length,
                        itemBuilder: (context, index) {
                          final book = filteredBooks[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BookDetailScreen(book: book),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  // Book Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      getBookImage(book),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  // Action Buttons Overlay
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.favorite_border,
                                              color: Colors.white),
                                          onPressed: () => addToFavorites(book),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add,
                                              color: Colors.white),
                                          onPressed: () => addToProfile(book),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Kitap',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favori',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Aylık',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavoritesScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MonthlyListScreen()),
            );
          }
        },
      ),
    );
  }
}
