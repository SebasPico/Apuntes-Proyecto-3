import 'package:flutter/material.dart';

class EspacioIcons {
  static const Map<String, IconData> all = {
    'kitchen': Icons.restaurant_rounded,
    'bathroom': Icons.water_drop_rounded,
    'laundry': Icons.local_laundry_service_rounded,
    'bedroom': Icons.bed_rounded,
    'storage': Icons.inventory_2_rounded,
    'home': Icons.home_work_rounded,
  };

  static IconData forKey(String key) => all[key] ?? Icons.home_work_rounded;
}
