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
          useHybridComposition: true,
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
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        controller.dispose();
      };
    }, []);

    return OrientationBuilder(
      builder: (context, orientation) {
        final size = MediaQuery.of(context).size;
        final isLandscape = orientation == Orientation.landscape;
        
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: Container(
            width: isLandscape ? size.width : size.width,
            height: isLandscape ? size.height : size.height * 0.3,
            child: YoutubePlayer(
              controller: controller,
              showVideoProgressIndicator: true,
              aspectRatio: isLandscape ? size.width / size.height : 16 / 9,
              onEnded: (_) {
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }
}
