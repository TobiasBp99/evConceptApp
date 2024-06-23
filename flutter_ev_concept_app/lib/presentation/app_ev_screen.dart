import 'dart:io';
import 'package:flutter_ev_concept_app/core/app_router.dart';
import 'package:flutter_ev_concept_app/core/repositories/evs_repository_local.dart';
import 'package:flutter_ev_concept_app/entities/ev.dart';
import 'package:flutter_ev_concept_app/main.dart';
import 'package:flutter_ev_concept_app/providers/ev_battery_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_ev_concept_app/widgets/drawer_home_screen.dart';


class AppEvScreen extends StatefulWidget {
  static const String name = 'AppEvScreen';
  final String id;

  const AppEvScreen({
    super.key,
    required this.id,
  });

  @override
  State<AppEvScreen> createState() => _AppEvScreenState();
}

class _AppEvScreenState extends State<AppEvScreen> {
  late Future<Ev?> evToPrint;

  late Ev evPrint;
  double _batteryMeasure = 0.1;
  final scafoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    evToPrint = LocalEvsRepository().getEvById(widget.id);
    evToPrint.then((value) {
      evPrint = value!;
      setState(() {});
    });
  }

  Future<void> _addImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      //debería cambiar las cosas en mi dao entiendo

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(image.path);
      final String savedImagePath = path.join(appDir.path, fileName);

      final File savedImage = await File(image.path)
          .copy(savedImagePath); // copio imagen al directorio

      // Actualiza el EV con la nueva ruta de la imagen
      //evPrint.image = savedImage.path;
      //await appDB.evDao.updateEvImageById(evPrint.id!, savedImage.path);
      await evsRepository.updateEvImageById(evPrint.id!, savedImage.path);
      (context as Element).markNeedsBuild();

      //setState(() {});
      evToPrint = LocalEvsRepository().getEvById(widget.id);
      
      evToPrint.then((value) {
      if (value != null) {
        setState(() {
          evPrint = value;
        });
      }
      }
      );

      // Mostrar confirmación y guardar la ruta de la imagen para usarla
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen guardada: ')),
      );

      // Ahora puedes usar 'imagePath' para referenciar la imagen guardada
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se seleccionó ninguna imagen')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle Ev'),
      ),
      resizeToAvoidBottomInset: false, //saca el error de overflow

      //body: _EvDetailView(patent: patent),
      body: FutureBuilder(
        
          future: evToPrint,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData) {

              return (Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading:
                                    const Icon(Icons.assignment_ind_outlined),
                                title: const Text(
                                  'Patente',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text(evPrint.patent!),
                                trailing: ElevatedButton.icon(
                                  onPressed: () {
                                    showEditEvDialog(
                                        context, evPrint, 'patente');
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Editar'),
                                ),
                              ),
                              const Divider(height: 0),
                              ListTile(
                                leading: const Icon(Icons.car_repair),
                                title: const Text(
                                  'Modelo',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text(evPrint.model!),
                                trailing: ElevatedButton.icon(
                                  onPressed: () {
                                    showEditEvDialog(
                                        context, evPrint, 'modelo');
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Editar'),
                                ),
                              ),
                              const Divider(height: 0),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FloatingActionButton(
                                onPressed: () async {

                                  //await appDB.evDao.deleteEvById(evPrint.id!);
                                  await evsRepository.deleteEvById(evPrint.id!);
                                  context.push('/app_home_screen/${evPrint.uidUser}');
                                },
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child:
                                    const Icon(Icons.delete_outline_outlined),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      width: 60,
                    ),
                    evPrint.image != null
                        ? SizedBox(
                            height: 150, // Alto fijo
                            child: _buildImageWidget(evPrint.image),
                            /*
                            Image.asset(
                              evPrint.image!, // Ruta de tu imagen
                              fit: BoxFit.cover, // Para ajustar la imagen al tamaño
                            ),
                            */
                          )
                        : ElevatedButton.icon(
                            onPressed: () {
                              _addImage(context);
                              //setState(() {});
                            },
                            label: const Text('Tomar imagen'),
                            icon: const Icon(Icons.add_a_photo),
                          ),

                    const SizedBox(height: 5),
                    // Nivel de batería
                    _BatteryLevelIndicator(
                      //batteryLevel: _batteryMeasure,
                    ),
                    const SizedBox(height: 5),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ColoredButton(
                              color:
                                  const Color.fromARGB(0xFF, 0xF1, 0xE9, 0xD4),
                              imagePath: 'assets/images/battery.png',
                              text: 'Carga y Batería',
                              userId: evPrint.uidUser.toString(),
                              evId: evPrint.id!,
                            ),
                            const SizedBox(width: 10),
                            _ColoredButton(
                              color:
                                  const Color.fromARGB(0xFF, 0xFF, 0xEF, 0xEF),
                              imagePath: 'assets/images/comfort.png',
                              text: 'Interior y Comfort',
                              //userId: evPrint.uidUser!,
                              userId: evPrint.uidUser.toString(),
                              evId: evPrint.id!,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ColoredButton(
                              color:
                                  const Color.fromARGB(0xFF, 0xD4, 0xF1, 0xD7),
                              imagePath: 'assets/images/safety.png',
                              text: 'Seguridad y Protección',
                              //userId: evPrint.uidUser!,
                              userId: evPrint.uidUser.toString(),
                              evId: evPrint.id!,
                            ),
                            const SizedBox(width: 10),
                            _ColoredButton(
                              color:
                                  const Color.fromARGB(0xFF, 0xD4, 0xDC, 0xF1),
                              imagePath: 'assets/images/ligths.png',
                              text: 'Iluminación',
                              userId: evPrint.uidUser.toString(),
                              //userId: evPrint.uidUser!,
                              evId: evPrint.id!,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ));
            } else {
              return (Text(snapshot.error.toString()));
            }
          })),

/*
drawer: DrawerHome(
        scafoldKey: scafoldKey,
        idUser: evPrint.idUser!,
      ),
  */ 
  
      drawer: FutureBuilder<Ev?>(
        //future: evToPrint = LocalEvsRepository().getEvById('1'),
        future: evToPrint,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          } else if (snapshot.hasData) {
            return DrawerHome(
              scafoldKey: scafoldKey,
              idUser: snapshot.data!.uidUser,
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildImageWidget(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        color: Colors.grey,
        child: const Icon(Icons.photo, size: 50),
      );
    }

    if (imagePath.startsWith('assets/')) {
      try {
        // pruebo cargar desde assets
        return Image.asset(
          imagePath,
          fit: BoxFit.cover,
        );
      } catch (e) {
        // manejo los errores
        //print('Error cargando imagen desde assets: $e');
      }
    } else {
      try {
        // la cargo como imagen
        final file = File(imagePath);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
          );
        }
      } catch (e) {
        // manejo los errores
        //print('Error cargando imagen desde el sistema de archivos: $e');
      }
    }

    return Container(
      color: Colors.grey,
      child: const Icon(Icons.photo, size: 50),
    ); // Widget de fallback si no se pudo cargar la imagen
  }

  void showEditEvDialog(BuildContext context, Ev ev, String field) async {
    String newValue = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar $field'),
          content: TextField(
            onChanged: (value) {
              newValue = value;
            },
            decoration: InputDecoration(
              hintText: 'Ingrese $field',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                if (field == 'patente') {
                  //await appDB.evDao.updateEvPatentById(ev.id!, newValue);
                  await evsRepository.updateEvPatentById(ev.id!, newValue);
                  (context as Element).markNeedsBuild();
                
                } else if (field == 'modelo') {
                  //await appDB.evDao.updateEvModelById(ev.id!, newValue);
                  await evsRepository.updateEvPatentById(ev.id!, newValue);
                  (context as Element).markNeedsBuild();
                }

                evToPrint = LocalEvsRepository().getEvById(widget.id);
                evToPrint.then((value) {
                  evPrint = value!;
                  setState(() {});
                });

                //context.pop();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

class _ColoredButton extends StatelessWidget {
  final Color color;
  final String imagePath;
  final String text;
  final String userId;
  final String evId;

  const _ColoredButton(
      {required this.color,
      required this.imagePath,
      required this.text,
      required this.userId,
      required this.evId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Acción del botón

        if (text == 'Interior y Comfort') {
          context.push('/app_home_screen/$userId/$evId/inside');
        }
        if (text == 'Seguridad y Protección') {
          context.push('/app_home_screen/$userId/$evId/security');
        }
        if (text == 'Carga y Batería') {
          context.push('/app_home_screen/$userId/$evId/battery');
        }
        /*
        if(text == 'Interior y Comfort'){
          context.push('/app_home_screen/${userId}/${evId}/inside');
        }
        */
      },
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: Colors.grey.shade700,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              child: Image.asset(
                imagePath,
                width: 120,
                height: 120,
              ),
            ),
            Positioned(
              top: 5,
              left: 5,
              child: SizedBox(
                width: 130,
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BatteryLevelIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteryLevel = ref.watch(batteryStateProvider).batteryLevel;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: LinearProgressIndicator(
            value: batteryLevel,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              batteryLevel <= 0.25 || batteryLevel >= 0.75
                  ? Colors.cyan
                  : Colors.orange,
            ),
            minHeight: 20,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Nivel de batería: ${(batteryLevel * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          batteryLevel <= 0.25
              ? 'Batería baja'
              : batteryLevel >= 0.75
                  ? 'Batería alta'
                  : '',
          style: TextStyle(
            fontSize: 14,
            color: batteryLevel <= 0.25 || batteryLevel >= 0.75
                  ? Colors.cyan
                  : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
