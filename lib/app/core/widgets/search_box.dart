import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const SearchBox({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
