class MenuModel {
  final int? id;
  final int restaurantId;
  final List<Map<String, dynamic>> menu;

  MenuModel({this.id, required this.restaurantId, required this.menu});

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'],
      restaurantId: json['restaurantId'],
      menu: List<Map<String, dynamic>>.from(json['menu'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'restaurantId': restaurantId,
      'menu': menu,
    };
    if (id != null) {
      data['id'] = id!;
    }
    return data;
  }
}