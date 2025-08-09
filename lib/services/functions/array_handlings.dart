double calculateAverageRating(List<dynamic> ratingsJson) {
  if (ratingsJson.isEmpty) return 0.0;

  double total = 0.0;
  for (var entry in ratingsJson) {
    if (entry is Map && entry.containsKey('rating')) {
      total += (entry['rating'] as num).toDouble();
    }
  }

  return total / ratingsJson.length;
}