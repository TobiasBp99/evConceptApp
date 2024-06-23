import 'package:flutter/material.dart';
import 'package:flutter_ev_concept_app/providers/ev_inside_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppInside extends ConsumerWidget {
  static const name = "AppInsideScreen";

  const AppInside({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insideState   = ref.watch(insideStateProvider);
    final tempSetPoint  = insideState.tempSetPoint.toDouble();
    final airSpeed      = insideState.airSpeed.toDouble();
    final tempHVAC      = insideState.tempHVAC;

    String imagePath = 'assets/images/interior.png'; // Imagen por defecto

    if (airSpeed == 0.0) {
      imagePath = 'assets/images/interior.png';
    } else {
      if (tempSetPoint >= 20.0) {
        imagePath = 'assets/images/warm_interior.png';
      } else {
        imagePath = 'assets/images/cool_interior.png';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interior y Comfort'),
      ),
      body: Column(
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            height: 150.0,
          ),
          const SizedBox(height: 20),
          // Cartel de temperatura HVAC
          const Text('Temperatura HVAC Actual'),
          Text('$tempHVAC°'),
          const SizedBox(height: 10),
          const Text('Temperatura'),
          const SizedBox(height: 10),
          Slider(
            value: tempSetPoint,
            min: 10.0,
            max: 30.0,
            divisions: 20,
            label: '${tempSetPoint.toStringAsFixed(1)}°C',
            onChanged: (double value) {
              ref.read(insideStateProvider.notifier).update((state) =>
                  state.copyWith(tempSetPoint: value ));
            },
            activeColor: tempSetPoint >= 20.0 ? Colors.red : Colors.blue,
            inactiveColor: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text('Velocidad de aire'),
          const SizedBox(height: 10),
          Slider(
            value: airSpeed,
            min: 0.0,
            max: 10.0,
            divisions: 10,
            label: airSpeed.toStringAsFixed(1),
            onChanged: (double value) {
              ref.read(insideStateProvider.notifier).update((state) =>
                  state.copyWith(airSpeed: value));
            },
            activeColor: Colors.green,
            inactiveColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}



/*
class AppInside extends StatefulWidget {
  static const name = "AppInsideScreen";

  const AppInside({super.key});

  @override
  State<AppInside> createState() => _AppInsideState();
}

class _AppInsideState extends State<AppInside> {
  double _temperature = 20.0;
  double _airSpeed = 0.0;

  @override
  Widget build(BuildContext context) {
    String imagePath = 'assets/images/interior.png'; // Imagen por defecto

    if(_airSpeed == 0.0){
      imagePath = 'assets/images/interior.png';
    }
    else{
      if( _temperature >= 20.0 ){
        imagePath = 'assets/images/warm_interior.png';
      }
      else{
        imagePath = 'assets/images/cool_interior.png';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interior y Comfort'),
      ),
      //body: _InteriorComfortView(),
      body: Column(
        children: [
          
          Image.asset(
            imagePath, 
            fit: BoxFit.cover,
            height: 150.0, 
          ),
          const SizedBox(height: 20),

          // Cartel de temperatura HVAC
          const Text('Temperatura HVAC Actual'),
          const Text('18°'),
          const SizedBox(height: 10),


          const Text('Temperatura'),
          const SizedBox(height: 10),
          Slider(
            value: _temperature,
            min: 10.0,
            max: 30.0,
            divisions: 20,
            label: '${_temperature.toStringAsFixed(1)}°C',
            onChanged: (double value) {
              setState(() {
                _temperature = value;
              });
            },
            activeColor: _temperature >= 20.0 ? Colors.red : Colors.blue,
            inactiveColor: Colors.grey,
          ),


          const SizedBox(height: 20),


          const Text('Velocidad de aire'),
          const SizedBox(height: 10),
          Slider(
            value: _airSpeed,
            min: 0.0,
            max: 10.0,
            divisions: 10,
            label: _airSpeed.toStringAsFixed(1),
            onChanged: (double value) {
              setState(() {
                _airSpeed = value;
              });
            },
            activeColor: Colors.green,
            inactiveColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}
*/