import 'package:flutter/material.dart';

/// One place for every field rule in the app.
///
/// Validation used to be written inline in each view, which meant the same
/// concept (a phone number, an address) was enforced differently in different
/// screens - or not at all. Keeping the rules here makes them consistent and
/// unit-testable, and gives the views a single import instead of a private
/// closure each.
abstract class AppValidators {
  /// Pakistani mobile number.
  ///
  /// Accepts the three shapes users actually type:
  /// `03001234567`, `+923001234567` and `923001234567`.
  static final RegExp pkPhone = RegExp(r'^(?:\+92|92|0)?3[0-9]{9}$');

  /// Loose but practical email check. Deliberately not RFC 5322 - the only
  /// authority that matters is whether a mail server accepts the address, and
  /// the confirmation mail is the real test.
  static final RegExp _email =
      RegExp(r'^[\w.!#$%&*+/=?^`{|}~-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$');

  /// Required free text with a minimum length.
  static String? Function(String?) text({
    int minLength = 3,
    String? label,
  }) {
    final name = label ?? 'This field';
    return (v) {
      final t = (v ?? '').trim();
      if (t.isEmpty) return '$name is required';
      if (t.length < minLength) {
        return '$name must be at least $minLength characters';
      }
      return null;
    };
  }

  /// Required person's name. Same rule as [text] but with a clearer message.
  static String? Function(String?) name({String label = 'Name'}) =>
      text(minLength: 3, label: label);

  /// Required email address.
  static String? Function(String?) email({bool allowEmpty = false}) {
    return (v) {
      final t = (v ?? '').trim();
      if (t.isEmpty) {
        return allowEmpty ? null : 'Email is required';
      }
      if (!_email.hasMatch(t)) return 'Enter a valid email';
      return null;
    };
  }

  /// Required Pakistani mobile number.
  static String? Function(String?) phone({bool allowEmpty = false}) {
    return (v) {
      final t = (v ?? '').trim();
      if (t.isEmpty) {
        return allowEmpty ? null : 'Phone number is required';
      }
      if (!pkPhone.hasMatch(t)) {
        return 'Enter a valid Pakistani number, e.g. 03001234567';
      }
      return null;
    };
  }

  /// Required street address, long enough to actually be deliverable.
  static String? Function(String?) address({
    int minLength = 10,
    String label = 'Address',
  }) {
    return (v) {
      final t = (v ?? '').trim();
      if (t.isEmpty) return '$label is required';
      if (t.length < minLength) {
        return '$label must be at least $minLength characters';
      }
      return null;
    };
  }

  /// Required password.
  ///
  /// [minLength] is deliberately permissive at 6: that is the Firebase Auth
  /// default, and anything stricter here produces an error the backend will
  /// not explain.
  static String? Function(String?) password({int minLength = 6}) {
    return (v) {
      final t = v ?? '';
      if (t.isEmpty) return 'Password is required';
      if (t.length < minLength) {
        return 'Password must be at least $minLength characters';
      }
      return null;
    };
  }

  /// Required number greater than zero - prices, stock counts.
  static String? Function(String?) positiveNumber({
    String label = 'Value',
    bool allowZero = false,
  }) {
    return (v) {
      final t = (v ?? '').trim();
      if (t.isEmpty) return '$label is required';
      final n = double.tryParse(t);
      if (n == null) return 'Enter a valid number';
      if (n.isNaN || n.isInfinite) return 'Enter a valid number';
      if (allowZero ? n < 0 : n <= 0) {
        return allowZero ? '$label cannot be negative' : '$label must be greater than 0';
      }
      return null;
    };
  }

  /// Any number, including zero and negatives - coordinates, adjustments.
  static String? Function(String?) number({String label = 'Value'}) {
    return (v) {
      final t = (v ?? '').trim();
      if (t.isEmpty) return '$label is required';
      final n = double.tryParse(t);
      if (n == null || n.isNaN || n.isInfinite) return 'Enter a valid number';
      return null;
    };
  }

  /// Latitude or longitude: any finite number inside the valid range.
  static String? Function(String?) coordinate({
    required String label,
    required double min,
    required double max,
  }) {
    return (v) {
      final t = (v ?? '').trim();
      if (t.isEmpty) return '$label is required';
      final n = double.tryParse(t);
      if (n == null || n.isNaN || n.isInfinite) return 'Enter a valid number';
      if (n < min || n > max) return '$label must be between $min and $max';
      return null;
    };
  }

  /// Marks a field as genuinely optional: anything goes, including empty.
  ///
  /// Use for notes, instructions and secondary inputs. Wrapping these in
  /// [optional] documents the intent and means a future tightening of the
  /// shared rules cannot accidentally start rejecting them.
  static String? Function(String?) optional() => (_) => null;
}

/// Groups several rules into one validator, reporting the first failure.
///
/// Lets a field carry more than one concern (a required address that also has
/// to be long enough) without nesting closures at every call site.
FormFieldValidator<String> all(List<String? Function(String?)> rules) {
  return (v) {
    for (final rule in rules) {
      final error = rule(v);
      if (error != null) return error;
    }
    return null;
  };
}

/// Formats a validation failure for a snackbar, for screens that validate on
/// submit instead of through a `Form`.
String validationMessage(String? error) =>
    error ?? 'Please check the highlighted fields';
