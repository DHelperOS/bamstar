import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;
  final Color? activeThumbColor;
  final Color? activeTrackColor;
  final Color? inactiveThumbColor;
  final Color? inactiveTrackColor;
  final double? splashRadius;

  const CustomSwitch({
    Key? key,
    this.initialValue = false,
    this.onChanged,
    this.activeThumbColor,
    this.activeTrackColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.splashRadius = 18,
  }) : super(key: key);

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  late bool _isOn;

  @override
  void initState() {
    super.initState();
    _isOn = widget.initialValue;
  }

  @override
  void didUpdateWidget(CustomSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _isOn = widget.initialValue;
    }
  }

  void _handleChanged(bool value) {
    setState(() {
      _isOn = value;
    });

    // Call the external callback if provided
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Switch(
      value: _isOn,
      splashRadius: widget.splashRadius,
      onChanged: _handleChanged,
      activeColor:
          widget.activeThumbColor ?? Colors.white, // Active thumb color
      activeTrackColor:
          widget.activeTrackColor ?? primaryColor, // Active track color
      inactiveThumbColor:
          widget.inactiveThumbColor ?? Colors.grey, // Inactive thumb color
      inactiveTrackColor:
          widget.inactiveTrackColor ?? Colors.grey[300], // Inactive track color
    );
  }
}
