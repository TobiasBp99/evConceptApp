import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ev_concept_app/providers/ev_battery_provider.dart';
import 'package:flutter_ev_concept_app/providers/ev_inside_provider.dart';
import 'package:flutter_ev_concept_app/widgets/drawer_home_screen.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

late BluetoothDevice deviceGlobal;

class AppBtScreen extends ConsumerStatefulWidget {
  static const name = "AppBtScreen";
  final String userId;

  const AppBtScreen({super.key,required this.userId});

  @override
  ConsumerState<AppBtScreen> createState() => _AppBtScreenState();
}

class _AppBtScreenState extends ConsumerState<AppBtScreen> {
  bool _bt = false;
  List<BluetoothDevice> devices = [];
  Timer? _timer;
  final scafoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
    if (_bt) {
      startScanning();
    }
  }

  Future<void> _checkBluetoothState() async {
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
      setState(() {
        _bt = true;
        startScanning();
      });
    }
  }

  void startScanning() async {
    await FlutterBluePlus.startScan();
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devices.contains(result.device)) {
          setState(() {
            devices.add(result.device);
          });
        }
      }
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    deviceGlobal = device;
    await device.connect();
    _startReadingCharacteristic(device);
  }

  void _startReadingCharacteristic(BluetoothDevice device) {
    List<Guid> characteristicIds = [
      Guid('BA77'), // Reemplaza con tu UUID de característica de batería
      Guid('F0F0') // Reemplaza con tu UUID de característica de interior
    ];
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      readCharacteristics(device, characteristicIds);
    });
  }

/*
  BatteryState parseCharacteristicValue(List<int> value) {
  String dataString = String.fromCharCodes(value);
  Map<String, dynamic> dataMap = {};

  RegExp regExp = RegExp(r'<(\w+)=([\d.]+)>');
  Iterable<Match> matches = regExp.allMatches(dataString);

  for (Match match in matches) {
    String key = match.group(1)!;
    String rawValue = match.group(2)!;
    double value = double.tryParse(rawValue) ?? 0.0;

    if (key == 'batteryLevel' || key == 'limitSet') {
      dataMap[key] = value;
    } else {
      dataMap[key] = int.tryParse(rawValue) ?? 0;
    }
  }

  return BatteryState(
    batteryLevel: dataMap['batteryLevel'] ?? 0.0,
    limitSet: dataMap['limitSet'] ?? 0.0,
    remainingKm: dataMap['remainingKm'] ?? 0,
    remainingMinutes: dataMap['remainingMinutes'] ?? 0,
    temperature: dataMap['temperature'] ?? 0,
    soc: dataMap['soc'] ?? 0,
    soh: dataMap['soh'] ?? 0,
  );
}
*/
void readCharacteristics(BluetoothDevice device, List<Guid> characteristicIds) async {
  List<BluetoothService> services = await device.discoverServices();

  for (BluetoothService service in services) {
    for (BluetoothCharacteristic characteristic in service.characteristics) {
      if (characteristicIds.contains(characteristic.uuid)) {
        List<int> value = await characteristic.read();
        //print('Read value from ${characteristic.uuid}: $value');

        // Parse the characteristic value
        var parsedValues = parseCharacteristicValue(value);

        // Update the battery provider with the parsed values
        if (parsedValues['type'] == 'batteryState') {
          BatteryState newState = parsedValues['state'];
          ref.read(batteryStateProvider.notifier).update((state) => state.copyWith(
            batteryLevel    : newState.batteryLevel    ,
            limitSet        : newState.limitSet        ,
            remainingKm     : newState.remainingKm     ,
            remainingMinutes: newState.remainingMinutes,
            temperature     : newState.temperature     ,
            soc             : newState.soc             ,
            soh             : newState.soh             ,
          ));
        }

        // Update the inside state provider with the parsed values
        if (parsedValues['type'] == 'insideState') {
          InsideState newState = parsedValues['state'];
          ref.read(insideStateProvider.notifier).update((state) => state.copyWith(
            tempSetPoint: newState.tempSetPoint ,
            airSpeed    : newState.airSpeed     ,
            tempHVAC    : newState.tempHVAC     ,
          ));
        }
      }
    }
  }
}

Map<String, dynamic> parseCharacteristicValue(List<int> value) {
  // Assume value is a string like '<batteryLevel=0.50><limitSet=0.95><remainingKm=1000><remainingMinutes=1000>'
  String stringValue = String.fromCharCodes(value);
  RegExp regExp = RegExp(r'<(.*?)=(.*?)>');
  Iterable<Match> matches = regExp.allMatches(stringValue);

  Map<String, double> batteryValues = {};
  Map<String, double> insideValues = {};

  for (Match match in matches) {
    String key = match.group(1)!;
    String val = match.group(2)!;

    switch (key) {
      case 'batteryLevel':
      case 'limitSet':
      case 'remainingKm':
      case 'remainingMinutes':
      case 'temperature':
      case 'soc':
      case 'soh':
        batteryValues[key] = double.parse(val);
        break;
      case 'tempSetPoint':
      case 'airSpeed':
      case 'tempHVAC':
        insideValues[key] = double.parse(val);
        break;
    }
  }

  if (batteryValues.isNotEmpty) {
    BatteryState batteryState = BatteryState(
      batteryLevel    : batteryValues['batteryLevel'] ?? 0.0,
      limitSet        : batteryValues['limitSet'] ?? 0.0,
      remainingKm     : batteryValues['remainingKm']?.toInt() ?? 0,
      remainingMinutes: batteryValues['remainingMinutes']?.toInt() ?? 0,
      temperature     : batteryValues['temperature']?.toInt() ?? 0,
      soc             : batteryValues['soc']?.toInt() ?? 0,
      soh             : batteryValues['soh']?.toInt() ?? 0,
    );

    return {
      'type': 'batteryState',
      'state': batteryState,
    };
  }

  if (insideValues.isNotEmpty) {
    InsideState insideState = InsideState(
      tempSetPoint: insideValues['tempSetPoint'] ?? 20,
      airSpeed    : insideValues['airSpeed'] ?? 0,
      tempHVAC    : insideValues['tempHVAC'] ?? 18,
    );

    return {
      'type': 'insideState',
      'state': insideState,
    };
  }

  return {};
}


  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    _timer?.cancel(); // Cancela el timer al desmontar la pantalla.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth'),
      ),
      drawer: DrawerHome(
        scafoldKey: scafoldKey,
        idUser: widget.userId,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SwitchListTile(
            title: const Text('Bluetooth'),
            value: _bt,
            onChanged: (bool value) {
              setState(() {
                _bt = value;
                if (_bt) {
                  startScanning();
                } else {
                  FlutterBluePlus.stopScan();
                  _timer?.cancel();
                  devices.clear();
                }
              });
            },
            secondary: Icon(_bt ? Icons.bluetooth_connected : Icons.bluetooth_disabled),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devices[index].platformName),
                  subtitle: Text(devices[index].remoteId.toString()),
                  onTap: () => connectToDevice(devices[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


          

/*
class AppBtScreen extends StatelessWidget {
  static const name = "AppBtScreen";
  
  const AppBtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth'),
      ),
      body: const _BtView(),
    );
  }
}

class _BtView extends StatefulWidget {
  const _BtView({super.key});

  @override
  State<_BtView> createState() => _BtViewState();
}

class _BtViewState extends State<_BtView> {
  bool _bt = false;
  List<BluetoothDevice> devices = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
    if (_bt) {
      startScanning();
    }
  }

  Future<void> _checkBluetoothState() async {
    
    //para ios creo que no hace falta
    //puede que no este bien hacer el starscanning ahora
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
      setState(() {
        _bt = true;
        startScanning();
      });
  }

  }

  void startScanning() async {
    await FlutterBluePlus.startScan();
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devices.contains(result.device)) {
          setState(() {
            devices.add(result.device);
          });
        }
      }
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    _startReadingCharacteristic(device);
  }

  void _startReadingCharacteristic(BluetoothDevice device) {
    var characteristicId = Guid('BA77'); // Reemplaza con tu UUID de característica
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      readCharacteristic(device, characteristicId);
    });
  }

  void readCharacteristic(BluetoothDevice device, Guid characteristicId) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid == characteristicId) {
          List<int> value = await characteristic.read();
          //print('Read value: $value');


          
          // Accessing the read method from WidgetRef
          // // Assuming you're inside a widget

          // Update the entire state
          ref.watch(batteryStateProvider.notifier).update((state) => state.copyWith(
            batteryLevel      : 0.90,
            limitSet          : 0.90, 
            remainingKm       : 80  ,
            remainingMinutes  : 80  ,
            temperature       : 80  ,
            soc               : 80  ,
            soh               : 80  ,
            
          ));
                  }
      }
    }
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    _timer?.cancel(); // Cancela el timer al desmontar la pantalla.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SwitchListTile(
          title: const Text('Bluetooth'),
          value: _bt,
          onChanged: (bool value) {
            setState(() {
              _bt = value;
              if (_bt) {
                startScanning();
              } else {
                FlutterBluePlus.stopScan();
                _timer?.cancel();
                devices.clear();
              }
            });
          },
          secondary: Icon(_bt ? Icons.bluetooth_connected : Icons.bluetooth_disabled),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(devices[index].platformName),
                subtitle: Text(devices[index].remoteId.toString()),
                onTap: () => connectToDevice(devices[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
*/

/*
class BleScanner extends StatefulWidget {
  @override
  _BleScannerState createState() => _BleScannerState();
}
class _BleScannerState extends State<BleScanner> {

  List<BluetoothDevice> devices = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startScanning();
  }

  void startScanning() async {
    await FlutterBluePlus.startScan();
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!devices.contains(result.device)) {
          setState(() {
            devices.add(result.device);
          });
        }
      }
    });
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
    // Una vez conectado, configura el timer para leer la característica cada segundo.
    _startReadingCharacteristic(device);
  }

  void _startReadingCharacteristic(BluetoothDevice device) {
    var characteristicId = Guid('BA77'); // Reemplaza con tu UUID de característica
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      readCharacteristic(device, characteristicId);
    });
  }

  void readCharacteristic(BluetoothDevice device, Guid characteristicId) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid == characteristicId) {
          List<int> value = await characteristic.read();
          print('Read value: $value');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(devices[index].platformName),
            subtitle: Text(devices[index].remoteId.toString()),
            onTap: () => connectToDevice(devices[index]),
          );
        },
      );
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    _timer?.cancel(); // Cancela el timer al desmontar la pantalla.
    super.dispose();
  }
}
*/





/*
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_ev_concept_app/presentation/app_bt_off_screen.dart';

import 'package:flutter_ev_concept_app/screens/scan_screen.dart';

class AppBtnScreen extends StatefulWidget {
  static const name = "AppBtScreen"; 
  const AppBtnScreen({Key? key}) : super(key: key);

  @override
  State<AppBtnScreen> createState() => _AppBtnScreen();
}

class _AppBtnScreen extends State<AppBtnScreen> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = _adapterState == BluetoothAdapterState.on
        ? const ScanScreen()
        : BluetoothOffScreen(adapterState: _adapterState);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //color: Colors.lightBlue,
      theme: ThemeData( colorSchemeSeed: Colors.lightBlue),
      home: screen,
      navigatorObservers: [BluetoothAdapterStateObserver()],
    );
  }
}

//
// This observer listens for Bluetooth Off and dismisses the DeviceScreen
//
class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      // Start listening to Bluetooth state changes when a new route is pushed
      _adapterStateSubscription ??= FlutterBluePlus.adapterState.listen((state) {
        if (state != BluetoothAdapterState.on) {
          // Pop the current route if Bluetooth is off
          navigator?.pop();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // Cancel the subscription when the route is popped
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}
*/
