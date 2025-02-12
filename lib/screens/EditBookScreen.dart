import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;

  EditBookScreen({required this.book});

  @override
  _EditBookScreenState createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _pageCountController;
  late TextEditingController _publishYearController;
  late TextEditingController _categoryController;
  late TextEditingController _imageUrlController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _pageCountController =
        TextEditingController(text: widget.book.pageCount.toString());
    _publishYearController =
        TextEditingController(text: widget.book.publishYear.toString());
    _categoryController = TextEditingController(text: widget.book.category);
    _imageUrlController = TextEditingController(text: widget.book.imagePath);
  }

  Future<void> _updateBook() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('books').doc(widget.book.id).update({
          'title': _titleController.text.trim(),
          'author': _authorController.text.trim(),
          'pageCount': int.parse(_pageCountController.text.trim()),
          'publishYear': int.parse(_publishYearController.text.trim()),
          'category': _categoryController.text.trim(),
          'imageUrl': _imageUrlController.text.trim(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kitap başarıyla güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Güncelleme sonrası listeyi yenile
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kitap güncellenirken hata oluştu: $e'),
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
        title: Text('Kitap Düzenle'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kitap Bilgilerini Düzenleyin',
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
                    label: 'Resim URL',
                    icon: Icons.image,
                  ),
                  SizedBox(height: 30),
                  // Kaydet Butonu
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _updateBook,
                      icon: Icon(Icons.save),
                      label: Text('Güncelle'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
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
                  ),
                ],
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
