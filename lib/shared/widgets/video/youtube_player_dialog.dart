import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

class YoutubePlayerDialog extends HookWidget {
  final String url;
  final String title;
  
  const YoutubePlayerDialog({
    super.key, 
    required this.url, 
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final videoId = YoutubePlayer.convertUrlToId(url) ?? '';
    final controller = useMemoized(() {
      return YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
          disableDragSeek: false,
          loop: false,
          forceHD: true,
          hideControls: false,
          controlsVisibleAtStart: true,
        ),
      );
    }, [videoId]);

    // Handle orientation changes
    useEffect(() {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      return () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
        controller.dispose();
      };
    }, []);

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.3,
            child: YoutubePlayer(
              controller: controller,
              showVideoProgressIndicator: true,
              aspectRatio: 16 / 9,
              onEnded: (_) {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            top: 8.0,
            right: 8.0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white, size: 24.0),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        backgroundColor: Colors.black,
                        body: Center(
                          child: YoutubePlayer(
                            controller: controller,
                            showVideoProgressIndicator: true,
                            aspectRatio: 16 / 9,
                            onEnded: (_) {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                      fullscreenDialog: true,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
