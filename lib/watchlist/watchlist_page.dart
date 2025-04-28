import 'package:flutter/material.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({Key? key}) : super(key: key);

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Watchlist', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
    );
  }
}
