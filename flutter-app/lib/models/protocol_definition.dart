import 'package:flutter/material.dart';

class ProtocolDefinition {
  final String plantClass;
  final String actionLabel;
  final Color indicatorColor;

  const ProtocolDefinition({
    required this.plantClass,
    required this.actionLabel,
    required this.indicatorColor,
  });

  static const List<ProtocolDefinition> all = [
    ProtocolDefinition(
      plantClass: 'Healthy',
      actionLabel: 'No action needed',
      indicatorColor: Colors.green,
    ),
    ProtocolDefinition(
      plantClass: 'Early_Blight',
      actionLabel: 'Disease detected — monitor closely',
      indicatorColor: Colors.orange,
    ),
    ProtocolDefinition(
      plantClass: 'Late_Blight',
      actionLabel: 'Severe disease — alert raised',
      indicatorColor: Colors.red,
    ),
    ProtocolDefinition(
      plantClass: 'Unknown',
      actionLabel: 'Low confidence — needs review',
      indicatorColor: Colors.grey,
    ),
  ];

  static ProtocolDefinition? forClass(String className) {
    try {
      return all.firstWhere((d) => d.plantClass == className);
    } catch (_) {
      return null;
    }
  }
}
