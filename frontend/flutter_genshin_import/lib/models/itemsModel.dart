class Item {
  final String id;
  final String name;
  final String category;
  final String? itemType;
  final String? description;
  final int stock;
  final String? imageUrl;
  final double price;

  Item({
    required this.id,
    required this.name,
    required this.category,
    this.itemType,
    this.description,
    required this.stock,
    this.imageUrl,
    required this.price,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'].toString(),
      name: json['name'],
      category: json['category'],
      itemType: json['item_type'],
      description: json['description'],
      stock: json['stock'] ?? 0,
      imageUrl: json['image_url'],
      price: double.parse(json['price'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'item_type': itemType,
      'description': description,
      'stock': stock,
      'image_url': imageUrl,
      'price': price,
    };
  }
}
