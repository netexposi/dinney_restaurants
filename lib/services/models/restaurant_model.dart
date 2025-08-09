class Restaurant {
  final int? id;
  final String name;
  final String email;
  final double lat = 0.0;
  final double lng = 0.0;
  final List<String> tags = [];
  final List<String> urls;
  final List<dynamic> rating = [];
  final String opening = "09:30:00";
  final String closing = "23:15:00";

  Restaurant({
    this.id,
    required this.name,
    required this.email,
    required this.urls
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      email: json['email'], 
      urls: ['urls'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'name': name,
      'email': email,
      'lat': lat,
      'lng': lng,
      'tags': tags,
      'urls': urls,
      'rating': rating,
      'opening': opening,
      'closing': closing,
    };
    if (id != null) {
      data['id'] = id!;
    }
    return data;
  }
}
