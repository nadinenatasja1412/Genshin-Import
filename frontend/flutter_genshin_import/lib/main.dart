import 'package:flutter/material.dart';
import 'package:flutter_genshin_import/models/itemsModel.dart';
import 'package:flutter_genshin_import/services/apiServices.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Biar label debug ilang
      title: 'Genshin Import',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Teyvat Digital Shop'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 1. Deklarasikan variabel Future untuk menampung data
  late Future<List<Item>> _itemsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // 2. Panggil API sekali saja saat widget pertama kali muncul
    _itemsFuture = _apiService.getAllItems();
  }

  // Fungsi buat refresh data kalau ada perubahan
  void _refreshData() {
    setState(() {
      _itemsFuture = _apiService.getAllItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData, // Tombol refresh manual
          ),
        ],
      ),
      body: FutureBuilder<List<Item>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          // Kondisi: Lagi Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Kondisi: Ada Error (XAMPP mati atau IP salah)
          else if (snapshot.hasError) {
            return Center(
              child: Text("Gagal konek ke Celestia: ${snapshot.error}"),
            );
          }
          // Kondisi: Data Berhasil Masuk
          else if (snapshot.hasData) {
            final items = snapshot.data!;

            if (items.isEmpty) {
              return const Center(child: Text("Stok barang lagi kosong!"));
            }

            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      child: const Icon(Icons.shopping_bag),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${item.category} | ${item.price} Mora"),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Nanti di sini panggil ApiService().buyItem
                        print("Beli ${item.name}");
                      },
                      child: const Text("Beli"),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text("Tidak ada data."));
        },
      ),
    );
  }
}
