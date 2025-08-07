import 'package:flutter/material.dart';
import '../models/cuisine.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/translations.dart';
import 'cart_screen.dart';

class CuisineScreen extends StatefulWidget {
  final Cuisine cuisine;
  final List<CartItem> cart;
  final List<Cuisine> allCuisines;

  CuisineScreen({required this.cuisine, required this.cart, required this.allCuisines});

  @override
  _CuisineScreenState createState() => _CuisineScreenState();
}

class _CuisineScreenState extends State<CuisineScreen> {
  late Future<List<Cuisine>> futureDishes;
  Map<String, int> dishQuantities = {};

  @override
  void initState() {
    super.initState();
    futureDishes = ApiService().fetchDishesByCuisine(widget.cuisine.cuisineName, widget.allCuisines);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cuisine.cuisineName, style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen(cart: widget.cart, fromScreen: 'cuisine'))).then((_) {
                // No need to reset anything here, handled by CartScreen
              });
            },
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: FutureBuilder<List<Cuisine>>(
        future: futureDishes,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final dishes = snapshot.data!.isNotEmpty ? snapshot.data!.first.items : [];
            if (dishes.isEmpty) {
              return Center(child: Text(Translations.get("no_dishes_found", true), style: TextStyle(color: Colors.black87)));
            }
            return ListView.builder(
              itemCount: dishes.length,
              itemBuilder: (context, index) {
                final dish = dishes[index];
                final dishKey = dish.id;
                dishQuantities[dishKey] ??= 0;
                return Card(
                  margin: EdgeInsets.all(8.0),
                  elevation: 2,
                  child: ListTile(
                    leading: Image.network(
                      dish.imageUrl,
                      width: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 50,
                        color: Colors.grey,
                        child: Center(child: Text("No Image", style: TextStyle(color: Colors.white))),
                      ),
                    ),
                    title: Text(dish.name, style: TextStyle(color: Colors.black87)),
                    subtitle: Text("₹${dish.price.toStringAsFixed(2)}", style: TextStyle(color: Colors.black54)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (dishQuantities[dishKey]! > 0)
                          GestureDetector(
                            onTap: () => setState(() {
                              if (dishQuantities[dishKey]! > 1) {
                                dishQuantities[dishKey] = dishQuantities[dishKey]! - 1;
                              } else {
                                dishQuantities[dishKey] = 0;
                              }
                              final existingItem = widget.cart.firstWhere(
                                (item) => item.dish.id == dish.id,
                                orElse: () => CartItem(dish: dish, cuisineId: widget.cuisine.cuisineId),
                              );
                              if (widget.cart.contains(existingItem)) {
                                if (dishQuantities[dishKey]! == 0) {
                                  widget.cart.remove(existingItem);
                                } else {
                                  existingItem.quantity = dishQuantities[dishKey]!;
                                }
                              }
                            }),
                            child: Icon(Icons.remove, color: Colors.red, size: 20),
                          ),
                        if (dishQuantities[dishKey]! > 0) SizedBox(width: 8),
                        if (dishQuantities[dishKey]! > 0) Text(dishQuantities[dishKey].toString()),
                        if (dishQuantities[dishKey]! > 0) SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              dishQuantities[dishKey] = dishQuantities[dishKey]! + 1;
                              final existingItem = widget.cart.firstWhere(
                                (item) => item.dish.id == dish.id,
                                orElse: () => CartItem(dish: dish, cuisineId: widget.cuisine.cuisineId),
                              );
                              if (widget.cart.contains(existingItem)) {
                                existingItem.quantity = dishQuantities[dishKey]!;
                              } else {
                                widget.cart.add(CartItem(dish: dish, cuisineId: widget.cuisine.cuisineId, quantity: dishQuantities[dishKey]!));
                              }
                            });
                          },
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 1.0, end: 0.9).animate(
                              CurvedAnimation(
                                parent: ModalRoute.of(context)!.animation!,
                                curve: Curves.easeInOut,
                              ),
                            ),
                            child: Icon(Icons.add, color: accentColor, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.red)));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}