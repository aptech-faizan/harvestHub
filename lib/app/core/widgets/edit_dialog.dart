import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/validators.dart';

// Describes one field of the dialog form.
class FieldDef {
  final String key;
  final String label;
  final String initial;
  final bool required;
  final bool numeric;
  final int lines;
  final Map<String, String>? options; // if set, shows a dropdown (value -> label)

  /// Overrides the rule inferred from [numeric]/[required] when a field needs
  /// something specific - a phone number, an email, a long address.
  ///
  /// Left null the dialog infers a sensible rule, which covers the common
  /// "required text" and "positive number" cases without every call site
  /// spelling them out.
  final FormFieldValidator<String>? validator;

  const FieldDef(this.key, this.label,
      {this.initial = '',
      this.required = true,
      this.numeric = false,
      this.lines = 1,
      this.options,
      this.validator});

  /// The rule to apply, preferring an explicit [validator].
  FormFieldValidator<String> get effectiveValidator {
    if (validator != null) return validator!;
    // Explicitly optional fields stay optional, whatever the other flags say.
    if (!required) return AppValidators.optional();
    if (numeric) return AppValidators.positiveNumber(label: label);
    return AppValidators.text(minLength: 1, label: label);
  }
}

// Opens a validated form dialog. Returns the entered values, or null if cancelled.
Future<Map<String, String>?> showEditDialog(String title, List<FieldDef> fields) {
  return Get.dialog<Map<String, String>>(_EditDialog(title, fields));
}

class _EditDialog extends StatefulWidget {
  final String title;
  final List<FieldDef> fields;
  const _EditDialog(this.title, this.fields);

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _c = {
    for (final f in widget.fields) f.key: TextEditingController(text: f.initial),
  };

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _field(FieldDef f) {
    final controller = _c[f.key]!;
    if (f.options != null) {
      return DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: f.options!.containsKey(controller.text) ? controller.text : null,
        decoration: InputDecoration(labelText: f.label, border: const OutlineInputBorder()),
        items: f.options!.entries
            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: (v) => controller.text = v ?? '',
        validator: (v) => f.required && (v == null || v.isEmpty) ? 'Select ${f.label}' : null,
      );
    }
    return TextFormField(
      controller: controller,
      maxLines: f.lines,
      textInputAction:
          f.lines > 1 ? TextInputAction.newline : TextInputAction.next,
      keyboardType: f.numeric
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : null,
      decoration: InputDecoration(labelText: f.label, border: const OutlineInputBorder()),
      validator: f.effectiveValidator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          // Re-validate as the user types, so a mistake surfaces before Save is
          // pressed rather than all at once on submit.
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              for (final f in widget.fields)
                Padding(padding: const EdgeInsets.only(top: 12), child: _field(f)),
            ]),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Get.back(result: {for (final e in _c.entries) e.key: e.value.text.trim()});
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
