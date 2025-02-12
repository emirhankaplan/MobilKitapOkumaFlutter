import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBookScreen extends StatefulWidget {
  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pageCountController = TextEditingController();
  final _publishYearController = TextEditingController();
  final _categoryController = TextEditingController();
  final _imageUrlController = TextEditingController();

  Future<void> _submitBook() async {
    if (_formKey.currentState!.validate()) {
      final book = {
        'title': _titleController.text.trim(),
        'author': _authorController.text.trim(),
        'pageCount': int.parse(_pageCountController.text.trim()),
        'publishYear': int.parse(_publishYearController.text.trim()),
        'category': _categoryController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
      };

      try {
        await FirebaseFirestore.instance.collection('books').add(book);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kitap başarıyla eklendi!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kitap eklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kitap Ekle',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Başlık
                    Text(
                      'Kitap Bilgilerini Girin',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Kitap Adı
                    _buildTextField(
                      controller: _titleController,
                      label: 'Kitap Adı',
                      icon: Icons.book,
                    ),
                    SizedBox(height: 15),
                    // Yazar
                    _buildTextField(
                      controller: _authorController,
                      label: 'Yazar',
                      icon: Icons.person,
                    ),
                    SizedBox(height: 15),
                    // Sayfa Sayısı
                    _buildTextField(
                      controller: _pageCountController,
                      label: 'Sayfa Sayısı',
                      icon: Icons.numbers,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 15),
                    // Basım Yılı
                    _buildTextField(
                      controller: _publishYearController,
                      label: 'Basım Yılı',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 15),
                    // Kategori
                    _buildTextField(
                      controller: _categoryController,
                      label: 'Kategori',
                      icon: Icons.category,
                    ),
                    SizedBox(height: 15),
                    // Resim URL
                    _buildTextField(
                      controller: _imageUrlController,
                      label: 'Resim URL (Google Drive)',
                      icon: Icons.image,
                    ),
                    SizedBox(height: 30),
                    // Kaydet Butonu
                    ElevatedButton.icon(
                      onPressed: _submitBook,
                      icon: Icon(Icons.save),
                      label: Text('Kaydet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Bu alan boş olamaz';
        }
        return null;
      },
    );
  }
}
