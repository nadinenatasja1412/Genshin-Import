class Weapon {
  final int id;
  final String name;
  final String type;
  final String description;
  final int stock;
  final String? imageUrl;
  final double price;

  const Weapon({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.stock,
    this.imageUrl,
    required this.price,
  });

  factory Weapon.fromJson(Map<String, dynamic> json) {
    return Weapon(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      stock: json['stock'] as int,
      imageUrl: json['image_url'] as String?,
      price: double.parse(json['price'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'description': description,
    'stock': stock,
    'image_url': imageUrl,
    'price': price,
  };

  Weapon copyWith({
    int? id,
    String? name,
    String? type,
    String? description,
    int? stock,
    String? imageUrl,
    double? price,
  }) => Weapon(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    description: description ?? this.description,
    stock: stock ?? this.stock,
    imageUrl: imageUrl ?? this.imageUrl,
    price: price ?? this.price,
  );
}

// lib/models/order.dart
class Order {
  final int id;
  final int userId;
  final int weaponId;
  final String weaponName;
  final String weaponType;
  final String? weaponImageUrl;
  final int quantity;
  final double totalPrice;
  final String status;
  final DateTime orderedAt;

  const Order({
    required this.id,
    required this.userId,
    required this.weaponId,
    required this.weaponName,
    required this.weaponType,
    this.weaponImageUrl,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.orderedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      weaponId: json['weapon_id'] as int,
      weaponName: json['weapon_name'] as String? ?? '',
      weaponType: json['weapon_type'] as String? ?? '',
      weaponImageUrl: json['image_url'] as String?,
      quantity: json['quantity'] as int,
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'] as String,
      orderedAt: DateTime.parse(json['ordered_at'] as String),
    );
  }
}

// lib/models/user.dart
class AppUser {
  final int id;
  final String name;
  final String email;
  final String role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  bool get isAdmin => role == 'admin';
}
