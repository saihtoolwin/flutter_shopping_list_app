import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
// import 'package:shopping_list/data/dummy_items.dart';
// import 'package:shopping_list/models/category.dart';
// import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadedItems();
  }

  void _loadedItems() async {
    final url = Uri.https(
      'shopping-list-flutter-ap-9b478-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = "Failed to fetch data.Please try again later";
        });
      }
      if (response.body == "null") {
        setState(() {
          _isLoading = false;
          return;
        });
      }
      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadItems = [];

      for (var item in listData.entries) {
        final category = categories.entries
            .firstWhere(
              (itemCate) => itemCate.value.title == item.value['category'],
            )
            .value;
        loadItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryItems = loadItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Something went wrong.Please try again later";
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => NewItem()));

    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
    // print("Loading done");
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
      'shopping-list-flutter-ap-9b478-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete the item. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(child: Text("No Items added yet."));

    if (_isLoading) {
      content = Center(child: CircularProgressIndicator());
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) {
          final item = _groceryItems[index];
          return Dismissible(
            onDismissed: (direction) {
              _removeItem(item);
            },
            key: ValueKey(item.id),
            child: ListTile(
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
            ),
          );
        },
      );
    }

    if (_error != null) {
      content = Center(child: Text(_error!));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Groceries"),
        actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
