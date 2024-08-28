import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class _InfoLine extends StatelessWidget {
  final String label;
  final dynamic value;

  _InfoLine(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        Text(
          value is num
              ? NumberFormat.decimalPattern('fr').format(value)
              : value.toString(),
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
