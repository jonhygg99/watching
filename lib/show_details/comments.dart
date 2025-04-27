import 'package:flutter/material.dart';

class ShowDetailComments extends StatelessWidget {
  final Future<List<dynamic>> commentsFuture;
  final String sort;
  final Map<String, String> sortLabels;
  final ValueChanged<String?> onChangeSort;
  const ShowDetailComments({super.key, required this.commentsFuture, required this.sort, required this.sortLabels, required this.onChangeSort});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text('Comentarios', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text('Ordenar comentarios:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: sort,
              items: sortLabels.keys
                  .map((key) => DropdownMenuItem(
                        value: key,
                        child: Text(sortLabels[key]!),
                      ))
                  .toList(),
              onChanged: onChangeSort,
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<dynamic>>(
          future: commentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Text('Error al cargar comentarios', style: TextStyle(color: Colors.red));
            }
            final comments = snapshot.data;
            if (comments == null || comments.isEmpty) {
              return const Text('No hay comentarios para este show.');
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final c = comments[i];
                final user = c['user']?['username'] ?? 'Anónimo';
                final date = c['created_at']?.substring(0, 10) ?? '';
                final text = c['comment'] ?? '';
                return ListTile(
                  title: Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(text),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
