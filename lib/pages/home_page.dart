// ignore_for_file: prefer_typing_uninitialized_variables, prefer_const_constructors, avoid_print, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/controller/controller.dart';
import 'package:music_player/database_utils/SongInfo.dart';
import 'package:music_player/database_utils/database_helper.dart';
import 'package:music_player/pages/music_player_page.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:music_player/widgets/bottom_player_widget.dart';
import 'package:path_provider/path_provider.dart';
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
  late Future<List<SongInfo>?>? future;

  // --------Path Manager--------
  List<String> dirPaths = [];
  List<String> musicPaths = [];
  List<String> musicTrackNames = [];
  List<Uint8List?> musicAlbumArts = [];
  String internalDirPath = '/storage/emulated/0/';
  String externalDirPath = '/storage/453E-10F7/';
  String currentMusicPath = '';
  bool isDatabaseCreated = false;

  // --------Audio Manager--------
  AudioPlayer player = AudioPlayer();
  late Duration dur;

  // --------Matadata--------
  String trackName = 'Track Name';
  String artistName = 'Artist Name';
  Image albumArt = Image.asset("assets/dummyImage.png");

  @override
  void initState() {
    requestPermission();
    setLastSongToPlayer();
    super.initState();
  }

  void requestPermission() async {
    var status = await Permission.storage.status;

    if (status.isDenied) {
      await Permission.storage.request();
      await Permission.storage.isGranted;
      scanInitially();
    } else if (status.isGranted) {
      scanInitially();
    }
  }

  void scanInitially() async {
    Directory? dir = await getExternalStorageDirectory();
    String path = '${dir!.path}/songInfos';

    if (!(File("$path/songInfo.db").existsSync())) {
      getPaths();
    } else {
      setState(() {
        future = DatabaseHelper.getAllNotes();
        isDatabaseCreated = true;
      });
    }
  }

  void getPaths() async {
    DatabaseHelper.deleteData();
    await Future.delayed(Duration(seconds: 1));
    var dir = Directory(internalDirPath);
    dirPaths = dir.listSync().map((e) => e.path).toList();

    dirPaths.addAll(
        Directory(externalDirPath).listSync().map((e) => e.path).toList());

    for (int i = 0; i < dirPaths.length; i++) {
      if (dirPaths[i].split('/').last.contains('.') ||
          dirPaths[i].split('/').last.contains('Android')) {
        dirPaths.removeAt(i);
      } else {
        print("Path:::${dirPaths[i]}");
        Directory path = Directory("${dirPaths[i]}/");
        musicPaths.addAll(path
            .listSync(recursive: true)
            .map((e) => e.path)
            .where((item) => item.endsWith('.mp3'))
            .toList());
      }
    }

    getAllAlbumArts();
    setState(() {});
  }

  void setLastSongToPlayer() async {
    final SharedPreferences prefs = await _prefs;
    if (prefs.getString('lastSong') != null) {
      initAudioPlayer(prefs.getString('lastSong')!, false);
    }
  }

  void initAudioPlayer(String musicPath, bool playInitially) async {
    player.stop();
    dur = (await player.setFilePath(musicPath))!;
    var metadata = await MetadataRetriever.fromFile(File(musicPath));

    setCurrentMusicInfos(metadata, musicPath);

    final SharedPreferences prefs = await _prefs;
    prefs.setString('lastSong', musicPath);

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
      albumArt = Image.memory(metadata.albumArt!);
    } else {
      albumArt = Image.asset("assets/dummyImage.png");
    }
  }

  void getAllAlbumArts() async {
    for (int i = 0; i < musicPaths.length; i++) {
      var metadata = await MetadataRetriever.fromFile(File(musicPaths[i]));
      musicAlbumArts.add(metadata.albumArt);

      Directory? externalDirectory = await getExternalStorageDirectory();
      String imageDirectoryPath = "${externalDirectory!.path}/cacheImages/";

      String tName = "";
      if (!Directory("${externalDirectory.path}/cacheImages/").existsSync()) {
        await Directory("${externalDirectory.path}/cacheImages/").create();
      }
      if (metadata.trackName != null) {
        tName = metadata.trackName!;
      } else {
        tName = "dummyImage";
      }
      if (tName.contains('/')) {
        tName = metadata.trackName!.split("/").join('');
      }

      File imageFile = File('$imageDirectoryPath$tName.png');

      if (!imageFile.existsSync()) {
        await imageFile.create();
      }
      if (metadata.albumArt != null) {
        await imageFile.writeAsBytes(metadata.albumArt!);
      }
      print("track name: ${tName}");
      DatabaseHelper.addData(
        SongInfo(
          songName: tName == "dummyImage"
              ? musicPaths[i].split('/').last.split('.').first
              : tName,
          songPath: musicPaths[i],
          imagePath: imageFile.path,
        ),
      );
    }
    setState(() {
      future = DatabaseHelper.getAllNotes();
      isDatabaseCreated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Music Player"),
        actions: [
          IconButton(
              onPressed: () {
                getPaths();
              },
              icon: Icon(Icons.refresh)),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Expanded(
                child: isDatabaseCreated
                    ? FutureBuilder<List<SongInfo>?>(
                        future: future,
                        builder:
                            (context, AsyncSnapshot<List<SongInfo>?> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Text("importing File ."),
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(child: Text("${snapshot.error}"));
                          } else if (snapshot.hasData) {
                            return Scrollbar(
                              thumbVisibility: true,
                              thickness: 10,
                              child: ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child:
                                          File(snapshot.data![index].imagePath)
                                                      .lengthSync() >
                                                  2000
                                              ? Image.file(
                                                  File(snapshot
                                                      .data![index].imagePath),
                                                  height: 50,
                                                  width: 50)
                                              : Image.asset(
                                                  "assets/dummyImage.png",
                                                  height: 50,
                                                  width: 50),
                                    ),
                                    title: Text(snapshot.data![index].songName),
                                    onTap: () {
                                      currentMusicPath =
                                          snapshot.data![index].songPath;
                                      initAudioPlayer(currentMusicPath, true);
                                      setState(() {});
                                    },
                                  );
                                },
                              ),
                            );
                          } else {
                            return Center(
                              child: Text("importing File....."),
                            );
                          }
                        },
                      )
                    : Center(
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(
                            height: 30,
                          ),
                          Text("Importing Files."),
                        ],
                      )),
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
                    artImage: albumArt,
                  ),
          ),
        ],
      ),
    );
  }
}
