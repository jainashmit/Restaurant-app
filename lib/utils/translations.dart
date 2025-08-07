class Translations {
  static Map<String, Map<String, String>> data = {
    "en": {
      "app_title": "Restaurant App",
      "cart": "Cart",
      "place_order": "Place Order",
      "top_dishes": "Top Dishes",
      "previous_orders": "Previous Orders",
      "no_dishes_found": "No dishes found for this cuisine",
      "cart_empty": "Cart is empty",
      "net_total": "Net Total",
      "cgst": "CGST (2.5%)",
      "sgst": "SGST (2.5%)",
      "grand_total": "Grand Total",
      "order_placed": "Order Placed! Txn Ref: ",
      "payment_failed": "Payment Failed: ",
      "order_details": "Order Details",
      "processing_payment": "Processing Payment...",
    },
    "hi": {
      "app_title": "रेस्तरां ऐप",
      "cart": "कार्ट",
      "place_order": "ऑर्डर दें",
      "top_dishes": "शीर्ष व्यंजन",
      "previous_orders": "पिछले ऑर्डर",
      "no_dishes_found": "इस व्यंजन के लिए कोई डिश नहीं मिली",
      "cart_empty": "कार्ट खाली है",
      "net_total": "कुल राशि",
      "cgst": "सीजीएसटी (2.5%)",
      "sgst": "एसजीएसटी (2.5%)",
      "grand_total": "कुल योग",
      "order_placed": "ऑर्डर सफल! लेनदेन संदर्भ: ",
      "payment_failed": "भुगतान विफल: ",
      "order_details": "ऑर्डर विवरण",
      "processing_payment": "भुगतान प्रक्रिया में...",
    },
  };

  static String get(String key, bool isEnglish) => data[isEnglish ? "en" : "hi"]![key]!;
}