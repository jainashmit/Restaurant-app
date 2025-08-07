class Dish {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double rating;

  Dish({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    print("Parsing dish JSON: $json"); // Debug log
    return Dish(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Dish',
      imageUrl: json['image_url']?.toString() ?? 'https://via.placeholder.com/80?text=No+Image',
      price: _parseDouble(json['price']),
      rating: _parseDouble(json['rating']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) {
      print("Warning: Price or rating is null, defaulting to 100.0");
      return 100.0;
    }
    if (value is String) {
      double? parsed = double.tryParse(value);
      if (parsed == null || parsed == 0.0) {
        print("Warning: Price parsing failed or is 0, defaulting to 100.0");
        return 100.0;
      }
      return parsed;
    }
    if (value is num) {
      double result = value.toDouble();
      if (result == 0.0) {
        print("Warning: Price is 0, defaulting to 100.0");
        return 100.0;
      }
      return result;
    }
    print("Warning: Price type unknown, defaulting to 100.0");
    return 100.0;
  }
}