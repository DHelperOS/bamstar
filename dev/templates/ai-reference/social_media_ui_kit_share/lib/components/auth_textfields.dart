import 'package:flutter/material.dart';

class AuthTextfields {
  Widget buildTextField({
    required TextEditingController controller,
    String labelText = 'Email',
    Color focusColor = const Color(0xFF7B4DFF),
  }) {
    final focusNode = FocusNode();
    final isFocused = ValueNotifier<bool>(false);

    focusNode.addListener(() {
      isFocused.value = focusNode.hasFocus;
    });

    return ValueListenableBuilder<bool>(
      valueListenable: isFocused,
      builder: (context, focused, _) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            boxShadow:
                focused
                    ? [
                      BoxShadow(
                        color: focusColor.withValues(alpha: 0.15),
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
            keyboardType: TextInputType.emailAddress,
            obscureText: false,
            style: const TextStyle(fontSize: 16.0),
            decoration: InputDecoration(
              labelText: labelText,
              contentPadding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0),
              filled: true,
              fillColor: Colors.white,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: focusColor, width: 2.0),
              ),
              labelStyle: TextStyle(
                color: focused ? focusColor : Colors.grey.shade600,
                fontSize: 16.0,
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
    Color focusColor = const Color(0xFF7B4DFF),
  }) {
    final focusNode = FocusNode();
    final isFocused = ValueNotifier<bool>(false);
    final obscureNotifier = ValueNotifier<bool>(true); // <-- persistent state

    focusNode.addListener(() {
      isFocused.value = focusNode.hasFocus;
    });

    return ValueListenableBuilder<bool>(
      valueListenable: isFocused,
      builder: (context, focused, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: obscureNotifier,
          builder: (context, _obscureText, _) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                boxShadow:
                    focused
                        ? [
                          BoxShadow(
                            color: focusColor.withOpacity(0.15),
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
                obscureText: _obscureText,
                style: const TextStyle(fontSize: 16.0),
                decoration: InputDecoration(
                  labelText: labelText,
                  contentPadding: const EdgeInsets.fromLTRB(
                    15.0,
                    20.0,
                    15.0,
                    10.0,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: focusColor, width: 2.0),
                  ),
                  labelStyle: TextStyle(
                    color: focused ? focusColor : Colors.grey.shade600,
                    fontSize: 16.0,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.withOpacity(0.7),
                      ),
                      onPressed: () {
                        obscureNotifier.value = !obscureNotifier.value;
                      },
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
