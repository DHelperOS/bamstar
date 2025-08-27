import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// app_theme import removed to avoid analyzer issues when package roots vary.
import '../theme/app_text_styles.dart';

/// Formats Korean-style phone numbers as the user types.
/// Examples:
/// 01012345678 -> 010-1234-5678
/// 021234567 -> 02-1234-567 (best-effort grouping)
class PhoneNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    String formatted;
    if (digits.length <= 3) {
      formatted = digits;
    } else if (digits.length <= 7) {
      formatted = digits.replaceFirstMapped(
        RegExp(r'^(\d{3})(\d+)'),
        (m) => '${m.group(1)}-${m.group(2)}',
      );
    } else {
      // 3-4-... grouping (max 11 digits -> 3-4-4)
      formatted = digits.replaceFirstMapped(RegExp(r'^(\d{3})(\d{4})(\d*)'), (
        m,
      ) {
        final tail = m.group(3) ?? '';
        return tail.isEmpty
            ? '${m.group(1)}-${m.group(2)}'
            : '${m.group(1)}-${m.group(2)}-$tail';
      });
    }

    // maintain selection at end
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class AuthTextfields {
  const AuthTextfields();

  Color? _lookupFocusColor(BuildContext? context) {
    if (context == null) return null;
    final exts = Theme.of(context).extensions.values;
    for (final e in exts) {
      if (e.runtimeType.toString() == 'AppExtras') {
        try {
          return (e as dynamic).focusColor as Color?;
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  Widget buildTextField({
    required TextEditingController controller,
    String labelText = 'Email',
    Color? focusColor,
    BuildContext? context,
    TextInputType keyboardType = TextInputType.emailAddress,
    List<TextInputFormatter>? inputFormatters,
    bool autofocus = false,
    String? hintText,
    Widget? prefixIcon,
  }) {
    final effectiveFocusColor =
        focusColor ??
        (context != null
            ? _lookupFocusColor(context) ??
                  Theme.of(context).colorScheme.secondary
            : const Color(0xFF7B4DFF));
    final focusNode = FocusNode();
    final isFocused = ValueNotifier<bool>(false);

    focusNode.addListener(() => isFocused.value = focusNode.hasFocus);

    return ValueListenableBuilder<bool>(
      valueListenable: isFocused,
      builder: (context, focused, _) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: focused
                ? [
                    BoxShadow(
                      color: effectiveFocusColor.withValues(alpha: 0.15),
                      blurRadius: 15.0,
                      spreadRadius: 5.0,
                      offset: const Offset(0, 0),
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            autofocus: autofocus,
            obscureText: false,
            style: AppTextStyles.inputText(context),
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText,
              prefixIcon: prefixIcon,
              contentPadding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: effectiveFocusColor, width: 2.0),
              ),
              labelStyle: AppTextStyles.inputLabel(context).copyWith(
                color: focused ? effectiveFocusColor : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildPasswordField({
    required TextEditingController controller,
    String labelText = 'Password',
    Color? focusColor,
    BuildContext? context,
  }) {
    final effectiveFocusColor =
        focusColor ??
        (context != null
            ? _lookupFocusColor(context) ??
                  Theme.of(context).colorScheme.secondary
            : const Color(0xFF7B4DFF));
    final focusNode = FocusNode();
    final isFocused = ValueNotifier<bool>(false);
    final obscureNotifier = ValueNotifier<bool>(true);

    focusNode.addListener(() => isFocused.value = focusNode.hasFocus);

    return ValueListenableBuilder<bool>(
      valueListenable: isFocused,
      builder: (context, focused, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: obscureNotifier,
          builder: (context, obscureText, _) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: focused
                    ? [
                        BoxShadow(
                          color: effectiveFocusColor.withValues(alpha: 0.15),
                          blurRadius: 15.0,
                          spreadRadius: 5.0,
                          offset: const Offset(0, 0),
                        ),
                      ]
                    : [],
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.text,
                obscureText: obscureText,
                style: AppTextStyles.inputText(context),
                decoration: InputDecoration(
                  labelText: labelText,
                  contentPadding: const EdgeInsets.fromLTRB(
                    15.0,
                    20.0,
                    15.0,
                    10.0,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: effectiveFocusColor,
                      width: 2.0,
                    ),
                  ),
                  labelStyle: AppTextStyles.inputLabel(context).copyWith(
                    color: focused ? effectiveFocusColor : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      onPressed: () =>
                          obscureNotifier.value = !obscureNotifier.value,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
