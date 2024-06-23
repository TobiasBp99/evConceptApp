import 'package:flutter/material.dart';
import 'package:flutter_ev_concept_app/providers/ev_battery_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBattery extends ConsumerWidget {
  static const name = "AppBattery";

  const AppBattery({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    /*
    final batteryLevel = ref.watch(batteryLevelProvider);
    final limitSet = ref.watch(limitSetProvider);
    final remainingKm = ref.watch(remainingKmProvider);
    final remainingMinutes = ref.watch(remainingMinutesProvider);
    */

    final battState = ref.watch(batteryStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batería y Carga'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 300,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[300],
              ),
              child: Stack(
                children: [
                  Container(
                    width: 300.0 * battState.batteryLevel,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.yellowAccent, Colors.cyan],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 300 * battState.limitSet - 1,
                    child: CustomPaint(
                      size: const Size(2, 50),
                      painter: DashedLinePainter(),
                    ),
                  ),
                  Positioned(
                    left: (300 * battState.batteryLevel) / 2 - 30,
                    top: 15,
                    child: Text(
                      'Limit set at ${(battState.limitSet * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${(battState.batteryLevel * 100).toInt()}% · ${battState.remainingKm}km',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${battState.remainingMinutes} minutos restantes',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            ListTile(
              leading : const Icon(Icons.thermostat),
              title   : const Text('Temperatura'),
              subtitle: const Text('Temperatura del pack'),
              trailing: Text('${battState.temperature}°C'),
            ),
            ListTile(
              leading : const Icon(Icons.battery_0_bar),
              title   : const Text('SOC'),
              subtitle: const Text('Estado de carga'),
              trailing: Text('${battState.soc}%'),
            ),
            ListTile(
              leading : const Icon(Icons.health_and_safety_rounded),
              title   : const Text('SOH'),
              subtitle: const Text('Estado de salud'),
              trailing: Text('${battState.soh}%'),
            ),
          ],
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 4, dashSpace = 4, startY = 0;
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter oldDelegate) => false;
}
