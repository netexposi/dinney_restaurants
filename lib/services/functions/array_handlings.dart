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
String getDayAbbreviation(DateTime date, int lang) {
  const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const fr = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  const ar = ['إث', 'ثل', 'أر', 'خم', 'جم', 'سب', 'أح'];

  final index = date.weekday - 1; // weekday: 1 = Mon, 7 = Sun

  switch (lang) {
    case 1:
      return ar[index];
    case 2:
      return fr[index];
    default:
      return en[index];
  }
}