import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../utils/translations.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cart;
  final String fromScreen; // 'home' or 'cuisine'

  CartScreen({required this.cart, this.fromScreen = 'home'});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _showOrderPlacedCard = false;

  @override
  Widget build(BuildContext context) {
    if (widget.cart.isEmpty) {
      return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context); // Simply pop to return to previous screen
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(Translations.get("cart", true), style: TextStyle(color: Colors.white)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context); // Return to previous screen
              },
            ),
          ),
          body: Center(child: Text(Translations.get("cart_empty", true), style: TextStyle(color: Colors.black87))),
        ),
      );
    }

    double netTotal = widget.cart.fold(0, (sum, item) => sum + item.dish.price * item.quantity);
    double cgst = netTotal * 0.025;
    double sgst = netTotal * 0.025;
    double grandTotal = netTotal + cgst + sgst;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context); // Return to previous screen
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(Translations.get("cart", true), style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Return to previous screen
            },
          ),
        ),
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart[index];
                      return ListTile(
                        leading: Image.network(
                          item.dish.imageUrl,
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 50,
                            color: Colors.grey,
                            child: Center(child: Text("No Image", style: TextStyle(color: Colors.white))),
                          ),
                        ),
                        title: Text(item.dish.name, style: TextStyle(color: Colors.black87)),
                        subtitle: Text("₹${item.dish.price.toStringAsFixed(2)} x ${item.quantity}", style: TextStyle(color: Colors.black54)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (item.quantity > 1) {
                                    item.quantity--;
                                  } else {
                                    widget.cart.removeAt(index);
                                  }
                                });
                              },
                              child: Icon(Icons.remove, color: Colors.red, size: 20),
                            ),
                            SizedBox(width: 8),
                            Text(item.quantity.toString()),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  item.quantity++;
                                });
                              },
                              child: Icon(Icons.add, color: accentColor, size: 20),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  widget.cart.removeAt(index);
                                });
                              },
                              child: Icon(Icons.delete, color: Colors.red, size: 20),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  color: Colors.grey[200],
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(Translations.get("net_total", true), style: TextStyle(color: Colors.black87)), Text("₹${netTotal.toStringAsFixed(2)}", style: TextStyle(color: Colors.black87))]),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(Translations.get("cgst", true), style: TextStyle(color: Colors.black87)), Text("₹${cgst.toStringAsFixed(2)}", style: TextStyle(color: Colors.black87))]),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(Translations.get("sgst", true), style: TextStyle(color: Colors.black87)), Text("₹${sgst.toStringAsFixed(2)}", style: TextStyle(color: Colors.black87))]),
                      Divider(),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(Translations.get("grand_total", true), style: TextStyle(color: Colors.black87)), Text("₹${grandTotal.toStringAsFixed(2)}", style: TextStyle(color: Colors.black87))]),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showOrderPlacedCard = true;
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [const Color.fromARGB(255, 232, 84, 4), Colors.orangeAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          child: Text(
                            Translations.get("place_order", true),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Card-like pop-up overlay
            if (_showOrderPlacedCard)
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                top: _showOrderPlacedCard ? MediaQuery.of(context).size.height * 0.3 : MediaQuery.of(context).size.height,
                left: 20,
                right: 20,
                child: AnimatedOpacity(
                  opacity: _showOrderPlacedCard ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 60),
                          SizedBox(height: 16),
                          Text(
                            "Order Placed Successfully!",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Ordered by: Ashmit Jain",
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Total: ₹${grandTotal.toStringAsFixed(2)}",
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Pass the cart items back to HomeScreen and navigate
                              Navigator.pop(context, widget.cart);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 255, 92, 10),
                            //     gradient: LinearGradient(
                            //   colors: [const Color.fromARGB(255, 232, 84, 4), Colors.orangeAccent],
                            //   begin: Alignment.topLeft,
                            //   end: Alignment.bottomRight,
                            // ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text("OK", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 