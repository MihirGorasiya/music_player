// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables,prefer_const_literals_to_create_immutables

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/controller/controller.dart';

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage(
      {Key? key,
      required this.audioPlayer,
      required this.albumArt,
      required this.trackName,
      required this.artistName})
      : super(key: key);
  final AudioPlayer audioPlayer;
  final Uint8List? albumArt;
  final String trackName;
  final String artistName;
  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final Controller c = Get.find();
  late double sliderValue = 0;
  // late bool isMusicPlaying = true;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: ((details) {
        c.isDrawerOpen.value = !c.isDrawerOpen.value;
      }),
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(50, 68, 137, 255),
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  height: 250,
                  width: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: widget.audioPlayer.currentIndex!.isNaN
                        ? Image.asset("assets/dummyImage.png")
                        : Image.memory(widget.albumArt!),
                  ),
                ),
                SizedBox(
                  height: 100,
                ),
                Text(widget.trackName),
                Text(widget.artistName),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Slider(
                    value: sliderValue,
                    onChanged: (value) {
                      sliderValue = value;
                      setState(() {});
                    },
                    onChangeStart: (value) {
                      sliderValue = value;
                      setState(() {});
                    },
                    onChangeEnd: (value) {
                      sliderValue = value;
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "${widget.audioPlayer.position.inMinutes}:${widget.audioPlayer.position.inSeconds}"),
                      Text(
                          "${widget.audioPlayer.duration?.inMinutes}:${widget.audioPlayer.duration!.inSeconds}"),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        iconSize: 40,
                        onPressed: () {},
                        icon: Icon(Icons.skip_previous_rounded),
                      ),
                      IconButton(
                        iconSize: 40,
                        onPressed: () {
                          // isMusicPlaying = !isMusicPlaying;
                          if (widget.audioPlayer.playing) {
                            widget.audioPlayer.pause();
                          } else {
                            widget.audioPlayer.play();
                          }
                          setState(() {});
                        },
                        icon: Icon(widget.audioPlayer.playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded),
                      ),
                      IconButton(
                        iconSize: 40,
                        onPressed: () {},
                        icon: Icon(Icons.skip_next_rounded),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// Text(  "${widget.audioPlayer.duration!.inMinutes}:${widget.audioPlayer.duration!.inSeconds}")
//widget.audioPlayer.play();