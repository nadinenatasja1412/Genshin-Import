import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/itemsModel.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000/api";

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
