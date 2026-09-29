import 'package:flutter_test/flutter_test.dart';
import 'package:harvest_hub/app/core/utils/validators.dart';

/// The validation rules are the one place every form in the app agrees on, so
/// they are pinned here rather than only being exercised indirectly through
/// whichever screen happens to be tested.
void main() {
  group('Pakistani phone number', () {
    // The three shapes the brief requires support for.
    for (final valid in ['03001234567', '+923001234567', '923001234567']) {
      test('accepts $valid', () {
        expect(AppValidators.phone()(valid), isNull);
      });
    }

    for (final invalid in <String>[
      '',
      '   ',
      '0300123456', // one digit short
      '030012345678', // one digit long
      '04001234567', // not a mobile prefix
      '1234567890', // no leading 03
      '+1 555-0199', // the US placeholder that used to sit in this app
      '+91 98765 43210', // the Indian placeholder that used to sit in this app
      '0300-1234567', // punctuation is not accepted
      'abcde12345',
    ]) {
      test('rejects "${invalid.isEmpty ? '(empty)' : invalid}"', () {
        expect(AppValidators.phone()(invalid), isNotNull);
      });
    }

    test('allowEmpty keeps a blank optional number optional', () {
      expect(AppValidators.phone(allowEmpty: true)(''), isNull);
      // ...but a number that IS given still has to be valid.
      expect(AppValidators.phone(allowEmpty: true)('04001234567'), isNotNull);
    });
  });

  group('Names and short text', () {
    test('rejects empty and short values', () {
      expect(AppValidators.name()(''), isNotNull);
      expect(AppValidators.name()('  '), isNotNull);
      expect(AppValidators.name()('Al'), isNotNull);
    });

    test('accepts three characters or more', () {
      expect(AppValidators.name()('Ali'), isNull);
      expect(AppValidators.name()('Rajesh Kumar'), isNull);
    });

    test('trims before measuring', () {
      // Three real characters padded with spaces is a valid name.
      expect(AppValidators.name()('  Ali  '), isNull);
      // Two real characters padded out is still too short.
      expect(AppValidators.name()('  Al  '), isNotNull);
    });
  });

  group('Email', () {
    for (final valid in ['user@example.com', 'first.last@sub.domain.co']) {
      test('accepts $valid', () => expect(AppValidators.email()(valid), isNull));
    }
    for (final invalid in ['', 'plain', 'no@domain', 'no@.com', '@example.com', 'a b@c.com']) {
      test('rejects "${invalid.isEmpty ? '(empty)' : invalid}"',
          () => expect(AppValidators.email()(invalid), isNotNull));
    }
  });

  group('Address', () {
    test('requires ten characters', () {
      // 8 characters - too short to be deliverable.
      expect(AppValidators.address()('123 Main'), isNotNull);
      expect(AppValidators.address()('Karachi'), isNotNull);
      expect(
        AppValidators.address()('House 12, Street 4, Karachi'),
        isNull,
      );
      // Exactly ten is enough.
      expect(AppValidators.address()('1234567890'), isNull);
    });

    test('optional() permits anything, including empty', () {
      expect(AppValidators.optional()(''), isNull);
      expect(AppValidators.optional()('x'), isNull);
    });
  });

  group('Numbers', () {
    test('positiveNumber rejects zero, negatives and junk', () {
      expect(AppValidators.positiveNumber()('0'), isNotNull);
      expect(AppValidators.positiveNumber()('-5'), isNotNull);
      expect(AppValidators.positiveNumber()('abc'), isNotNull);
      expect(AppValidators.positiveNumber()('12.50'), isNull);
    });

    test('allowZero accepts a sold-out stock level but not a negative one', () {
      final v = AppValidators.positiveNumber(allowZero: true);
      expect(v('0'), isNull);
      expect(v('-1'), isNotNull);
      expect(v('40'), isNull);
    });

    test('coordinate range-checks latitude and longitude', () {
      final lat = AppValidators.coordinate(label: 'Latitude', min: -90, max: 90);
      expect(lat('24.8607'), isNull);
      expect(lat('91'), isNotNull);
      expect(lat('-91'), isNotNull);

      final lng = AppValidators.coordinate(label: 'Longitude', min: -180, max: 180);
      expect(lng('67.0011'), isNull);
      expect(lng('181'), isNotNull);
    });
  });

  group('Password', () {
    test('defaults to the Firebase minimum of six', () {
      expect(AppValidators.password()('short'), isNotNull);
      expect(AppValidators.password()('secret123'), isNull);
    });

    test('login only requires a non-empty password', () {
      // A user typing a wrong password should get "Incorrect password" from
      // the backend, not a client-side length complaint.
      expect(AppValidators.password(minLength: 1)('x'), isNull);
      expect(AppValidators.password(minLength: 1)(''), isNotNull);
    });
  });

  group('all()', () {
    test('reports the first failure and passes when every rule passes', () {
      final v = all([
        AppValidators.name(),
        AppValidators.text(minLength: 5, label: 'Label'),
      ]);
      expect(v('Ali'), isNotNull); // first rule fails
      expect(v('Alice'), isNull);
    });
  });
}
