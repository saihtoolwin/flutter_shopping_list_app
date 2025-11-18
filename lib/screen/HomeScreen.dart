import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';

class Homescreen extends StatelessWidget {
  Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Groceries")),
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (context, index) {
          final item = groceryItems[index];
          return ListTile(
            title: Text(item.name),
            leading: Container(
              width: 16,
              height: 16,
              color: item.category.color,
            ),
            trailing: Text(
              item.quantity.toString(),
              style: TextStyle(fontSize: 18),
            ),
          );
        },
      ),
    );
  }
}
