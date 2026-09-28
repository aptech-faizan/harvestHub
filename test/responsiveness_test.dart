import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:harvest_hub/app/core/responsive/responsive.dart';
import 'package:harvest_hub/app/core/widgets/app_shimmer.dart';
import 'package:harvest_hub/app/core/widgets/app_stat_card.dart';
import 'package:harvest_hub/app/data/services/auth_service.dart';
import 'package:harvest_hub/app/modules/auth/controllers/login_controller.dart';
import 'package:harvest_hub/app/modules/auth/views/login_view.dart';
import 'package:harvest_hub/app/routes/app_pages.dart';

/// Guards the responsiveness work: no layout may overflow, and the scaling
/// helpers must stay inside their documented clamps.
///
/// An overflow is a silent visual defect in production - the offending widget
/// paints a yellow-and-black stripe and everything to its right is clipped. A
/// widget test is the only way to catch it without a device on every screen
/// size, which is why this suite exists.
void main() {
  // Sizes chosen to bracket the clamped range rather than to be exhaustive:
  // a small phone, the design baseline, a large phone, a tablet, and a
  // short landscape window (the tightest vertical budget in the app).
  const sizes = <String, Size>{
    'small phone 320x568': Size(320, 568),
    'design baseline 360x690': Size(360, 690),
    'large phone 430x932': Size(430, 932),
    'tablet 800x1280': Size(800, 1280),
    'landscape 740x360': Size(740, 360),
  };

  group('Responsive scaling stays within its clamps', () {
    for (final entry in sizes.entries) {
      testWidgets('${entry.key} - w/h/sp/r within bounds', (tester) async {
        late Responsive r;
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(size: entry.value),
            child: Builder(
              builder: (context) {
                r = Responsive.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // A clamped scale is the whole point of the helper: it must never
        // diverge, or the approved design stops being the approved design.
        expect(r.w, inInclusiveRange(0.85, 1.35));
        expect(r.h, inInclusiveRange(0.90, 1.25));
        expect(r.sp, inInclusiveRange(0.90, 1.18));
        expect(r.r, inInclusiveRange(0.85, 1.30));
      });
    }

    testWidgets('design baseline renders at 1.0 so the approved design is untouched',
        (tester) async {
      // This is the guarantee that the refactor is design-neutral: at the
      // baseline size every scale factor is exactly 1, so nothing moves.
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(360, 690)),
          child: Builder(
            builder: (context) {
              final r = Responsive.of(context);
              expect(r.w, 1.0);
              expect(r.h, 1.0);
              expect(r.sp, 1.0);
              expect(r.r, 1.0);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('column count is bounded and never zero', (tester) async {
      for (final size in sizes.values) {
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                final r = Responsive.of(context);
                expect(r.productColumns, inInclusiveRange(1, 4));
                expect(r.productColumns, greaterThan(0));
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      }
    });
  });

  group('No layout overflow at any supported size', () {
    for (final entry in sizes.entries) {
      testWidgets('LoginView renders without overflow on ${entry.key}',
          (tester) async {
        // Captured, not re-reported: the assertion below then reports *which*
        // widget overflowed, instead of the framework dumping a raw render
        // error with no context.
        final overflows = _captureOverflows(tester);

        await tester.binding.setSurfaceSize(entry.value);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        Get.reset();
        // LoginController resolves AuthService in its constructor, so the
        // dependency has to be in the container first. AuthService.onInit
        // try/catches the missing Firebase app, leaving firebaseUser null.
        Get.put(AuthService());
        Get.put(LoginController());
        await tester.pumpWidget(
          GetMaterialApp(home: const LoginView(), getPages: AppPages.pages),
        );
        // pump() rather than pumpAndSettle(): a settling pump times out on any
        // repeating animation, which would mask the layout result.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(overflows, isEmpty, reason: _format(entry.key, overflows));
      });
    }

    testWidgets('AppStatCard icon + trend row survives a small tile',
        (tester) async {
      // The trend pill was the one part of this card that could not shrink,
      // which overflowed once the OS text scale was raised.
      final overflows = _captureOverflows(tester);

      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: GridView.count(
              crossAxisCount: 2,
              mainAxisExtent: 156,
              padding: const EdgeInsets.all(16),
              children: const [
                AppStatCard(title: 'Total Orders', value: '1,284', trend: '+12.4%'),
                AppStatCard(title: 'Gross Revenue', value: 'PKR 84k', trend: '+3.1%'),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(overflows, isEmpty, reason: _format('320x568 stat grid', overflows));
    });
  });

  group('Shimmer skeletons match their content shape', () {
    testWidgets('ShimmerProductGrid uses the same column count as the grid it replaces',
        (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: Scaffold(body: ShimmerProductGrid())),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // A skeleton with a different column count than the real grid is worse
      // than a spinner: the content visibly jumps when the data lands.
      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, Responsive.of(
            tester.element(find.byType(ShimmerProductGrid)),
          ).productColumns);
    });

    testWidgets('shimmer animates and does not throw', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: ShimmerProductList(count: 3),
          ),
        ),
      );
      // Enough frames for the sweeping highlight to move.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(tester.takeException(), isNull);
    });
  });
}

/// Installs a [FlutterError.onError] hook that records overflow errors instead
/// of throwing, so the assertion can report the offending widget by name.
///
/// The default handler is deliberately *not* chained: forwarding would fail the
/// test immediately and the useful reason string would never be printed.
List<String> _captureOverflows(WidgetTester tester) {
  final overflows = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    final text = '${details.exception}';
    if (text.contains('overflowed')) {
      // Include the creator chain - that is what identifies the culprit widget.
      overflows.add(details.toString());
    }
    // Anything that is not an overflow is left to the default handling.
    if (!text.contains('overflowed')) previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);
  return overflows;
}

String _format(String size, List<String> overflows) {
  if (overflows.isEmpty) return 'no overflow recorded on $size';
  return 'Overflow on $size:\n${overflows.join('\n---\n')}';
}
