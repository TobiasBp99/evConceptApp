import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';



class AppSignUpScreen extends StatefulWidget {
  static const name = "AppSignUp";
  const AppSignUpScreen({super.key});

  @override
  State<AppSignUpScreen> createState() => _AppSignUpScreenState();
}

class _AppSignUpScreenState extends State<AppSignUpScreen> {

  TextEditingController emailController = TextEditingController(text: '');
  TextEditingController passwordController = TextEditingController(text: '');

  void showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    SnackBar snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void signUpUser() async {
  
    if(emailController.text.isEmpty ){
      showSnackBar('Empty email',context);
      return;
    }
    if(passwordController.text.isEmpty ){
      showSnackBar('Empty password',context);
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Navegar a la pantalla de inicio de sesión después del registro
      context.push('/app_home_screen/${userCredential.user?.uid}');
      showSnackBar('User registered successfully!',context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar('The password provided is too weak.',context);
      } else if (e.code == 'email-already-in-use') {
        showSnackBar('The account already exists for that email.',context);
      } else if (e.code == 'invalid-email') {
        showSnackBar('The email address is not valid.',context);
      } else {
        showSnackBar('Error: ${e.message}',context);
      }
    } catch (e) {
      showSnackBar('Error: ${e.toString()}',context);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      body: Padding(
        padding: const EdgeInsets.only(
        top: 40.0,
        left: 20.0,
        right: 20.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Ev Concept App',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,    
            ),
          ),
          Image.asset('assets/images/logo.png',
            height: 150,
            width : 150,
          ),
          const SizedBox(height: 10.0),
          const Text(
            //PASARLO A ALGO CUSTOM
            "Ingresu su email",
            style: TextStyle(fontSize: 16.0),
          ),
          _TextFieldUsernameView(controller: emailController),
          const Text(
            //PASARLO A ALGO CUSTOM
            "Ingrese su contraseña",
            style: TextStyle(fontSize: 16.0),
          ),
          _TextFieldPasswordView(controller: passwordController),
          const SizedBox(height: 10.0),
          //
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            onPressed: signUpUser,
            label: const Text('Crear')
          ),
        ],
        ),
      ),
    );

  }

}

class _TextFieldUsernameView extends StatelessWidget {
  TextEditingController controller;
  _TextFieldUsernameView({ required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.person_2_rounded),
      ),
    );
  }
}

class _TextFieldPasswordView extends StatelessWidget {
  TextEditingController controller;
  _TextFieldPasswordView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.password),
      ),
      obscureText: true,
    );
  }
}