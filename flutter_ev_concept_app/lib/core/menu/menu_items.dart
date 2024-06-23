import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String link;

  const MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.link,
  });
}

const List<MenuItem> menuItems = [

  MenuItem(
    title: 'Mis Evs',
    subtitle: 'Home',
    icon: Icons.car_rental,
    link: '/app_home_screen/'
  ),
  
  MenuItem(
    title: 'Bluetooth',
    subtitle: 'Conexión Bluetooth',
    icon: Icons.bluetooth,
    link: '/bluetooth/'
  ),
  

  MenuItem(
    title: 'Cerrar sesión',
    subtitle: 'Logout',
    icon: Icons.logout_outlined,
    link: '/'
  ),
  
];