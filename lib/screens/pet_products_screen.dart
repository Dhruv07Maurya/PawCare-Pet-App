import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pet_products_data.dart';
import 'cart_provider.dart';

class PetProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final products = PetProductsData.getProducts();
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pet Products'),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image from local assets
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.asset(
                        'assets/images/${products[index].imageUrl}',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.grey[400],
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Product Details
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          products[index].name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          products[index].description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              products[index].price,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.orange,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Add to cart using provider
                                cartProvider.addItem(products[index]);

                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("${products[index].name} added to cart!"),
                                    backgroundColor: Colors.orange,
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(seconds: 2),
                                    action: SnackBarAction(
                                      label: 'VIEW CART',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/cart');
                                      },
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                              child: Icon(Icons.add_shopping_cart, size: 20),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(8),
                                minimumSize: Size.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}