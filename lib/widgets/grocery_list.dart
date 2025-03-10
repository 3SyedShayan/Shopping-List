import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  late Future<List<GroceryItem>> loadedItems;
  List<GroceryItem> _groceryItems = [];
  var isLoading = true;
  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(
      'shopcart-6ea1e-default-rtdb.asia-southeast1.firebasedatabase.app',
      'grocery_items.json',
    );
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch grocery items, Please Try Again');
    }
    if (response.body == 'null') {
      return [];
    }
    // if (response.body == 'null') {
    //   setState(() {
    //     isLoading = false;
    //   });
    //   return;
    // }
    final Map<String, dynamic> extractedData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final data in extractedData.entries) {
      final category = categories.entries
          .firstWhere((e) => e.value.name == data.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
          id: data.key,
          name: data.value['name'],
          quantity: data.value['quantity'],
          category: category,
        ),
      );
    }
    print(loadedItems.length);
    return loadedItems;

    // if (response.statusCode >= 400) {
    //   setState(() {
    //     _error = 'An error occurred!';
    //   });
    // }
  }

  void _removeItem(GroceryItem item) async {
    var itemIndex = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https(
        'shopcart-6ea1e-default-rtdb.asia-southeast1.firebasedatabase.app',
        'grocery_items/${item.id}.json');
    final response = await http.delete(url);
    print(response.statusCode);
    print(response.body);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(itemIndex, item);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadedItems = _loadItems();
  }

  void _onNewItem() async {
    var newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => NewItem(),
      ),
    );
    _groceryItems.add(newItem!);
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    // if (_error != null) {
    //   content = Center(
    //     child: Text(_error!),
    //   );
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Groceries"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _onNewItem,
          ),
        ],
      ),
      body: RefreshIndicator(
        child: FutureBuilder(
            future: _loadItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }

              if (snapshot.data!.isEmpty) {
                return Center(
                  child: Text("No Items Added"),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => Dismissible(
                  key: ValueKey(snapshot.data![index].id),
                  onDismissed: (direction) {
                    _removeItem(
                      snapshot.data![index],
                    );
                  },
                  child: ListTile(
                    title: Text(snapshot.data![index].name),
                    leading: Container(
                      width: 25,
                      height: 25,
                      color: snapshot.data![index].category.color,
                    ),
                    trailing: Text(
                      snapshot.data![index].quantity.toString(),
                    ),
                  ),
                ),
              );
            }),
        // content,
        onRefresh: () async {
          await Future.delayed(
            Duration(seconds: 5),
          );
          _loadItems();
        },
      ),
    );
  }
}
