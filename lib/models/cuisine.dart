import 'dish.dart';

class Cuisine {
  final String cuisineId;
  final String cuisineName;
  final String cuisineImageUrl;
  final List<Dish> items;

  Cuisine({
    required this.cuisineId,
    required this.cuisineName,
    required this.cuisineImageUrl,
    required this.items,
  });

  factory Cuisine.fromJson(Map<String, dynamic> json) {
    return Cuisine(
      cuisineId: json['cuisine_id']?.toString() ?? '',
      cuisineName: json['cuisine_name']?.toString() ?? 'Unknown Cuisine',
      cuisineImageUrl: json['cuisine_image_url']?.toString() ?? 'https://via.placeholder.com/150?text=No+Image',
      items: (json['items'] as List? ?? []).map((item) => Dish.fromJson(item)).toList(),
    );
  }
}