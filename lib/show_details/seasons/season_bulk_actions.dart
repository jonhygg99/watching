import 'package:flutter/material.dart';

/// AppBar action for marking/unmarking all episodes in a season.
class SeasonBulkActionButton extends StatelessWidget {
  final bool allWatched;
  final bool loading;
  final List<int> episodeNumbers;
  final Future<void> Function(bool allWatched) onBulkAction;

  /// Botón de acción bulk para marcar/desmarcar todos los episodios de la temporada.
  const SeasonBulkActionButton({
    super.key,
    required this.allWatched,
    required this.loading,
    required this.episodeNumbers,
    required this.onBulkAction,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.done_all,
        color: allWatched ? Colors.green : Colors.grey,
      ),
      tooltip: allWatched ? 'Eliminar temporada del historial' : 'Marcar todos como vistos',
      onPressed: loading ? null : () => onBulkAction(allWatched),
    );
  }
}
