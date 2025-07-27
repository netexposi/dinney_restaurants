class MonoPriceCategory {
  final int? id;
  final String name;
  final int restaurantId;
  final List<Map<String, double>> items;

  MonoPriceCategory({
    this.id,
    required this.name,
    required this.restaurantId,
    required this.items,
  });

  factory MonoPriceCategory.fromJson(Map<String, dynamic> json) {
    return MonoPriceCategory(
      id: json['id'],
      name: json['name'],
      restaurantId: json['restaurantId'],
      items: (json['items'] as List)
          .map((item) => Map<String, double>.from(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'name': name,
      'restaurantId': restaurantId,
      'items': items,
    };
    if (id != null) {
      data['id'] = id!;
    }
    return data;
  }
}
