// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shopping_list/data/categories.dart';

// import 'package:shopping_list/models/grocery_item.dart';
// import 'package:shopping_list/widgets/new_item.dart';

// class GroceryList extends StatefulWidget {
//   const GroceryList({super.key});

//   @override
//   State<GroceryList> createState() => _GroceryListState();
// }

// class _GroceryListState extends State<GroceryList> {
//   List<GroceryItem> _groceryItems = [];
//   var _isLoading = true;
//   // String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _loadItems();
//   }

//   void _loadItems() async {
//     // final url =
//     //     'https://udemylearn-7cce0-default-rtdb.asia-southeast1.firebasedatabase.app/grocery_items.json';
//     // final response = await http.get(Uri.parse(url));

//     final url = Uri.https(
//         'udemylearn-7cce0-default-rtdb.asia-southeast1.firebasedatabase.app',
//         'grocery_items.json');
//     final response = await http.get(url);
//     print(response.statusCode);
//     print(response.body);
//     // if (response.statusCode >= 400) {
//     //   setState(() {
//     //     _error = 'Failed to fetch data. Please try again later.';
//     //   });
//     // }

//     final Map<String, dynamic> listData = json.decode(response.body);
//     final List<GroceryItem> loadedItems = [];
//     for (final item in listData.entries) {
//       final category = categories.entries
//           .firstWhere((catItem) => catItem.value.name == item.value['category'])
//           .value;
//       loadedItems.add(
//         GroceryItem(
//           id: item.key,
//           name: item.value['name'],
//           quantity: item.value['quantity'],
//           category: category,
//         ),
//       );
//     }
//     setState(() {
//       _groceryItems = loadedItems;
//       _isLoading = false;
//     });
//   }

//   void _addItem() async {
//     final newItem = await Navigator.of(context).push<GroceryItem>(
//       MaterialPageRoute(
//         builder: (ctx) => const NewItem(),
//       ),
//     );

//     if (newItem == null) {
//       return;
//     }

//     setState(() {
//       _groceryItems.add(newItem);
//     });
//   }

//   void _removeItem(GroceryItem item) {
//     setState(() {
//       _groceryItems.remove(item);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     Widget content = const Center(child: Text('No items added yet.'));

//     if (_isLoading) {
//       content = const Center(child: CircularProgressIndicator());
//     }

//     if (_groceryItems.isNotEmpty) {
//       content = ListView.builder(
//         itemCount: _groceryItems.length,
//         itemBuilder: (ctx, index) => Dismissible(
//           onDismissed: (direction) {
//             _removeItem(_groceryItems[index]);
//           },
//           key: ValueKey(_groceryItems[index].id),
//           child: ListTile(
//             title: Text(_groceryItems[index].name),
//             leading: Container(
//               width: 24,
//               height: 24,
//               color: _groceryItems[index].category.color,
//             ),
//             trailing: Text(
//               _groceryItems[index].quantity.toString(),
//             ),
//           ),
//         ),
//       );
//     }

//     // if (_error != null) {
//     //   content = Center(child: Text(_error!));
//     // }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Groceries'),
//         actions: [
//           IconButton(
//             onPressed: _addItem,
//             icon: const Icon(Icons.add),
//           ),
//         ],
//       ),
//       body: content,
//     );
//   }
// }

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
  List<GroceryItem> _groceryItems = [];
  var isLoading = true;
  String? _error;
  void _loadItems() async {
    // final url = Uri.https(
    //     'udemylearn-7cce0-default-rtdb.asia-southeast1.firebasedatabase.app',
    //     'grocery_items.json');
    final url = Uri.https(
        'udemylearn-7cce0-default-rtdb.asia-southeast1.firebasedatabase.app',
        'grocery_items.json');
    final response = await http.get(url);
    print(response.statusCode);
    print(response.body);

    if (response.statusCode >= 400) {
      setState(() {
        _error = 'An error occurred!';
      });
    }

    if (response.body == 'null') {
      setState(() {
        isLoading = false;
      });
      return;
    }
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

    setState(() {});
    _groceryItems = loadedItems;
    isLoading = false;
  }

  void _removeItem(GroceryItem item) async {
    var itemIndex = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https(
        'udemylearn-7cce0-default-rtdb.asia-southeast1.firebasedatabase.app',
        'grocery_items/${item.id}.json');
    final response = await http.delete(url);
    print(response.statusCode);
    print(response.body);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(itemIndex, item);
        _error = 'An error occurred!';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
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
    Widget content = Center(
      child: Text(
        "No Items to Display, \n Please Add an Item.",
      ),
    );
    if (isLoading) {
      content = Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          key: Key(_groceryItems[index].id),
          onDismissed: (direction) {
            _removeItem(
              _groceryItems[index],
            );
          },
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 25,
              height: 25,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }
    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
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
      body: content,
    );
  }
}
