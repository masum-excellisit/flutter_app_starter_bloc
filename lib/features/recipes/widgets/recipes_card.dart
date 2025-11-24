import 'package:flutter/material.dart';

import '../models/recipes_model.dart';

class RecipeCard extends StatelessWidget {
  final RecipeModel item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RecipeCard({Key? key, required this.item, this.onEdit, this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(item.name!, style: Theme.of(context).textTheme.titleMedium)),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') onEdit?.call();
                    if (v == 'delete') onDelete?.call();
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(item.cuisine!),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: item.tags!.map((t) => Chip(label: Text(t))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
