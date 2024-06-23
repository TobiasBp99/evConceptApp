import 'package:flutter_riverpod/flutter_riverpod.dart';

// Class containing battery data
class BatteryState {
  final double batteryLevel;
  final double limitSet;
  final int remainingKm;
  final int remainingMinutes;
  final int temperature;
  final int soc; // State of Charge
  final int soh; // State of Health

  BatteryState({
    required this.batteryLevel,
    required this.limitSet,
    required this.remainingKm,
    required this.remainingMinutes,
    required this.temperature,
    required this.soc,
    required this.soh,
  });

  // Update specific values (optional)
  BatteryState copyWith({
    double? batteryLevel,
    double? limitSet,
    int? remainingKm,
    int? remainingMinutes,
    int? temperature,
    int? soc,
    int? soh,
  }) {
    return BatteryState(
      batteryLevel: batteryLevel ?? this.batteryLevel,
      limitSet: limitSet ?? this.limitSet,
      remainingKm: remainingKm ?? this.remainingKm,
      remainingMinutes: remainingMinutes ?? this.remainingMinutes,
      temperature: temperature ?? this.temperature,
      soc: soc ?? this.soc,
      soh: soh ?? this.soh,
    );
  }
}

// StateProvider for managing BatteryState
var batteryStateProvider = StateProvider<BatteryState>((ref) {
  // Initial values (replace with actual data fetching logic)
  return BatteryState(
    batteryLevel: 0.75, // Between 0.0 and 1.0
    limitSet: 0.20, // Between 0.0 and 1.0 for low battery limit
    remainingKm: 100, // Estimated remaining distance in kilometers
    remainingMinutes: 120, // Estimated remaining battery time in minutes
    temperature: 25, // Battery temperature in degrees Celsius
    soc: 85, // State of Charge (percentage)
    soh: 90, // State of Health (percentage)
  );
});


// Example usage in a widget:
/*
class BatteryManager extends ConsumerWidget {
  const BatteryManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryState = ref.watch(batteryStateProvider);
    // Use the batteryValues object for further processing or logic
    // You can use these values in calculations, display them later, etc.
    return const Placeholder(); // Empty container, as we only need values
  }
}
*/