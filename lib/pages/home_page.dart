// ignore_for_file: prefer_typing_uninitialized_variables, prefer_const_constructors

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/controller/controller.dart';
import 'package:music_player/pages/music_player_page.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:music_player/widgets/bottom_player_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Controller c = Get.put(Controller());
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  // --------Path Manager--------
  List<String> paths = [];
  List<Uint8List?> musicAlbumArts = [];
  List<String> musicTrackNames = [];
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
    requestPermission();
    getPaths();
    setLastSongToPlayer();
    super.initState();
  }

  void requestPermission() async {
    var status = await Permission.storage.status;
    var status2 = await Permission.manageExternalStorage.status;
    if (status.isDenied) {
      await Permission.storage.request();
    }
    if (status2.isDenied) {
      await Permission.manageExternalStorage.request();
    }
  }

  void getPaths() async {
    var dir = Directory(dirPath);
    paths = dir
        .listSync(recursive: true)
        .map((e) => e.path)
        .where((item) => item.endsWith(".mp3"))
        .toList();

    paths.sort();
    setState(() {});
    getAllTrackName();
    getAllAlbumArts();
  }

  void setLastSongToPlayer() async {
    final SharedPreferences prefs = await _prefs;
    initAudioPlayer(prefs.getString('lastSong')!, false);
  }

  void initAudioPlayer(String musicPath, bool playInitially) async {
    player.stop();
    dur = (await player.setFilePath(musicPath))!;
    var metadata = await MetadataRetriever.fromFile(File(musicPath));

    setCurrentMusicInfos(metadata, musicPath);

    final SharedPreferences prefs = await _prefs;
    prefs.setString('lastSong', musicPath);

    isDurLoaded = true;

    setControllerValues();

    playInitially ? player.play() : null;

    setState(() {});
  }

  void setControllerValues() {
    c.musicLengthInt.value = player.duration!.inSeconds;
    c.musicLength.value =
        "${(player.duration!.inSeconds / 60).truncate().toString().padLeft(2, '0')}:${(player.duration!.inSeconds).remainder(60).toString().padLeft(2, '0')}";

    Timer.periodic(Duration(seconds: 1), (Timer t) {
      c.musicPosition.value =
          "${(player.position.inSeconds / 60).truncate().toString().padLeft(2, '0')}:${(player.position.inSeconds).remainder(60).toString().padLeft(2, '0')}";

      c.sliderValue.value =
          player.position.inSeconds / player.duration!.inSeconds;
    });
  }

  void setCurrentMusicInfos(Metadata metadata, String musicPath) {
    if (metadata.trackName != null) {
      trackName = metadata.trackName!;
    } else {
      trackName = musicPath.split('/').last;
    }

    if (metadata.trackArtistNames != null) {
      artistName = metadata.trackArtistNames!.join(',');
    } else {
      artistName = "Unknown Artist";
    }

    if (metadata.albumArt != null) {
      albumArt = metadata.albumArt!;
    }
  }

  void getAllAlbumArts() async {
    for (int i = 0; i < paths.length; i++) {
      var metadata = await MetadataRetriever.fromFile(File(paths[i]));
      musicAlbumArts.add(metadata.albumArt);
    }
    setState(() {});
  }

  void getAllTrackName() async {
    for (int i = 0; i < paths.length; i++) {
      var metadata = await MetadataRetriever.fromFile(File(paths[i]));
      if (metadata.trackName != null) {
        musicTrackNames.add(metadata.trackName!);
      } else {
        musicTrackNames.add(paths[i].split('/').last.split('.').first);
      }
    }
    // musicTrackNames.sort();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Music Player")),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Expanded(
                child: (paths.isNotEmpty && musicAlbumArts.length > 25)
                    ? ListView.builder(
                        itemCount: paths.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: musicAlbumArts[index] != null
                                ? Image.memory(
                                    musicAlbumArts[index]!,
                                    height: 50,
                                    width: 50,
                                  )
                                : Image.asset("assets/dummyImage.png"),
                            // title: Text(paths[index].split('/').last),
                            title: Text(musicTrackNames[index]),
                            onTap: () {
                              currentMusicPath = paths[index];
                              initAudioPlayer(currentMusicPath, true);
                              setState(() {});
                            },
                          );
                        },
                      )
                    : Center(child: const CircularProgressIndicator()),
              ),
              SizedBox(
                height: 75,
              ),
            ],
          ),
          Obx(
            () => c.isDrawerOpen.value
                ? MusicPlayerPage(
                    audioPlayer: player,
                    albumArt: albumArt,
                    trackName: trackName,
                    artistName: artistName,
                  )
                : BottomPlayerWidget(
                    player: player,
                    trackName: trackName,
                    artistName: artistName,
                    artImage: isDurLoaded
                        ? Image.memory(albumArt)
                        : Image.asset("assets/dummyImage.png"),
                  ),
          ),
        ],
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
            //   )