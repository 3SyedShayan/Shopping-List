import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

List<GroceryItem> _groceryItems = [];

class _GroceryListState extends State<GroceryList> {
  void _onNewItem() async {
    var newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => NewItem(),
      ),
    );
    if (newItem == null) return;
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text(
        "No Items to Display \n Please Add an Item",
      ),
    );

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          key: Key(_groceryItems[index].id),
          onDismissed: (direction) {
            setState(() {
              _groceryItems.remove(_groceryItems[index]);
            });
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
        body: content);
  }
}
