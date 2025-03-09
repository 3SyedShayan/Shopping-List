import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  int _enteredQuantity = 1;
  String _enteredName = "";
  var _selectedCategory = categories[Categories.vegetables]!;
  bool isLoading = false;
  var _formKey = GlobalKey<FormState>();
  void _submitForm() async {
    print("Executed");
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      isLoading = true;
      final url = Uri.https(
          'shopcart-6ea1e-default-rtdb.asia-southeast1.firebasedatabase.app',
          'grocery_items.json');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': _enteredName,
          'quantity': _enteredQuantity,
          'category': _selectedCategory.name,
        }),
      );
      print("After Save");
      print(response.body);
      print(response.statusCode);

      if (!context.mounted) {
        return;
      }
      final Map<String, dynamic> resData = json.decode(response.body);

      Navigator.of(context).pop(
        GroceryItem(
          id: resData['name'],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Item"),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                onSaved: (value) {
                  _enteredName = value!;
                },
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return "Must be between 1 and 50 characters";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Item Name",
                ),
                maxLength: 50,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      onSaved: (value) {
                        _enteredQuantity;
                      },
                      initialValue: "1",
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Must be a number greater than 0";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Quantity",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      onSaved: (value) {
                        _selectedCategory = value!;
                      },
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: "Category",
                      ),
                      validator: (value) {
                        if (value == null) {
                          return "Please select a category";
                        }
                        return null;
                      },
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
                                Text(category.value.name),
                              ],
                            ),
                          )
                      ],
                      onChanged: (value) {},
                    ),
                  )
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: Text("Reset"),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
                    child: isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(),
                          )
                        : Text("Submit"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
