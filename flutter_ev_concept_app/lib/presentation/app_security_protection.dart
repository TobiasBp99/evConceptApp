import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ev_concept_app/presentation/app_bt_screen.dart';

class AppSecurity extends StatefulWidget {
  static const name = "AppSecurity";

  const AppSecurity({super.key});

  @override
  State<AppSecurity> createState() => _AppSecurityState();
}

class _AppSecurityState extends State<AppSecurity> {

  bool _isLocked = false;
  //late BluetoothDevice _device;
  final Guid _characteristicUUID = Guid('FAFA');

  void toggleLock() async {
    setState(() {
      _isLocked = !_isLocked;
    });

    // The value to write to the characteristic, e.g., "locked" or "unlocked"
    List<int> value = (_isLocked ? "LOCKED" : "UNLOCKED").codeUnits + [0];

    
    List<BluetoothService> services = await deviceGlobal.discoverServices();
    services.forEach((service) async {
    // do something with service

    // Reads all characteristics
    var characteristics = service.characteristics;
    for(BluetoothCharacteristic c in characteristics) {

        if (c.uuid == _characteristicUUID ){
          await c.write(value);
        }

    }
    });

  }

  @override
  Widget build(BuildContext context) {

    String imagePath = 'assets/images/car_unlocked.png'; // Imagen por defecto

    if( _isLocked == true ){
      imagePath = 'assets/images/car_locked.png';
    }
    else{
      imagePath = 'assets/images/car_unlocked.png';
    }


    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguridad y Protección'),
      ),
      body: Center(
        child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          
              Image.asset(
                imagePath, 
                fit: BoxFit.cover,
                height: 150.0, 
              ),
              const SizedBox(height: 20),
          
              ElevatedButton.icon(
                onPressed: toggleLock,
                icon: Icon(_isLocked ? Icons.lock : Icons.lock_open),
                label: Text(_isLocked ? 'Bloqueado' : 'Desbloqueado'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}