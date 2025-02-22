import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Groceries"),
      ),
      body: Text("data"),
    );
  }
}
