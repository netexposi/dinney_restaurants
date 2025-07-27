class Client {
  final int? id;
  final String fullname;
  final String email;
  final List<String> favs;

  Client({
    this.id,
    required this.fullname,
    required this.email,
    required this.favs,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      fullname: json['fullname'],
      email: json['email'],
      favs: List<String>.from(json['favs'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'fullname': fullname,
      'email': email,
      'favs': favs,
    };
    if (id != null) {
      data['id'] = id!;
    }
    return data;
  }
}
