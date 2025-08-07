import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cuisine.dart';
import '../models/dish.dart';

class ApiService {
  static const String baseUrl = "https://uat.onebanc.ai";
  static const String apiKey = "uonebancservceemultrS3cg8RaL30";

  Future<List<Cuisine>> fetchCuisines() async {
    final response = await http.post(
      Uri.parse('$baseUrl/emulator/interview/get_item_list'),
      headers: {
        "X-Partner-API-Key": apiKey,
        "X-Forward-Proxy-Action": "get_item_list",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"page": 1, "count": 10}),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      print("fetchCuisines response: $jsonData"); // Debug log
      return (jsonData['cuisines'] as List).map((json) => Cuisine.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load cuisines");
    }
  }

  Future<List<Cuisine>> fetchDishesByCuisine(String cuisineName, List<Cuisine> allCuisines) async {
    final response = await http.post(
      Uri.parse('$baseUrl/emulator/interview/get_item_by_filter'),
      headers: {
        "X-Partner-API-Key": apiKey,
        "X-Forward-Proxy-Action": "get_item_by_filter",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "cuisine_type": [cuisineName],
      }),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      print("fetchDishesByCuisine response for $cuisineName: $jsonData"); // Debug log
      List<Cuisine> cuisines = (jsonData['cuisines'] as List).map((json) => Cuisine.fromJson(json)).toList();
      // Check if prices are 0 or missing, fallback to allCuisines
      for (var cuisine in cuisines) {
        List<Dish> updatedItems = [];
        for (var dish in cuisine.items) {
          if (dish.price == 0.0 || dish.price == 100.0) {
            // Find matching dish in allCuisines
            Dish updatedDish = dish; // Default to the original dish
            for (var fallbackCuisine in allCuisines) {
              var matchingDish = fallbackCuisine.items.firstWhere(
                (d) => d.id == dish.id,
                orElse: () => dish,
              );
              if (matchingDish.price != 0.0 && matchingDish.price != 100.0) {
                // Create a new Dish with the updated price
                updatedDish = Dish(
                  id: dish.id,
                  name: dish.name,
                  imageUrl: dish.imageUrl,
                  price: matchingDish.price,
                  rating: dish.rating,
                );
                break; // Exit loop once we find a valid price
              }
            }
            updatedItems.add(updatedDish);
          } else {
            updatedItems.add(dish);
          }
        }
        cuisine.items.clear();
        cuisine.items.addAll(updatedItems);
      }
      return cuisines;
    } else {
      throw Exception("Failed to load dishes");
    }
  }

  Future<String> makePayment(double totalAmount, List<Map<String, dynamic>> items) async {
    final response = await http.post(
      Uri.parse('$baseUrl/emulator/interview/make_payment'),
      headers: {
        "X-Partner-API-Key": apiKey,
        "X-Forward-Proxy-Action": "make_payment",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "total_amount": totalAmount.toString(),
        "total_items": items.length,
        "data": items,
      }),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = jsonDecode(response.body);
      print("makePayment response: $jsonData"); // Debug log
      return jsonData['txn_ref_no'];
    } else {
      throw Exception("Payment failed");
    }
  }
}