import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/constants/genres.dart';

const double kRadiusChip = 16.0;

class GenresChips extends StatelessWidget {
  final List<dynamic> genres;

  const GenresChips({super.key, required this.genres});

  @override
  Widget build(BuildContext context) {
    if (genres.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children:
          genres.map<Widget>((genre) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(kRadiusChip),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Text(
                Genres.getTranslatedGenre(genre as String, AppLocalizations.of(context)!).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  height: 1.2,
                ),
                strutStyle: const StrutStyle(
                  fontSize: 12,
                  height: 1.2,
                  leading: 0,
                ),
              ),
            );
          }).toList(),
    );
  }
}
