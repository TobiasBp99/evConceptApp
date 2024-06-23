
import 'package:flutter_ev_concept_app/core/repositories/evs_repository.dart';
import 'package:flutter_ev_concept_app/core/repositories/evs_repository_local.dart';
import 'package:flutter_ev_concept_app/core/repositories/users_repository.dart';
import 'package:flutter_ev_concept_app/core/repositories/users_repository_local.dart';
import 'package:flutter_ev_concept_app/presentation/app_bt_screen.dart';
import 'package:flutter_ev_concept_app/presentation/app_charge_battery_screen.dart';
import 'package:flutter_ev_concept_app/presentation/app_signUp_screen.dart';
import 'package:flutter_ev_concept_app/presentation/app_ev_screen.dart';
import 'package:flutter_ev_concept_app/presentation/app_home_screen.dart';
import 'package:flutter_ev_concept_app/presentation/app_inside.dart';
import 'package:flutter_ev_concept_app/presentation/app_login_screen.dart';
import 'package:flutter_ev_concept_app/presentation/app_security_protection.dart';
import 'package:go_router/go_router.dart';

final UsersRepository userRepository = LocalUsersRepository();
final EvsRepository evsRepository = LocalEvsRepository();

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name:AppLoginScreen.name,
      builder: (context,state) => AppLoginScreen(
        //usersRepository: userRepository,
      ),
    ),

    GoRoute(
      path: '/signUp',
      name:AppSignUpScreen.name,
      builder: (context,state) => AppSignUpScreen(),
    ),

    GoRoute(
      path:'/app_home_screen/:userId',
      name:AppHomeScreen.name,
      builder:(context,state) {
        final userId = state.pathParameters['userId'];
        return AppHomeScreen(
          userId : userId!,
          evsRepository: evsRepository,
        );
      },
    ),

    
    GoRoute(
      path:'/app_home_screen/:userId/:evId',
      name:AppEvScreen.name,
      builder:(context,state) {
        final evId = state.pathParameters['evId'];
        return AppEvScreen(
          //id: int.tryParse(evId ?? '') ?? -1,
          id: evId! ,
        );
      },
    ),

    GoRoute(
      path:'/bluetooth/:userId',
      name:AppBtScreen.name,
      //name:FlutterBlueApp.name,
      builder:(context,state) {
        final userId = state.pathParameters['userId'];
        return AppBtScreen( userId: userId!,
        //return const FlutterBlueApp(
        );
      },
    ),

    GoRoute(
      path:'/app_home_screen/:userId/:evId/inside',
      name:AppInside.name,
      builder:(context,state) {
        return const AppInside(
        );
      },
    ),

    GoRoute(
      path:'/app_home_screen/:userId/:evId/security',
      name:AppSecurity.name,
      builder:(context,state) {
        return const AppSecurity(
        );
      },
    ),

    GoRoute(
      path:'/app_home_screen/:userId/:evId/battery',
      name:AppBattery.name,
      builder:(context,state) {
        return const AppBattery(
        );
      },
    ),
    
  ]
);