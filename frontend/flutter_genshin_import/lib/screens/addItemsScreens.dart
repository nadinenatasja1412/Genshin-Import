import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/apiServices.dart';

class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  File? _selectedImage;
  final _nameController = TextEditingController();
  final _picker = ImagePicker();

  // Fungsi untuk ambil gambar dari galeri
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _submitData() async {
    if (_selectedImage == null) return;

    bool success = await ApiService().uploadItem(
      name: _nameController.text,
      category: "weapon", // Contoh hardcode
      price: "1500",
      stock: "10",
      imageFile: _selectedImage!,
    );

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload Berhasil!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add New Weapon/Artifact")),
      body: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Item Name"),
          ),
          SizedBox(height: 20),
          _selectedImage != null
              ? Image.file(_selectedImage!, height: 200) // Preview gambar
              : Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Icon(Icons.image),
                ),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text("Pilih dari Galeri"),
          ),
          ElevatedButton(
            onPressed: _submitData,
            child: Text("Simpan ke Database"),
          ),
        ],
      ),
    );
  }
}
