// Product Screen: Displays the list of products
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_member_link/myconfig.dart';
import 'new_product.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<dynamic> productList = [];
  String status = "Loading...";
  late double screenWidth, screenHeight;

  @override
  void initState() {
    super.initState();
    loadProductsData();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          IconButton(
            onPressed: () => loadProductsData(),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: productList.isEmpty
          ? Center(
              child: Text(
                status,
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            )
          : GridView.builder(
              itemCount: productList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.75),
              itemBuilder: (context, index) {
                final product = productList[index];
                return Card(
                  child: InkWell(
                    onTap: () => showProductDetailsDialog(index),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            product['name'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          Image.network(
                            "${MyConfig.servername}/memberlink/assets/products/${product['image']}",
                            height: screenHeight * 0.2,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset("assets/images/na.png"),
                          ),
                          const SizedBox(height: 10),
                          Text("Price: \$${product['price']}"),
                          Text("Qty: ${product['quantity']}"),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewProduct()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void loadProductsData() async {
    try {
      final response = await http.get(
          Uri.parse("${MyConfig.servername}/memberlink/api/load_products.php"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == "success") {
          setState(() {
            productList = data['data']['products'];
          });
        } else {
          setState(() {
            status = "No Products Available";
          });
        }
      } else {
        setState(() {
          status = "Error Loading Products";
        });
      }
    } catch (e) {
      setState(() {
        status = "Error: ${e.toString()}";
      });
    }
  }

  void showProductDetailsDialog(int index) {
    final product = productList[index];
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(product['name']),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.network(
                  "${MyConfig.servername}/memberlink/assets/products/${product['image']}",
                  height: screenHeight * 0.2,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset("assets/images/na.png"),
                ),
                const SizedBox(height: 10),
                Text(product['description']),
                Text("Price: \$${product['price']}"),
                Text("Quantity: ${product['quantity']}"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              )
            ],
          );
        });
  }
}
