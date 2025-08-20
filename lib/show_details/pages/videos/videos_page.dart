import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/constants/video_types.dart';
import 'package:watching/shared/utils/video_utils.dart';
import 'package:watching/show_details/pages/videos/empty_videos_state.dart';
import 'package:watching/show_details/pages/videos/video_card.dart';
import 'package:watching/show_details/pages/videos/video_filter_chips.dart';
import 'package:watching/youtube_player_dialog.dart';

class VideosPage extends StatefulWidget {
  final List<dynamic> videos;
  final String showTitle;

  const VideosPage({super.key, required this.videos, required this.showTitle});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  final Map<String, bool> _selectedTypes = {
    for (var type in VideoTypes.all) type: true,
  };

  void _toggleType(String type) {
    setState(() {
      _selectedTypes[type] = !(_selectedTypes[type] ?? false);
    });
  }

  List<dynamic> get _filteredVideos {
    if (_selectedTypes.values.every((isSelected) => !isSelected)) {
      return widget.videos;
    }
    return widget.videos.where((video) {
      final type = (video['type'] as String?)?.toLowerCase() ?? '';
      return _selectedTypes[type] == true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.videos)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VideoFilterChips(
            selectedTypes: _selectedTypes,
            onTypeToggled: _toggleType,
          ),
          const Divider(height: 1),
          Expanded(
            child:
                _filteredVideos.isEmpty
                    ? const EmptyVideosState()
                    : _buildVideosList(),
          ),
        ],
      ),
    );
  }

  Widget _buildVideosList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _filteredVideos.length,
      itemBuilder: (context, index) {
        final video = _filteredVideos[index];
        if (video['site'] != 'youtube') return const SizedBox.shrink();

        final url = video['url'] as String? ?? '';
        final videoId = VideoUtils.extractYoutubeVideoId(url);
        final thumbnailUrl = VideoUtils.getYoutubeThumbnailUrl(videoId);

        return VideoCard(
          title: video['title'] ?? AppLocalizations.of(context)!.noTitle,
          type: video['type'],
          thumbnailUrl: thumbnailUrl,
          onTap: () {
            showDialog(
              context: context,
              builder:
                  (_) => YoutubePlayerDialog(
                    url: url,
                    title: video['title'] ?? '',
                  ),
            );
          },
        );
      },
    );
  }
}
