import 'package:flutter/material.dart';

/// Product image component that renders a network image if present,
/// or a lush gradient background with a category emoji and icon placeholder.
class ProductImagePlaceholder extends StatelessWidget {
  final String? imageUrl;
  final String category;
  final double width;
  final double height;
  final double borderRadius;
  final String? heroTag;

  const ProductImagePlaceholder({
    super.key,
    this.imageUrl,
    required this.category,
    this.width = 72,
    this.height = 72,
    this.borderRadius = 14,
    this.heroTag,
  });

  // Category visual attributes
  static _CategoryStyle _getCategoryStyle(String cat) {
    switch (cat.toLowerCase().trim()) {
      case 'vegetables':
        return const _CategoryStyle(
          emoji: '🥬',
          icon: Icons.eco_rounded,
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: Color(0xFF2E7D32),
        );
      case 'fruits':
        return const _CategoryStyle(
          emoji: '🍎',
          icon: Icons.apple_rounded,
          gradient: LinearGradient(
            colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: Color(0xFFC62828),
        );
      case 'grains':
        return const _CategoryStyle(
          emoji: '🌾',
          icon: Icons.grain_rounded,
          gradient: LinearGradient(
            colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: Color(0xFFF57F17),
        );
      case 'poultry':
        return const _CategoryStyle(
          emoji: '🥚',
          icon: Icons.egg_outlined,
          gradient: LinearGradient(
            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: Color(0xFFE65100),
        );
      case 'honey & dairy':
      case 'dairy':
        return const _CategoryStyle(
          emoji: '🍯',
          icon: Icons.water_drop_outlined,
          gradient: LinearGradient(
            colors: [Color(0xFFFFFDE7), Color(0xFFFFF9C4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: Color(0xFFF9A825),
        );
      case 'herbs & spices':
      case 'herbs':
        return const _CategoryStyle(
          emoji: '🌿',
          icon: Icons.grass_rounded,
          gradient: LinearGradient(
            colors: [Color(0xFFF1F8E9), Color(0xFFDCEDC8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: Color(0xFF558B2F),
        );
      default:
        return const _CategoryStyle(
          emoji: '🌱',
          icon: Icons.spa_rounded,
          gradient: LinearGradient(
            colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentColor: Color(0xFF00695C),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getCategoryStyle(category);

    Widget placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: style.gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: style.accentColor.withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              style.emoji,
              style: TextStyle(fontSize: width * 0.38),
            ),
          ],
        ),
      ),
    );

    Widget imageWidget = (imageUrl != null && imageUrl!.trim().isNotEmpty)
        ? ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Image.network(
              imageUrl!,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => placeholder,
            ),
          )
        : placeholder;

    if (heroTag != null && heroTag!.isNotEmpty) {
      return Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

class _CategoryStyle {
  final String emoji;
  final IconData icon;
  final LinearGradient gradient;
  final Color accentColor;

  const _CategoryStyle({
    required this.emoji,
    required this.icon,
    required this.gradient,
    required this.accentColor,
  });
}
