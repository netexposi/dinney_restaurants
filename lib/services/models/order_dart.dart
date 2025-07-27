class Order {
  final int? id;
  final int restaurantId;
  final int clientId;
  final String clientName;
  final String clientEmail;
  final bool atTable;
  final bool suggested;
  final List<Map<String, double>> items;
  final DateTime? createdAt;
  final DateTime? deliveryAt;
  final bool validated;

  Order({
    this.id,
    required this.restaurantId,
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.atTable,
    required this.suggested,
    required this.items,
    this.createdAt,
    this.deliveryAt,
    required this.validated,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      restaurantId: json['restaurantId'],
      clientId:  json['clientId'],
      clientName: json['clientName'],
      clientEmail: json['clientEmail'],
      atTable: json['atTable'],
      suggested: json['suggested'],
      items: (json['items'] as List)
          .map((item) => Map<String, double>.from(item))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      deliveryAt: json['deliveryAt'] != null
          ? DateTime.parse(json['deliveryAt'])
          : null,
      validated: json['validated'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'restaurantId': restaurantId,
      'clientId': clientId,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'atTable': atTable,
      'suggested': suggested,
      'items': items,
      'validated': validated,
    };

    if (createdAt != null) {
      data['createdAt'] = createdAt!.toIso8601String();
    }
    if (deliveryAt != null) {
      data['deliveryAt'] = deliveryAt!.toIso8601String();
    }
    if (id != null) {
      data['id'] = id!;
    }

    return data;
  }
}
