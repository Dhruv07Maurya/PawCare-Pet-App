import 'package:flutter/foundation.dart';
import 'pet_products_data.dart';

class CartProvider with ChangeNotifier {
  final List<PetProduct> _items = [];

  List<PetProduct> get items => [..._items];

  int get itemCount => _items.length;

  void addItem(PetProduct product) {
    _items.add(product);
    notifyListeners();
  }

  void removeItem(PetProduct product) {
    _items.remove(product);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalAmount {
    double total = 0;
    for (var product in _items) {
      // Remove ₹ symbol and commas, then parse to double
      String priceString = product.price.replaceAll('₹', '').replaceAll(',', '');
      total += double.parse(priceString);
    }
    return total;
  }
}