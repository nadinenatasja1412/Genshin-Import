import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/itemsModel.dart';
import 'package:path/path.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000/api";

  Future<bool> uploadItem({
    required String name,
    required String category,
    required String price,
    required String stock,
    required File imageFile, // File fisik dari galeri
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse("$baseUrl/items"));

      // Menambahkan data teks
      request.fields['name'] = name;
      request.fields['category'] = category;
      request.fields['price'] = price;
      request.fields['stock'] = stock;

      // Menambahkan data file gambar
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();

      var multipartFile = http.MultipartFile(
        'image', // Harus sama dengan upload.single('image') di Backend Multer
        stream,
        length,
        filename: basename(imageFile.path),
      );

      request.files.add(multipartFile);

      // Kirim ke server
      var response = await request.send();

      return response.statusCode == 201;
    } catch (e) {
      print("Upload Error: $e");
      return false;
    }
  }

  Future<List<Item>> getAllItems() async {
    final response = await http.get(Uri.parse("$baseUrl/items"));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception("Gagal mengambil data dari Teyvat");
    }
  }

  Future<bool> buyItem(String userId, String itemId, int quantity) async {
    final response = await http.post(
      Uri.parse("$baseUrl/transactions/buy"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "item_id": itemId,
        "quantity": quantity,
      }),
    );
    return response.statusCode == 201;
  }

  // 3. Hapus Item (Admin)
  Future<bool> deleteItem(String id) async {
    final response = await http.delete(Uri.parse("$baseUrl/items/$id"));
    return response.statusCode == 200;
  }
}
