import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Central responsiveness utility for HarvestHub.
///
/// ## Why this instead of `flutter_screenutil`
///
/// The brief allowed either. This is a self-contained implementation for three
/// reasons:
///
///  1. **It must not change the approved design.** A mechanical swap to `.sp`
///     everywhere scales every text size by the device ratio, which visibly
///     alters a design that was just signed off. Here, scaling is *clamped*:
///     layout scales with the device, but type only grows to 1.18x and text
///     only shrinks to 0.9x. The layout still adapts; the design is intact.
///
///  2. **No dependency risk.** The project has a chronically full C: drive and
///     has already lost builds to SDK/network problems. No new package, no
///     `pub get` step to fail.
///
///  3. **Deliberate clamping beats raw ratios.** An uncapped `.h` on a tablet
///     produces enormous padding; an uncapped `.sp` produces overflow. Both are
///     the cause of the "overflow warnings on smaller screens" this is meant to
///     solve, so the caps are the feature, not a limitation.
///
/// The API deliberately mirrors ScreenUtil (`.w`, `.h`, `.sp`, `.r`, `.sw`)
/// so call sites stay familiar and could be swapped for the real package later
/// without a rewrite.
///
/// Always reach it through a BuildContext - [BuildContextX.resp] - so the values
/// track orientation and window changes instead of being captured at startup.
class Responsive {
  Responsive._({
    required this.size,
    required this.textScaler,
  })  : _isLandscape = size.width > size.height,
        _shortestSide = size.shortestSide;

  // ---------------------------------------------------------------------------
  // Design baseline: a small, common phone. Chosen so that most phones render
  // at or near 1.0x and only genuinely different sizes deviate.
  // ---------------------------------------------------------------------------
  static const double designWidth = 360;
  static const double designHeight = 690;

  // Clamp bounds. The lower bounds stop small phones from collapsing; the
  // upper bounds stop tablets from ballooning.
  static const double _minW = 0.85;
  static const double _maxW = 1.35;
  static const double _minH = 0.90;
  static const double _maxH = 1.25;
  static const double _minSp = 0.90;
  static const double _maxSp = 1.18;
  static const double _maxR = 1.30;

  /// Widths at or below this are treated as "small phone" - the tightest layout
  /// budget, where overflow actually happens.
  static const double smallPhoneMaxWidth = 340;

  static const double tabletBreakpoint = 600;
  static const double largeTabletBreakpoint = 840;

  final Size size;
  final TextScaler textScaler;
  final bool _isLandscape;
  final double _shortestSide;

  /// Reads the current metrics for [context].
  ///
  /// Re-reading on every call is the point: it means a rotation or a resized
  /// window is reflected without rebuilding the whole tree by hand.
  factory Responsive.of(BuildContext context) {
    final media = MediaQuery.of(context);
    return Responsive._(size: media.size, textScaler: media.textScaler);
  }

  // ---------------------------------------------------------------------------
  // Raw scale factors
  // ---------------------------------------------------------------------------

  /// Width scale, clamped.
  double get w => (size.width / designWidth).clamp(_minW, _maxW);

  /// Height scale, clamped.
  double get h => (size.height / designHeight).clamp(_minH, _maxH);

  /// Border-radius scale - follows width, since radii are horizontal.
  double get r => (size.width / designWidth).clamp(_minW, _maxR);

  /// Font scale, clamped, and damped against the OS text-size setting.
  ///
  /// ScreenUtil's raw `.sp` multiplies by the platform text factor, so a user
  /// with the largest system font gets text scaled twice - which is precisely
  /// what overflows. Here the ratio is clamped and then weighted at 50% against
  /// the platform factor, so a large system font still helps accessibility
  /// without exploding the layout.
  double get sp {
    final ratio = (size.width / designWidth).clamp(_minSp, _maxSp);
    final platform = textScaler.scale(1.0);
    return ratio * (1 + (platform - 1) * 0.5);
  }

  // ---------------------------------------------------------------------------
  // Breakpoints
  // ---------------------------------------------------------------------------

  bool get isPhone => _shortestSide < tabletBreakpoint;
  bool get isTablet =>
      _shortestSide >= tabletBreakpoint && _shortestSide < largeTabletBreakpoint;
  bool get isLargeTablet => _shortestSide >= largeTabletBreakpoint;

  /// True on genuinely cramped devices, where text and paddings must shrink.
  bool get isSmallPhone => size.width <= smallPhoneMaxWidth;

  /// Phone in landscape has very little vertical room; charts and tall cards
  /// need to collapse.
  bool get isShortLandscape => _isLandscape && size.height < 560;

  // ---------------------------------------------------------------------------
  // Layout helpers - these are what actually prevent overflow
  // ---------------------------------------------------------------------------

  /// Columns for a fixed-width grid, so tiles never drop below [minTileWidth].
  ///
  /// This is the single most effective overflow fix: a hardcoded
  /// `crossAxisCount: 2` overflows on a narrow phone and looks sparse on a
  /// tablet. Deriving it from available width handles both.
  int columns({double minTileWidth = 160, int maxColumns = 4}) {
    final count = (size.width / minTileWidth).floor();
    return count.clamp(1, maxColumns).toInt();
  }

  /// Columns for a grid of product-style cards.
  int get productColumns => columns(minTileWidth: 158, maxColumns: 4);

  /// Content width for wide screens, so cards do not stretch to tablet width.
  ///
  /// Returns the available width capped at [maxContentWidth], so a desktop or
  /// large-tablet layout is a centred column rather than absurdly wide cards.
  double contentWidth({double maxContentWidth = 720}) =>
      math.min(size.width, maxContentWidth);

  /// Standard screen padding, slightly tighter on small phones.
  EdgeInsets get screenPadding =>
      EdgeInsets.symmetric(horizontal: 16 * w.clamp(0.85, 1.2), vertical: 8 * h.clamp(0.9, 1.1));

  /// Gutter between cards, scaled with width.
  double get gutter => (12 * w).clamp(10, 18);

  /// Readable line length for body copy on very wide screens.
  double get maxTextWidth => math.min(size.width, 640);

  // ---------------------------------------------------------------------------
  // Grid delegate helpers
  //
  // Shared by every product grid in the app so all of them stay consistent and
  // none of them can clip. `aspect` reproduces each screen's current card
  // proportions at the 360px design width, so the approved design is unchanged
  // on a standard phone.
  // ---------------------------------------------------------------------------

  /// Tile height for a grid, derived from the tile's own width.
  ///
  /// Pass the same [columns] used by the grid delegate. [horizontalPad] is the
  /// total padding on both sides, [gutter] the space between tiles.
  double gridExtent({
    required int columns,
    required double horizontalPad,
    required double gutter,
    double aspect = 1.70,
    double min = 190,
    double max = 340,
  }) {
    final pad = dx(horizontalPad) * 2;
    final gap = dx(gutter) * (columns - 1);
    final usable = size.width - pad - gap;
    final tileWidth = columns > 0 ? usable / columns : usable;
    return (tileWidth * aspect).clamp(min, max);
  }

  /// Grid delegate for product-style cards.
  ///
  /// Defaults reproduce the app's existing card metrics: 2 columns, 12px
  /// gutter, ~270px tall at 360px width.
  SliverGridDelegateWithFixedCrossAxisCount productGridDelegate({
    double horizontalPad = 16,
    double horizontalGutter = 12,
    double verticalGutter = 16,
    double aspect = 1.70,
  }) {
    final cols = productColumns;
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: cols,
      crossAxisSpacing: dx(horizontalGutter),
      mainAxisSpacing: dy(verticalGutter),
      mainAxisExtent: gridExtent(
        columns: cols,
        horizontalPad: horizontalPad,
        gutter: horizontalGutter,
        aspect: aspect,
      ),
    );
  }

  /// Grid delegate for dashboard metric/stat tiles.
  ///
  /// Column count is derived from the available width by default, which keeps
  /// 2 columns on a phone (unchanged) and adds columns on a tablet instead of
  /// stretching each card to half the screen. Pass [columns] to pin it.
  ///
  /// Set [extent] to use a fixed tile height (as the admin stats grid does) or
  /// leave it null and set [aspect] instead.
  SliverGridDelegateWithFixedCrossAxisCount statGridDelegate({
    int? columns,
    double minTileWidth = 160,
    double horizontalPad = 16,
    double gutter = 12,
    double? extent,
    double aspect = 1.0,
  }) {
    final cols = columns ??
        this.columns(minTileWidth: minTileWidth, maxColumns: 4);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: cols,
      crossAxisSpacing: dx(gutter),
      mainAxisSpacing: dy(gutter),
      mainAxisExtent: extent == null ? null : dy(extent),
      childAspectRatio: extent == null ? aspect : 1.0,
    );
  }

  /// True when a value should be treated as a fixed layout token rather than
  /// scaled - useful for icon sizes that must not shrink to nothing.
  double icon(double base) => (base * sp).clamp(base * 0.9, base * 1.12);

  // ---------------------------------------------------------------------------
  // Value helpers
  //
  // Prefer these over raw multiplication so the clamp is always applied. There
  // is deliberately no `16.w` extension: a bare `num` has no BuildContext, so
  // that form would need global mutable state, which breaks on rotation.
  // ---------------------------------------------------------------------------

  /// Horizontal (width-scaled) value.
  double dx(num value) => value * w;

  /// Vertical (height-scaled) value.
  double dy(num value) => value * h;

  /// Font size, clamped and damped against the OS text-size setting.
  double font(num value) => value * sp;

  /// Border radius, width-scaled.
  double radius(num value) => value * r;

  /// Icon size, damped so it never shrinks to nothing.
  double iconSize(num value) => icon(value.toDouble());

  EdgeInsets pad(num value) => EdgeInsets.all(value * w);

  EdgeInsets padH(num value) => EdgeInsets.symmetric(horizontal: value * w);

  EdgeInsets padV(num value) => EdgeInsets.symmetric(vertical: value * h);
}

/// Context extension, so widgets read `context.resp` at the point of use.
extension BuildContextX on BuildContext {
  Responsive get resp => Responsive.of(this);
}
