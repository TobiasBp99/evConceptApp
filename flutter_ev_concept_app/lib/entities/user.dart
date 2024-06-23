import 'package:floor/floor.dart';
/*
It will represent a database table 
as well as your business object. 
It is like a table in SQL which few properties.
*/
@entity
class User{
@PrimaryKey(autoGenerate:true)
  final int id;

  final String  username;
  final String  password;
  final bool    login;

  User({
        required this.id, 
        required this.username,
        required this.password,
        required this.login
      });

}

