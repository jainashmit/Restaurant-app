import 'dish.dart';

class CartItem {
  final Dish dish;
  final String cuisineId;
  int quantity;

  CartItem({required this.dish, required this.cuisineId, this.quantity = 1});
}