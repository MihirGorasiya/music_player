// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:music_player/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        canvasColor: Colors.grey[800],
      ),
      home: HomePage(),
    );
  }
}
