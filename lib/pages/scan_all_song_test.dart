// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';

class ScanAllSongPage extends StatefulWidget {
  const ScanAllSongPage({Key? key}) : super(key: key);

  @override
  State<ScanAllSongPage> createState() => _ScanAllSongPageState();
}

class _ScanAllSongPageState extends State<ScanAllSongPage> {
  List<String> paths = [];
  var songPaths = [];
  // String dirPath = '/storage/';
  // String dirPath = '/storage/emulated/0/';
  String dirPath = '/storage/453E-10F7/';

  void scanpaths() async {
    paths = Directory(dirPath)
        .listSync()
        .map((e) => e.path)
        .where((item) => !item.contains('.'))
        .toList();
    for (int i = 0; i < paths.length; i++) {
      if (paths[i].split('/').last.contains('.') ||
          paths[i].split('/').last.contains('Android')) {
        paths.removeAt(i);
      }
    }
    setState(() {});
    print(paths);
    scanSongs();
  }

  void scanSongs() async {
    songPaths.clear();
    for (int i = 0; i < paths.length; i++) {
      String path = "${paths[i]}/";
      songPaths.addAll(Directory(path)
          .listSync(recursive: true)
          .map((e) => e.path)
          .where((item) => item.endsWith('.mp3'))
          .toList());
    }
    songPaths.sort();
    setState(() {});
    print("object: ${songPaths.length} ${songPaths}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan all musics"),
      ),
      body: songPaths.isNotEmpty
          ? ListView.builder(
              itemCount: songPaths.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(songPaths[index].split('/').last),
                );
              },
            )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          scanpaths();
        },
      ),
    );
  }
}
