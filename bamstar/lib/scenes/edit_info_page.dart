import 'package:flutter/material.dart';
import 'package:bamstar/theme/typography.dart';

class EditInfoPage extends StatefulWidget {
  final String title;
  final Map<String, String> fields;

  const EditInfoPage({super.key, required this.title, required this.fields});

  @override
  State<EditInfoPage> createState() => _EditInfoPageState();
}

class _EditInfoPageState extends State<EditInfoPage> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final e in widget.fields.entries)
        e.key: TextEditingController(text: e.value),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final result = _controllers.map((k, v) => MapEntry(k, v.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '저장 완료: ${result.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
        ),
      ),
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: context.h2),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: _controllers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, idx) {
                    final key = _controllers.keys.elementAt(idx);
                    final controller = _controllers[key]!;
                    return TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: key,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _save,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                  child: Text('저장', style: context.buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
