import 'package:flutter/material.dart';
import '../models/cuisine.dart';
import '../models/dish.dart';
import '../models/cart_item.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/translations.dart';
import 'cuisine_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Cuisine>> futureCuisines;
  List<CartItem> cart = [];
  List<CartItem> previousOrders = [];
  bool isEnglish = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    futureCuisines = ApiService().fetchCuisines();
    // Add initial hardcoded previous orders
    previousOrders.add(CartItem(
      dish: Dish(id: "1", name: "Butter Chicken", imageUrl: "https://uat-static.onebanc.ai/picture/ob_dish_butter_chicken.webp", price: 199.0, rating: 4.5),
      cuisineId: "1",
      quantity: 2,
    ));
    previousOrders.add(CartItem(
      dish: Dish(id: "2", name: "Sweet and Sour Chicken", imageUrl: "https://uat-static.onebanc.ai/picture/ob_dish_sweet_and_sour_chicken.webp", price: 250.0, rating: 4.0),
      cuisineId: "1",
      quantity: 1,
    ));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen(cart: cart, fromScreen: 'home'))).then((result) {
          setState(() {
            _selectedIndex = 0; // Reset to Home tab
            if (result != null) {
              // Add the ordered items to previous orders
              previousOrders.addAll(result as List<CartItem>);
              cart.clear(); // Clear the cart after placing the order
            }
          });
        });
      }
    });
  }

  int _getDishCount(Dish dish) {
    return cart.where((item) => item.dish.id == dish.id).fold(0, (sum, item) => sum + item.quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.get("app_title", isEnglish), style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => isEnglish = value == "English");
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: "English", child: Text("English")),
              PopupMenuItem(value: "Hindi", child: Text("Hindi")),
            ],
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16.0),
            SizedBox(
              height: 200,
              child: FutureBuilder<List<Cuisine>>(
                future: futureCuisines,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final cuisines = snapshot.data!;
                    return PageView.builder(
                      controller: PageController(viewportFraction: 0.8),
                      itemCount: cuisines.length * 1000,
                      itemBuilder: (context, index) {
                        final cuisine = cuisines[index % cuisines.length];
                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => CuisineScreen(cuisine: cuisine, cart: cart, allCuisines: cuisines)),
                            );
                            if (result != null) {
                              setState(() {
                                cart = result;
                              });
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              color: const Color.fromARGB(221, 255, 255, 255),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.network(
                                      cuisine.cuisineImageUrl,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        height: 150,
                                        color: Colors.grey,
                                        child: Center(child: Text("Image Not Available", style: TextStyle(color: Colors.white))),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                    child: Text(
                                      cuisine.cuisineName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(Translations.get("top_dishes", isEnglish), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            SizedBox(
              height: 180,
              child: FutureBuilder<List<Cuisine>>(
                future: futureCuisines,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final allDishes = snapshot.data!
                        .expand((cuisine) => cuisine.items)
                        .where((dish) => dish.rating > 0)
                        .toList()
                      ..sort((a, b) => b.rating.compareTo(a.rating));
                    final topDishes = allDishes.take(3).toList();
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: topDishes.length,
                      itemBuilder: (context, index) {
                        final dish = topDishes[index];
                        final dishCount = _getDishCount(dish);
                        return Container(
                          width: 140,
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                  child: Image.network(
                                    dish.imageUrl,
                                    height: 80,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 80,
                                      color: Colors.grey,
                                      child: Center(child: Text("No Image", style: TextStyle(color: Colors.white))),
                                    ),
                                  ),
                                ),
                                Text(dish.name, style: TextStyle(fontSize: 14, color: Colors.black87)),
                                Text("₹${dish.price.toStringAsFixed(2)} | ${dish.rating}★", style: TextStyle(fontSize: 12, color: Colors.black54)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () => setState(() {
                                        final existingItem = cart.firstWhere(
                                          (item) => item.dish.id == dish.id,
                                          orElse: () => CartItem(dish: dish, cuisineId: snapshot.data!.firstWhere((c) => c.items.contains(dish)).cuisineId),
                                        );
                                        if (cart.contains(existingItem)) {
                                          if (existingItem.quantity > 1) {
                                            existingItem.quantity--;
                                          } else {
                                            cart.remove(existingItem);
                                          }
                                        }
                                      }),
                                      child: ScaleTransition(
                                        scale: Tween<double>(begin: 1.0, end: 0.9).animate(
                                          CurvedAnimation(
                                            parent: ModalRoute.of(context)!.animation!,
                                            curve: Curves.easeInOut,
                                          ),
                                        ),
                                        child: Icon(Icons.remove, color: Colors.red),
                                      ),
                                    ),
                                    Text(dishCount.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    GestureDetector(
                                      onTap: () => setState(() {
                                        final existingItem = cart.firstWhere(
                                          (item) => item.dish.id == dish.id,
                                          orElse: () => CartItem(dish: dish, cuisineId: snapshot.data!.firstWhere((c) => c.items.contains(dish)).cuisineId),
                                        );
                                        if (cart.contains(existingItem)) {
                                          existingItem.quantity++;
                                        } else {
                                          cart.add(CartItem(dish: dish, cuisineId: snapshot.data!.firstWhere((c) => c.items.contains(dish)).cuisineId, quantity: 1));
                                        }
                                      }),
                                      child: ScaleTransition(
                                        scale: Tween<double>(begin: 1.0, end: 0.9).animate(
                                          CurvedAnimation(
                                            parent: ModalRoute.of(context)!.animation!,
                                            curve: Curves.easeInOut,
                                          ),
                                        ),
                                        child: Icon(Icons.add, color: accentColor),
                                      ),
                                    ),
                                  ],
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
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(Translations.get("previous_orders", isEnglish), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            // Dynamically display previous orders
            ...previousOrders.map((order) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                    child: ListTile(
                      leading: Image.network(
                        order.dish.imageUrl,
                        width: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 50,
                          color: Colors.grey,
                          child: Center(child: Text("No Image", style: TextStyle(color: Colors.white))),
                        ),
                      ),
                      title: Text(order.dish.name, style: TextStyle(color: Colors.black87)),
                      subtitle: Text("₹${order.dish.price.toStringAsFixed(2)} x ${order.quantity}", style: TextStyle(color: Colors.black54)),
                      trailing: Text("₹${(order.dish.price * order.quantity).toStringAsFixed(2)}", style: TextStyle(color: Colors.black87)),
                    ),
                  ),
                )),
            SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                if (cart.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        cart.length.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: Translations.get("cart", isEnglish),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}