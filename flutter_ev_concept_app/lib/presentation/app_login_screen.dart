import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AppLoginScreen extends StatefulWidget {
  static const name = "AppLoginScreen";
  //final UsersRepository usersRepository;

  //yo debo recibir que???
  const AppLoginScreen({  super.key , 
                          //required this.usersRepository,
                        
                        });

  @override
  State<AppLoginScreen> createState() => _AppLoginScreenState();
}

class _AppLoginScreenState extends State<AppLoginScreen> {
  
  //late Future <List<User>> usersRequest;

  @override
  void initState(){
    super.initState();
    //usersRequest = widget.usersRepository.getUsers();
    isLogin();
  }

  void isLogin()async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool? isLogin = sp.getBool('isLoggedIn') ?? false;
    String? id = sp.getString('uid');

    if(isLogin){
      context.push('/app_home_screen/$id');
    }else{
      //me quedo aca
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return const Scaffold(
      resizeToAvoidBottomInset : false,
      body: _EvLoginView(),
    );
  }
}

class _EvLoginView extends StatefulWidget {
  
  //final List<User> usersList;
    
  const _EvLoginView();

  @override
  State<_EvLoginView> createState() => _EvLoginViewState();
}

class _EvLoginViewState extends State<_EvLoginView> {
  TextEditingController emailController = TextEditingController(text: '');
  TextEditingController passwordController = TextEditingController(text: '');
  bool isKeepSigned = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            "Email",
            style: TextStyle(fontSize: 16.0),
          ),
          _TextFieldUsernameView(controller: emailController),
          const Text(
            //PASARLO A ALGO CUSTOM
            "Contraseña",
            style: TextStyle(fontSize: 16.0),
          ),
          _TextFieldPasswordView(controller: passwordController),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Mantener sesión",
                style: TextStyle(fontSize: 16.0),
              ),
              Switch(
                value: isKeepSigned, 
                onChanged: (bool value) {
                  isKeepSigned = !isKeepSigned;
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          _LoginButton(
            onPressed_: tryLogin,
          ),
          
          const SizedBox(height: 10.0),
          InkWell(
            child: Text(
              'Crear una cuenta',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary, 
              ),
            ),
            
            onTap: () {
              //context.push('/sign_up_screen'); // Cambia a la ruta de tu pantalla de registro
              context.push('/signUp');
            },
          ),

        ],
      ),
    );
  }

  void showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    SnackBar snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void tryLogin (BuildContext context) async {

    if (emailController.text.isEmpty) {
      //handle empty email error
      showSnackBar('Email empty', context);
      return;
    } else if (passwordController.text.isEmpty) {
      //handle empty password error
      showSnackBar('Password empty', context);
      return;
    } 
    else {
      try {
        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Handle successful login (e.g., navigate to home screen)
        final user = userCredential.user!;
        if( isKeepSigned == true ){
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('uid', user.uid );
          await prefs.setBool('isLoggedIn', true);
        }
        context.push('/app_home_screen/${user.uid}');
      } on FirebaseAuthException catch (e) {
        if (e.code.toString() == 'invalid-email') {
          // Handle user not found error
          showSnackBar('Invalid email'+e.toString() , context);
        } else if (e.code.toString() == 'invalid-credential') {
          // Handle wrong password error
          showSnackBar('Invalid credential'+e.toString(), context);
        } else {
          // Handle other errors
          showSnackBar(e.toString(), context);
        }
      }
    }
  }
}

class _TextFieldUsernameView extends StatelessWidget {
  TextEditingController controller;
  _TextFieldUsernameView({required this.controller});

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

typedef LoginCallback = void Function(BuildContext context);

class _LoginButton extends StatelessWidget {
  final LoginCallback onPressed_;

  const _LoginButton({required this.onPressed_});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        icon: const Icon(Icons.login_outlined),
        onPressed: () => onPressed_(context),
        label: const Text('Ingresar'));
  }
}