import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../youtube_player_dialog.dart';
import '../../shared/constants/video_types.dart';

class AllVideosPage extends StatefulWidget {
  final List<dynamic> videos;
  final String showTitle;

  const AllVideosPage({
    super.key,
    required this.videos,
    required this.showTitle,
  });

  @override
  State<AllVideosPage> createState() => _AllVideosPageState();
}

class _AllVideosPageState extends State<AllVideosPage> {
  // Default all video types are selected
  final Map<String, bool> _selectedTypes = {
    for (var type in VideoTypes.all) type: true,
  };

  // Toggle video type selection
  void _toggleType(String type) {
    setState(() {
      _selectedTypes[type] = !(_selectedTypes[type] ?? false);
    });
  }

  // Filter videos based on selected types
  List<dynamic> get _filteredVideos {
    if (_selectedTypes.values.every((isSelected) => !isSelected)) {
      // If no types are selected, show all videos
      return widget.videos;
    }
    return widget.videos.where((video) {
      final type = (video['type'] as String?)?.toLowerCase() ?? '';
      return _selectedTypes[type] == true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('${widget.showTitle} - Videos')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter chips row
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  _selectedTypes.entries.map((entry) {
                    final type = entry.key;
                    final isSelected = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(
                          type[0].toUpperCase() + type.substring(1),
                          style: TextStyle(
                            color:
                                isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) => _toggleType(type),
                        showCheckmark: false,
                        backgroundColor:
                            isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surface,
                        selectedColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color:
                                isSelected
                                    ? theme.colorScheme.primary
                                    : theme.dividerColor,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const Divider(height: 1),
          // Videos list
          Expanded(
            child:
                _filteredVideos.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.videocam_off_outlined,
                            size: 64,
                            color: theme.disabledColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay videos que coincidan con los filtros',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.disabledColor,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _filteredVideos.length,
                      itemBuilder: (context, index) {
                        final video = _filteredVideos[index];
                        final isYoutube =
                            video['site'] == 'youtube' ||
                            (video['url'] ?? '').contains('youtube.com') ||
                            (video['url'] ?? '').contains('youtu.be');

                        if (!isYoutube) return const SizedBox.shrink();

                        String? thumbnailUrl;
                        final url = video['url'] ?? '';
                        final regExp = RegExp(
                          r'(?:v=|youtu.be/|embed/)([\w-]{11})',
                        );
                        final match = regExp.firstMatch(url);
                        final videoId = match?.group(1);
                        if (videoId != null) {
                          thumbnailUrl =
                              'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.0),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (thumbnailUrl != null)
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(12.0),
                                            ),
                                        child: CachedNetworkImage(
                                          imageUrl: thumbnailUrl,
                                          height: 200,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorWidget:
                                              (context, error, stackTrace) =>
                                                  Container(
                                                    height: 200,
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.videocam,
                                                      size: 50,
                                                    ),
                                                  ),
                                        ),
                                      )
                                    else
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(12.0),
                                            ),
                                        child: Container(
                                          height: 200,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.videocam,
                                            size: 50,
                                          ),
                                        ),
                                      ),
                                    const Icon(
                                      Icons.play_circle_filled,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        video['title'] ?? 'Sin tÃ­tulo',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        video['type'] ?? '',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
