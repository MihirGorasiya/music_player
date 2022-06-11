// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music_player/database_utils/SongInfo.dart';
import 'package:music_player/database_utils/database_helper.dart';

class TempPage extends StatefulWidget {
  const TempPage({Key? key}) : super(key: key);

  @override
  State<TempPage> createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> {
  late int databaseLength = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(databaseLength.toString()),
      ),
      body: FutureBuilder<List<SongInfo>?>(
        future: DatabaseHelper.getAllNotes(),
        builder: (context, AsyncSnapshot<List<SongInfo>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading:
                      File(snapshot.data![index].imagePath).lengthSync() > 2000
                          ? Image.file(File(snapshot.data![index].imagePath))
                          : Image.asset('assets/dummyImage.png'),
                  // leading: Text("$index"),
                  title: Text(snapshot.data![index].songName),
                  subtitle: Text(snapshot.data![index].imagePath),
                  trailing: IconButton(
                      onPressed: () {
                        // DatabaseHelper.deleteData();
                        print("File length: ${snapshot.data![index].songPath}");
                        setState(() {
                          databaseLength = snapshot.data!.length;
                        });
                      },
                      icon: Icon(Icons.delete_forever_rounded)),
                );
              },
            );
          } else {
            return Text("Song List");
          }
        },
      ),
    );
  }
}


// Expanded(
              //   child: (musicPaths.isNotEmpty &&
              //           musicAlbumArts.length == musicPaths.length)
              //       ? ListView.builder(
              //           itemCount: musicPaths.length,
              //           itemBuilder: (context, index) {
              //             return ListTile(
              //               leading: musicAlbumArts[index] != null
              //                   ? Image.memory(
              //                       musicAlbumArts[index]!,
              //                       height: 50,
              //                       width: 50,
              //                     )
              //                   : Image.asset("assets/dummyImage.png"),
              //               // title: Text(paths[index].split('/').last),
              //               title: Text(musicTrackNames[index]),
              //               onTap: () {
              //                 currentMusicPath = musicPaths[index];
              //                 initAudioPlayer(currentMusicPath, true);
              //                 setState(() {});
              //               },
              //             );
              //           },
              //         )
              //       : Center(
              //           child: Column(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             CircularProgressIndicator(),
              //             SizedBox(
              //               height: 30,
              //             ),
              //             Text(
              //                 "importing File ${currentImportingIndex} out of ${musicPaths.length}."),
              //           ],
              //         )),
              // ),