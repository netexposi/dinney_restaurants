class Restaurant {
  final int? id;
  final String uid;
  final String name;
  final String email;
  final double lat = 0.0;
  final double lng = 0.0;
  final List<String> tags = [];
  final List<String> urls;
  final List<dynamic> rating = [];
  final List<Map<String, double>> schedule = [];

  Restaurant({
    this.id,
    required this.uid,
    required this.name,
    required this.email,
    required this.urls
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      uid: json['uid'],
      name: json['name'],
      email: json['email'], 
      urls: ['urls'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'uid': uid,
      'name': name,
      'email': email,
      'lat': lat,
      'lng': lng,
      'tags': tags,
      'urls': urls,
      'rating': rating,
      'schedule': schedule
    };
    if (id != null) {
      data['id'] = id!;
    }
    return data;
  }
}
