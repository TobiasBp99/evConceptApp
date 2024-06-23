import 'package:flutter_ev_concept_app/core/menu/menu_items.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerHome extends StatefulWidget {
  
  final GlobalKey<ScaffoldState> scafoldKey;
  final idUser;
  const DrawerHome({
      super.key,
      required this.scafoldKey,
      required this.idUser  
    });

  @override
  State<DrawerHome> createState() => _DraweMenuState();
}

class _DraweMenuState extends State<DrawerHome> {
  int selectedScreen = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: selectedScreen,
      onDestinationSelected: (value) async {
        setState(() {
          selectedScreen = value;
        });

        if( value == 0 ){
          context.push( '${menuItems[value].link}${widget.idUser}' );
        }
        else if( value == 1 ){
          context.push( '${menuItems[value].link}${widget.idUser}' );
        }
        else if( value == 2){
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('userId');
          await prefs.remove('isLoggedIn');
          context.push( menuItems[value].link );
        }
        //context.push(menuItems[value].link);
        widget.scafoldKey.currentState?.closeDrawer();
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 10, 28, 5),
          child: Text('Main', style: Theme.of(context).textTheme.titleMedium),
        ),
        ...menuItems.map((item) => NavigationDrawerDestination(
              icon: Icon(item.icon),
              label: Text(item.title),
            )),
      ],
    );
  }
}