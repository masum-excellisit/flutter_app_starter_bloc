import 'package:flutter/material.dart';

class ReusableSearchInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final List<String>? toSearch;

  const ReusableSearchInput({
    super.key,
    required this.controller,
    this.onChanged,
    this.hintText = 'Search',
    this.toSearch,
  });

  @override
  Widget build(BuildContext context) {
    print('ReusableSearchInput build with toSearch: $toSearch');
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
        // suffixIcon: toSearch != null && toSearch!.isNotEmpty
        //     ? Tooltip(
        //         message: 'Searching in: ${toSearch!.join(', ')}',
        //         child: const Icon(Icons.filter_list, size: 20),
        //       )
        //     : null,
      ),
    );
  }
}
