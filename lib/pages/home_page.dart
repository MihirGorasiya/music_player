// ignore_for_file: prefer_typing_uninitialized_variables, prefer_const_constructors

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/controller/controller.dart';
import 'package:music_player/pages/music_player_page.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Controller c = Get.put(Controller());
  // --------Path Manager--------
  var paths = [];
  // String dirPath = '/storage/emulated/0/';
  String dirPath = '/storage/453E-10F7/music/My Fab';
  String currentMusicPath = '';
  // bool isDrawerOpen = false;

  // --------Audio Manager--------
  AudioPlayer player = AudioPlayer();
  late Duration dur;
  bool isDurLoaded = false;

  // --------Matadata--------
  String trackName = 'Track Name';
  String artistName = 'Artist Name';
  late Uint8List albumArt;

  @override
  void initState() {
    getPaths();
    super.initState();
  }

  void getPaths() async {
    var dir = Directory(dirPath);
    paths = dir
        .listSync()
        .map((e) => e.path)
        .where((item) => item.endsWith(".mp3"))
        .toList();
    paths.sort();
    setState(() {});
  }

  void initAudioPlayer(String musicPath) async {
    player.stop();
    dur = (await player.setFilePath(musicPath))!;
    var metadata = await MetadataRetriever.fromFile(File(musicPath));
    trackName = metadata.trackName!;
    artistName = metadata.trackArtistNames!.join(',');
    albumArt = metadata.albumArt!;

    isDurLoaded = true;
    player.play();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // List<String> pathDevided = dirPath.split('/');
        // dirPath = '/';
        // for (int i = 1; i < pathDevided.length - 2; i++) {
        //   dirPath = "$dirPath${pathDevided[i]}/";
        // }
        // setState(() {
        //   getPaths();
        // });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("File Manager")),
        body: Stack(
          children: [
            paths.isNotEmpty
                ? ListView.builder(
                    itemCount: paths.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(paths[index].split('/').last),
                        onTap: () {
                          currentMusicPath = paths[index];
                          initAudioPlayer(currentMusicPath);

                          // dirPath = '$dirPath${paths[index].split('/').last}/';
                          setState(() {});
                        },
                      );
                    },
                  )
                : const CircularProgressIndicator(),
            Obx(
              () => c.isDrawerOpen.value
                  ? MusicPlayerPage(
                      audioPlayer: player,
                      albumArt: albumArt,
                      trackName: trackName,
                      artistName: artistName,
                    )
                  : Positioned(
                      bottom: 0,
                      child: InkWell(
                        onTap: () {
                          c.isDrawerOpen.value = !c.isDrawerOpen.value;
                        },
                        child: Container(
                          color: Colors.grey[300],
                          height: 75,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              isDurLoaded
                                  ? Image.memory(albumArt)
                                  : Image.asset("assets/dummyImage.png"),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      trackName,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      artistName,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                iconSize: 40,
                                onPressed: () {
                                  // isMusicPlaying = !isMusicPlaying;
                                  if (player.playing) {
                                    player.pause();
                                  } else {
                                    player.play();
                                  }
                                  setState(() {});
                                },
                                icon: Icon(player.playing
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


// player.currentIndex!.isNaN
//                                       ? Image.asset("assets/dummyImage.png")
//                                       : Image.memory(albumArt)

// if (isDrawerOpen)
            //   MusicPlayerPage(
            //     audioPlayer: player,
            //     albumArt: albumArt,
            //     trackName: trackName,
            //     artistName: artistName,
            //   )
            // else
            //   Positioned(
            //     bottom: 0,
            //     child: InkWell(
            //       onTap: () {
            //         isDrawerOpen = !isDrawerOpen;
            //         setState(() {});
            //       },
            //       child: Container(
            //         color: Colors.deepOrange,
            //         height: 75,
            //         width: MediaQuery.of(context).size.width,
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Image.asset("assets/dummyImage.png"),
            //             SizedBox(
            //               width: MediaQuery.of(context).size.width * 0.6,
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Text(trackName),
            //                   Text(artistName),
            //                 ],
            //               ),
            //             ),
            //             Container(
            //               color: Colors.blue,
            //               child: IconButton(
            //                 iconSize: 55,
            //                 onPressed: () {},
            //                 icon: Icon(
            //                   Icons.play_arrow_rounded,
            //                 ),
            //               ),
            //             )
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),