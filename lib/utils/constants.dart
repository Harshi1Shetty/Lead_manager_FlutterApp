import 'package:flutter/material.dart';

const List<String> leadStatuses = ['New', 'Contacted', 'Converted', 'Lost'];

Color getStatusColor(String status) {
  switch (status) {
    case 'New':
      return Colors.blue;
    case 'Contacted':
      return Colors.orange;
    case 'Converted':
      return Colors.green;
    case 'Lost':
      return Colors.red;
    default:
      return Colors.grey;
  }
}