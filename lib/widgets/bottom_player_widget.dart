import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/controller/controller.dart';

class BottomPlayerWidget extends StatefulWidget {
  const BottomPlayerWidget({
    Key? key,
    required this.player,
    required this.trackName,
    required this.artistName,
    required this.artImage,
  }) : super(key: key);
  final AudioPlayer player;
  final String trackName;
  final String artistName;
  // final bool isDurLoaded;
  // final Uint8List? albumArt;
  final Image artImage;

  @override
  State<BottomPlayerWidget> createState() => _BottomPlayerWidgetState();
}

class _BottomPlayerWidgetState extends State<BottomPlayerWidget> {
  final Controller c = Get.find();
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: InkWell(
        onTap: () {
          c.isDrawerOpen.value = !c.isDrawerOpen.value;
        },
        child: Container(
          color: const Color.fromARGB(75, 0, 0, 0),
          height: 75,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.artImage,
              SizedBox(
                width: (MediaQuery.of(context).size.width - 220),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 30,
                      child: Text(
                        widget.trackName,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                      child: Text(
                        widget.artistName,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() => Text(c.musicPosition.value)),
              IconButton(
                iconSize: 40,
                onPressed: () {
                  // isMusicPlaying = !isMusicPlaying;
                  if (widget.player.playing) {
                    widget.player.pause();
                  } else {
                    widget.player.play();
                  }
                  setState(() {});
                },
                icon: Icon(widget.player.playing
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
