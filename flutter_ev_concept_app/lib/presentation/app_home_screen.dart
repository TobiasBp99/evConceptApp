import 'dart:io';
import 'package:flutter_ev_concept_app/core/app_router.dart';
import 'package:flutter_ev_concept_app/core/repositories/evs_repository.dart';
import 'package:flutter_ev_concept_app/entities/ev.dart';
import 'package:flutter_ev_concept_app/widgets/drawer_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';



class AppHomeScreen extends StatefulWidget {
  static const name = "AppHomeScreen";
  final String userId;
  final EvsRepository evsRepository;

  const AppHomeScreen({
    super.key,
    required this.userId,
    required this.evsRepository,
  });

  @override
  State<AppHomeScreen> createState() => _AppHomeScreenState();
}

class _AppHomeScreenState extends State<AppHomeScreen> {
  late Future<List<Ev>> evsRequest;
  late List<Ev> evsPrint;
  final scafoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    evsRequest = widget.evsRepository.getEvsByUserId(widget.userId);
    evsRequest.then((value) {
      evsPrint = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scafoldKey,
      appBar: AppBar(
        title: const Text('Mis Evs'),
      ),
      //body: _EvHomeView(),
      body: FutureBuilder(
          //esto me permite no usarlo como statefull, herramienta interna
          future: evsRequest,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData) {
              
              return (_EvHomeView(
                //evsList: snapshot.data!,
                evsList: evsPrint,
              ));

            } else {
              return (Text(snapshot.error.toString()));
            }
          })),
      drawer: DrawerHome(
        scafoldKey: scafoldKey,
        idUser: widget.userId,
      ),

      floatingActionButton: _EvHomeFAB(uid: widget.userId),
    );
  }
}

class _EvHomeFAB extends StatefulWidget {
  final String uid;

  const _EvHomeFAB({
    required this.uid,
  });

  @override
  State<_EvHomeFAB> createState() => _EvHomeFABState();
}

class _EvHomeFABState extends State<_EvHomeFAB> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FloatingActionButton(
      onPressed: () async {
        //await appDB.evDao.insertEv( Ev( idUser: userId ));
        final newEv = Ev(
          uidUser: widget.uid,
          model: '',
          patent: '',
          image: null,
        );

        //final newEvId = await appDB.evDao.insertEv(newEv);
        //final finDB = await appDB.evDao
        //    .findAllEvs();

        String newEvId = await evsRepository.insertEv(newEv);
        if (newEvId.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nuevo EV añadido con ID: $newEvId')),
        );

        // Actualiza la lista de EVs y navega a la pantalla correspondiente
        (context as Element).markNeedsBuild();
        context.push('/app_home_screen/${newEv.uidUser}/$newEvId');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir el nuevo EV')),
      );
      }
        

        // Actualiza la lista de EVs
        //(context as Element).markNeedsBuild();
        //context.push('/app_home_screen/${newEv.uidUser}/${newEvId}');


        
      },
      backgroundColor: colors.primary,
      shape: const CircleBorder(),
      child: const Icon(Icons.add),
    );
  }
}


class _EvHomeView extends StatelessWidget {
  final List<Ev> evsList;

  const _EvHomeView({
    required this.evsList,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: evsList.length,
        itemBuilder: (context, index) {
          final itemEv = evsList[index];

          return _EvItemView(ev: itemEv);
        });
  }
}

class _EvItemView extends StatelessWidget {
  final Ev ev;
  final String? evImage;
  const _EvItemView({required this.ev, this.evImage});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(

        leading: CircleAvatar(
          radius: 30,
          //backgroundImage: ev.image != null ? AssetImage(ev.image!) : null,
          backgroundImage: _getImageProvider(ev.image),
          child: ev.image == null ? const Icon(Icons.add_a_photo, size: 30) : null,
        ),

        title: Text(
          ev.model!,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(ev.patent!),
        trailing: const Icon(Icons.arrow_circle_right),
        onTap: () {
          context.push('/app_home_screen/${ev.uidUser}/${ev.id}');
        },
      ),
    );
  }

  ImageProvider? _getImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return null; // Sin imagen
    }

    if (imagePath.startsWith('assets/')) {
      try {
        // pruebo con asset
        return AssetImage(imagePath);
      } catch (e) {
        // manejo errores
        //print('Error cargando imagen desde assets: $e');
      }
    } else {
      try {
        // cargo desde archivos
        final file = File(imagePath);
        if (file.existsSync()) {
          return FileImage(file);
        }
      } catch (e) {
        // manejo archivos
        //print('Error cargando imagen desde el sistema de archivos: $e');
      }
    }

    return null; // Por defecto, sin imagen
  }

}