import 'package:flutter/material.dart';

// Shows a spinner, an error with retry, an empty message, or the real content.
class StateView extends StatelessWidget {
  final bool isLoading;
  final String error;
  final bool isEmpty;
  final String emptyText;
  final VoidCallback onRetry;
  final Widget child;

  const StateView({
    super.key,
    required this.isLoading,
    required this.error,
    required this.isEmpty,
    required this.onRetry,
    required this.child,
    this.emptyText = 'Nothing here yet',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error.isNotEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(error, textAlign: TextAlign.center),
          ),
          ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
        ]),
      );
    }
    if (isEmpty) return Center(child: Text(emptyText));
    return child;
  }
}
