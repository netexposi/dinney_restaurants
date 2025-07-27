class MultiPriceCategory {
  final int? id;
  final String name;
  final int restaurantId;
  final List<Map<String, List<double>>> items;

  MultiPriceCategory({
    this.id,
    required this.name,
    required this.restaurantId,
    required this.items,
  });

  factory MultiPriceCategory.fromJson(Map<String, dynamic> json) {
    return MultiPriceCategory(
      id: json['id'],
      name: json['name'],
      restaurantId: json['restaurantId'],
      items: (json['items'] as List)
          .map((item) => (item as Map<String, dynamic>).map(
                (key, value) => MapEntry(
                  key,
                  List<double>.from(value),
                ),
              ))
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
