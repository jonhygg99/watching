import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/pages/myshows/widgets/calendar/item.dart';

class Calendar extends StatefulWidget {
  final List<dynamic> items;

  const Calendar({super.key, required this.items});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final Map<int, bool> _expandedShows = {};

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noShowsFound));
    }

    return Column(
      children:
          widget.items.asMap().entries.map((entry) {
            final index = entry.key;
            final showData = entry.value;
            final show = showData['show'] ?? {};
            final episodes = List<Map<String, dynamic>>.from(
              showData['episodes'] ?? [],
            );

            // Sort episodes by air date
            episodes.sort(
              (a, b) => (a['first_aired'] as String).compareTo(
                b['first_aired'] as String,
              ),
            );

            // Initialize expanded state if not exists
            _expandedShows.putIfAbsent(index, () => false);

            return StatefulBuilder(
              builder: (context, setState) {
                return CalendarItem(
                  show: show,
                  episodes: episodes,
                  isExpanded: _expandedShows[index]!,
                  onToggleExpand: () {
                    setState(() {
                      _expandedShows[index] = !_expandedShows[index]!;
                    });
                  },
                );
              },
            );
          }).toList(),
    );
  }
}
