import 'package:flutter/material.dart';
import 'package:harvest_hub/app/core/responsive/responsive.dart';
import 'package:harvest_hub/app/core/widgets/app_shimmer.dart';

/// Renders one of four states: shimmer, error, empty, or real content.
///
/// The loading state uses a shimmer skeleton rather than a centred spinner, so
/// the screen keeps its final layout while data arrives and nothing jumps when
/// the real rows replace it.
///
/// [variant] picks the skeleton shape. Defaults to [StateViewVariant.list];
/// grid-based screens should pass [StateViewVariant.grid] so the placeholder
/// matches the real card layout and column count.
class StateView extends StatelessWidget {
  final bool isLoading;
  final String error;
  final bool isEmpty;
  final String emptyText;
  final VoidCallback onRetry;
  final Widget child;
  final StateViewVariant variant;

  /// Approximate number of skeleton rows to show.
  final int skeletonCount;

  const StateView({
    super.key,
    required this.isLoading,
    required this.error,
    required this.isEmpty,
    required this.onRetry,
    required this.child,
    this.emptyText = 'Nothing here yet',
    this.variant = StateViewVariant.list,
    this.skeletonCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return switch (variant) {
        StateViewVariant.list => ShimmerListSkeleton(count: skeletonCount),
        StateViewVariant.grid => ShimmerProductGrid(
            count: context.resp.productColumns * (skeletonCount ~/ 2),
          ),
        StateViewVariant.order => ShimmerOrderList(count: skeletonCount ~/ 2 + 1),
        // A short, non-list body: one centred block beats a full-screen skeleton.
        StateViewVariant.block => const ShimmerDetailBlock(),
      };
    }

    if (error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(context.resp.dx(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 42, color: Colors.grey),
              SizedBox(height: context.resp.dy(12)),
              Text(error, textAlign: TextAlign.center),
              SizedBox(height: context.resp.dy(16)),
              ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }

    if (isEmpty) return Center(child: Text(emptyText));
    return child;
  }
}

/// Which skeleton shape a loading screen should show.
enum StateViewVariant { list, grid, order, block }
