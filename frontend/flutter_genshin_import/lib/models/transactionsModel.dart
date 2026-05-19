class TransactionHistory {
  final String id;
  final String itemName;
  final int quantity;
  final double totalPrice;
  final DateTime purchaseDate;

  TransactionHistory({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.totalPrice,
    required this.purchaseDate,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    return TransactionHistory(
      id: json['id'].toString(),
      itemName: json['item_name'] ?? "Unknown Item",
      quantity: json['quantity'],
      totalPrice: double.parse(json['total_price'].toString()),
      purchaseDate: DateTime.parse(json['purchase_date']),
    );
  }
}
