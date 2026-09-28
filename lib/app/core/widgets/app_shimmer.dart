import 'package:flutter/material.dart';
import 'package:harvest_hub/app/core/responsive/responsive.dart';

/// Placeholder block with a sweeping highlight, used while real data loads.
///
/// Preferred over a CircularProgressIndicator for list content: it preserves
/// the final layout, so nothing jumps when the real rows arrive.
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  const ShimmerBox.circle({super.key, required double size})
      : width = size,
        height = size,
        borderRadius = 0;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF262E29) : const Color(0xFFE4EAE3);
    final highlight = isDark ? const Color(0xFF323B35) : const Color(0xFFF6F9F5);

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        // Sweep from off-screen left to off-screen right.
        final t = _c.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 - 2 * (1 - t), 0),
              end: Alignment(1 - 2 * (1 - t), 0),
              colors: [base, highlight, base],
              stops: const [0.1, 0.5, 0.9],
            ),
          ),
        );
      },
    );
  }
}

/// The single building block every skeleton is composed from.
///
/// Reads the responsiveness helper so the placeholder tracks the same scale as
/// the real content it stands in for - a skeleton sized in raw pixels would
/// itself overflow on a small phone.
class ShimmerLine extends StatelessWidget {
  final double height;
  final double width;
  final double radius;

  const ShimmerLine({
    super.key,
    this.height = 12,
    this.width = double.infinity,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) {
    final resp = context.resp;
    return ShimmerBox(
      height: resp.dy(height),
      width: width,
      borderRadius: resp.radius(radius),
    );
  }
}

/// Skeleton shaped like a product row: thumbnail, title, two meta lines, price.
class ShimmerProductTile extends StatelessWidget {
  const ShimmerProductTile({super.key});

  @override
  Widget build(BuildContext context) {
    final resp = context.resp;
    final pad = resp.pad(12);
    final thumb = resp.dx(76);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: resp.dx(16),
        vertical: resp.dy(6),
      ),
      padding: pad,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(resp.radius(20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            width: thumb,
            height: thumb,
            borderRadius: resp.radius(14),
          ),
          SizedBox(width: resp.dx(14)),
          // Expanded keeps the text column from overflowing when the OS font is
          // large; the text lines are fixed-width so nothing else can push out.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLine(height: 14),
                SizedBox(height: resp.dy(10)),
                ShimmerLine(height: 11, width: resp.dx(120)),
                SizedBox(height: resp.dy(8)),
                ShimmerLine(height: 11, width: resp.dx(70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Vertical list of [ShimmerProductTile]s.
class ShimmerProductList extends StatelessWidget {
  final int count;
  const ShimmerProductList({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: context.resp.dy(8)),
      itemCount: count,
      itemBuilder: (_, __) => const ShimmerProductTile(),
    );
  }
}

/// Grid skeleton whose column count matches the real grid, so the layout does
/// not visibly reflow when the data lands.
class ShimmerProductGrid extends StatelessWidget {
  final int count;
  const ShimmerProductGrid({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    final resp = context.resp;
    return GridView.builder(
      padding: EdgeInsets.all(resp.dx(16)),
      // Same derivation as the real grid - see Responsive.productColumns.
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: resp.productColumns,
        crossAxisSpacing: resp.gutter,
        mainAxisSpacing: resp.gutter,
        childAspectRatio: 0.72,
      ),
      itemCount: count,
      itemBuilder: (_, __) => ShimmerBox(
        borderRadius: resp.radius(18),
      ),
    );
  }
}

/// Skeleton for a chat/list row: leading circle, two lines, trailing time.
class ShimmerListTileSkeleton extends StatelessWidget {
  const ShimmerListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final resp = context.resp;
    final avatar = resp.dx(46);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: resp.dx(16),
        vertical: resp.dy(10),
      ),
      child: Row(
        children: [
          ShimmerBox(
            width: avatar,
            height: avatar,
            borderRadius: resp.radius(avatar / 2),
          ),
          SizedBox(width: resp.dx(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLine(height: 13, width: double.infinity),
                SizedBox(height: resp.dy(9)),
                ShimmerLine(height: 11, width: resp.dx(220)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerListSkeleton extends StatelessWidget {
  final int count;
  const ShimmerListSkeleton({super.key, this.count = 7});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (_, __) => const ShimmerListTileSkeleton(),
    );
  }
}

/// Skeleton shaped like an order row: icon tile, title, status pill, amount.
class ShimmerOrderTile extends StatelessWidget {
  const ShimmerOrderTile({super.key});

  @override
  Widget build(BuildContext context) {
    final resp = context.resp;
    final pad = resp.pad(14);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: resp.dx(16),
        vertical: resp.dy(6),
      ),
      padding: pad,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(resp.radius(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(
                width: resp.dx(40),
                height: resp.dx(40),
                borderRadius: resp.radius(12),
              ),
              SizedBox(width: resp.dx(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerLine(height: 13),
                    SizedBox(height: resp.dy(8)),
                    ShimmerLine(height: 10, width: resp.dx(110)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: resp.dy(12)),
          ShimmerLine(height: 14, width: resp.dx(90), radius: 8),
        ],
      ),
    );
  }
}

class ShimmerOrderList extends StatelessWidget {
  final int count;
  const ShimmerOrderList({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: context.resp.dy(8)),
      itemCount: count,
      itemBuilder: (_, __) => const ShimmerOrderTile(),
    );
  }
}

/// Category / services strip: a row of square tiles.
class ShimmerCategoryStrip extends StatelessWidget {
  const ShimmerCategoryStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final resp = context.resp;
    final tile = resp.dx(74);
    return SizedBox(
      height: tile,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: resp.dx(16)),
        itemCount: 6,
        separatorBuilder: (_, __) => SizedBox(width: resp.gutter),
        itemBuilder: (_, __) => ShimmerBox(
          width: tile,
          height: tile,
          borderRadius: resp.radius(18),
        ),
      ),
    );
  }
}

/// Wide banner / hero placeholder.
class ShimmerBanner extends StatelessWidget {
  final double height;
  const ShimmerBanner({super.key, this.height = 150});

  @override
  Widget build(BuildContext context) {
    final resp = context.resp;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: resp.dx(16),
        vertical: resp.dy(8),
      ),
      child: ShimmerBox(
        height: resp.dy(height),
        borderRadius: resp.radius(20),
      ),
    );
  }
}

/// A single centred shimmer block, for screens that are not lists.
///
/// Replaces a bare CircularProgressIndicator on detail screens while keeping the
/// surrounding chrome visible.
class ShimmerDetailBlock extends StatelessWidget {
  final double height;
  const ShimmerDetailBlock({super.key, this.height = 200});

  @override
  Widget build(BuildContext context) {
    final resp = context.resp;
    return Padding(
      padding: EdgeInsets.all(resp.dx(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
            height: resp.dy(height),
            borderRadius: resp.radius(18),
          ),
          SizedBox(height: resp.dy(16)),
          const ShimmerLine(height: 18),
          SizedBox(height: resp.dy(10)),
          ShimmerLine(height: 13, width: context.resp.dx(200)),
          SizedBox(height: resp.dy(10)),
          ShimmerLine(height: 13, width: context.resp.dx(140)),
        ],
      ),
    );
  }
}
