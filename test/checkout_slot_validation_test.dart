import 'package:flutter_test/flutter_test.dart';
import 'package:harvest_hub/app/data/models/pickup_slot_model.dart';
import 'package:harvest_hub/app/modules/customer/checkout/controllers/checkout_controller.dart';

/// Guards the rule that an order cannot be placed without a pickup slot for
/// every farmer.
///
/// The bug this pins: the requirement used to be conditional on the farmer
/// having slots available, so a farmer whose slot list was empty - not loaded
/// yet, failed to load, or all already in the past - still got an order
/// created, carrying an empty `pickupSlotId` and a misleading
/// "Standard Delivery" label on what is meant to be a collection.
void main() {
  PickupSlotModel slot(String id, {String farmerId = 'f1'}) => PickupSlotModel(
        id: id,
        farmerId: farmerId,
        startTime: DateTime(2030, 1, 1, 9),
        endTime: DateTime(2030, 1, 1, 12),
        capacity: 10,
        bookedCount: 0,
      );

  String? missing({
    required List<String> farmerIds,
    required Map<String, List<PickupSlotModel>> slots,
    required Map<String, String> selected,
  }) =>
      CheckoutController.farmerMissingPickupSlot(
        farmerIds: farmerIds,
        farmerSlots: slots,
        selectedSlotId: selected,
      );

  group('The reported bug: farmer with an empty slot list', () {
    test('is reported as missing a slot, not skipped', () {
      // This is the case the old `availableSlots.isNotEmpty &&` guard let
      // through: no slots at all, so no selection could be made.
      expect(
        missing(
          farmerIds: ['f1'],
          slots: const {},
          selected: const {},
        ),
        'f1',
      );
    });

    test('an explicitly empty slot list behaves the same as an absent one', () {
      expect(
        missing(
          farmerIds: ['f1'],
          slots: const {'f1': <PickupSlotModel>[]},
          selected: const {'f1': 'slot-1'},
        ),
        'f1',
        reason: 'a selected id that resolves to nothing is not a usable slot',
      );
    });

    test('an empty selection is rejected even when slots exist', () {
      expect(
        missing(
          farmerIds: ['f1'],
          slots: {
            'f1': [slot('slot-1')],
          },
          selected: const {'f1': ''},
        ),
        'f1',
      );
    });
  });

  group('A complete, valid selection is accepted', () {
    test('single farmer', () {
      expect(
        missing(
          farmerIds: ['f1'],
          slots: {
            'f1': [slot('slot-1'), slot('slot-2')],
          },
          selected: const {'f1': 'slot-2'},
        ),
        isNull,
      );
    });

    test('every farmer in a multi-farmer cart', () {
      expect(
        missing(
          farmerIds: ['f1', 'f2', 'f3'],
          slots: {
            'f1': [slot('a1', farmerId: 'f1')],
            'f2': [slot('b1', farmerId: 'f2')],
            'f3': [slot('c1', farmerId: 'c1'.replaceAll('c1', 'f3'))],
          },
          selected: const {'f1': 'a1', 'f2': 'b1', 'f3': 'c1'},
        ),
        isNull,
      );
    });
  });

  group('One bad farmer fails the whole order', () {
    test('a missing selection on the second of three farmers is caught', () {
      final result = missing(
        farmerIds: ['f1', 'f2', 'f3'],
        slots: {
          'f1': [slot('a1', farmerId: 'f1')],
          'f2': [slot('b1', farmerId: 'f2')],
          'f3': [slot('c1', farmerId: 'f3')],
        },
        selected: const {'f1': 'a1', 'f3': 'c1'}, // f2 absent entirely
      );
      expect(result, 'f2');
    });

    test('a stale selection on one farmer fails the whole order', () {
      // The slot was withdrawn after the customer picked it.
      final result = missing(
        farmerIds: ['f1', 'f2'],
        slots: {
          'f1': [slot('a1', farmerId: 'f1')],
          'f2': [slot('b1', farmerId: 'f2')],
        },
        selected: const {'f1': 'a1', 'f2': 'b-withdrawn'},
      );
      expect(result, 'f2');
    });

    test('reports the first offender', () {
      final result = missing(
        farmerIds: ['f1', 'f2'],
        slots: const {'f1': <PickupSlotModel>[], 'f2': <PickupSlotModel>[]},
        selected: const {},
      );
      expect(result, 'f1');
    });
  });

  group('Edge cases', () {
    test('an empty cart has nothing to validate', () {
      // No farmers means no missing slot - though placeOrder already rejects an
      // empty cart earlier, so this case never reaches the check in practice.
      expect(
        missing(farmerIds: const [], slots: const {}, selected: const {}),
        isNull,
      );
    });

    test('a farmer missing from farmerSlots entirely is caught', () {
      expect(
        missing(
          farmerIds: ['f1'],
          slots: const {},
          selected: const {'f1': 'slot-1'},
        ),
        'f1',
      );
    });
  });
}
