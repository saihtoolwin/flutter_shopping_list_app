import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
// import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _enterName = '';
  var _enterQuantity = 1;
  var _selectedCategory = categories[Categories.fruit]!;
  var _isSending=false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending=true;
      });
      final url = Uri.https(
        'shopping-list-flutter-ap-9b478-default-rtdb.firebaseio.com',
        'shopping-list.json',
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': "application/json"},
        body: json.encode({
          'name': _enterName,
          'quantity': _enterQuantity,
          'category': _selectedCategory.title,
        }),
      );
      final resData = json.decode(response.body);
      if (!context.mounted) {
        return;
      }
      // response.statusCode
      Navigator.of(context).pop(GroceryItem(id: resData['name'], name: _enterName, quantity: _enterQuantity, category: _selectedCategory));
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add new item")),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: InputDecoration(label: Text("Name")),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return "Must be between 1 and 50 characters.";
                  }
                  return null;
                },
                onSaved: (value) {
                  _enterName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(label: Text("Quantity")),
                      keyboardType: TextInputType.number,
                      initialValue: _enterQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Must be between 1 and 50 characters.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enterQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending ? null : () {
                      _formKey.currentState!.reset();
                    },
                    child: Text("Reset"),
                  ),
                  ElevatedButton(onPressed:_isSending ? null : _saveItem, child: _isSending ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(),
                  ): Text("Add Item")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
