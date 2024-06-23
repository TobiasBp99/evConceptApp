import 'package:flutter_ev_concept_app/entities/user.dart';
import 'package:floor/floor.dart';
/*
This component is responsible for managing access to the underlying SQLite database. 
The abstract class contains the method signatures for querying the database.
NotesDao has all the queries which are just abstract methods.The floor will generate its implementation.
*/
@dao
abstract class UserDao{
  @Query('SELECT * FROM User')
  Future<List<User>> findAllUsers();

  @Query('SELECT * FROM User where id =:id')
  Future<User?> findUsersById(int id);

  //@insert
  //Future<void> insertEv(Ev ev);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertUser(User user);
}