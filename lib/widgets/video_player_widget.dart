import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';

class NewVideoPlay extends StatefulWidget {
  final String? pathh;
  final String? type;

  @override
  _NewVideoPlayState createState() => _NewVideoPlayState();

  const NewVideoPlay({
    super.key,
    this.type,
    required this.pathh, // Video from previous path
  });
}

class _NewVideoPlayState extends State<NewVideoPlay> {
  ValueNotifier<VideoPlayerValue?> currentPosition = ValueNotifier(null);
  VideoPlayerController? controller;
  late Future<void> futureController;
  bool isFullScreen = false;

  initVideo() {
    controller = widget.type == 'url'
        ? VideoPlayerController.networkUrl(Uri.parse(widget.pathh!))
        : VideoPlayerController.file(File(widget.pathh!));
    futureController = controller!.initialize();
  }

  @override
  void initState() {
    super.initState();
    initVideo();
    controller!.addListener(() {
      if (controller!.value.isInitialized) {
        currentPosition.value = controller!.value;
      }
    });
    debugPrint(widget.pathh.toString());
  }

  @override
  void dispose() {
    controller?.pause();
    controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
      if (isFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setPreferredOrientations([]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              //Navigator.pop(context);
              Navigator.pop(context);

              setState(() {});
            },
            icon: Icon(
              Icons.arrow_back,
              size: 40,
              color: AppColors.white,
            ),
          ),
        ),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            FutureBuilder(
              future: futureController,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    controller!.value.isInitialized) {
                  return Center(
                    child: AspectRatio(
                      aspectRatio: controller!.value.aspectRatio,
                      child: VideoPlayer(controller!),
                    ),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      backgroundColor: Color(0xffDEDAD8),
                    ),
                  );
                } else {
                  return Center(
                    child: Text("Error loading video   ${snapshot.hasError}",
                        style: TextStyle(color: Colors.white)),
                  );
                }
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () async {
                          Duration? position = await controller!.position;
                          setState(() {
                            controller!.seekTo(
                                Duration(seconds: position!.inSeconds - 10));
                          });
                        },
                        icon: const Icon(
                          Icons.fast_rewind_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (controller!.value.isPlaying) {
                              controller!.pause();
                            } else {
                              controller!.play();
                            }
                          });
                        },
                        icon: Icon(
                          controller!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          Duration? position = await controller!.position;
                          setState(() {
                            controller!.seekTo(
                                Duration(seconds: position!.inSeconds + 10));
                          });
                        },
                        icon: const Icon(
                          Icons.fast_forward_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: VideoProgressIndicator(
                    controller!,
                    allowScrubbing: true,
                    colors: const VideoProgressColors(
                        bufferedColor: Color(0xffDEDAD8),
                        playedColor: Colors.blueAccent),
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: currentPosition,
                  builder: (context, VideoPlayerValue? videoPlayerValue, w) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            videoPlayerValue?.position
                                    .toString()
                                    .split('.')
                                    .first ??
                                "Loading...",
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            ' ${videoPlayerValue?.duration.toString().split('.').first ?? ""}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // IconButton(
                //   onPressed: toggleFullScreen,
                //   icon: Icon(
                //     isFullScreen
                //         ? Icons.fullscreen_exit
                //         : Icons.fullscreen,
                //     color: Colors.white,
                //     size: 30,
                //   ),
                // ),
              ],
            )
          ],
        ));
    // persistentFooterButtons: isFullScreen
    // ? null
    // :
    // [
    // ],
  }
}
