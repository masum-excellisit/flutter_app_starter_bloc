import 'package:flutter/material.dart';

class SortSelector extends StatelessWidget {
  final List<String> sortFields;
  final String? currentSortBy;
  final bool isAscending;
  final Function(String field, bool ascending) onSortChanged;

  const SortSelector({
    super.key,
    required this.sortFields,
    this.currentSortBy,
    this.isAscending = true,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort),
          tooltip: 'Sort by',
          onSelected: (field) => onSortChanged(field, isAscending),
          itemBuilder: (context) => sortFields
              .map((field) => PopupMenuItem(
                    value: field,
                    child: Row(
                      children: [
                        Text(field.toUpperCase()),
                        if (currentSortBy == field) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.check, size: 16),
                        ],
                      ],
                    ),
                  ))
              .toList(),
        ),
        if (currentSortBy != null)
          IconButton(
            icon: Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward),
            tooltip: isAscending ? 'Ascending' : 'Descending',
            onPressed: () => onSortChanged(currentSortBy!, !isAscending),
          ),
      ],
    );
  }
}
