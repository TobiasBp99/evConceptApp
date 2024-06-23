import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ev_concept_app/core/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


//late AppDatabase appDB;
final FirebaseAuth auth = FirebaseAuth.instance;
var db = FirebaseFirestore.instance;

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

    runApp(ProviderScope(
      child: MainApp()
      )
    );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData( colorSchemeSeed: Colors.lightBlue),
    );
  }
}

