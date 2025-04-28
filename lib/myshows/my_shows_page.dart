import 'package:flutter/material.dart';

class MyShowsPage extends StatefulWidget {
  const MyShowsPage({Key? key}) : super(key: key);

  @override
  State<MyShowsPage> createState() => _MyShowsPageState();
}

class _MyShowsPageState extends State<MyShowsPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('My Shows', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
    );
  }
}
