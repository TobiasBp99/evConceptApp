import 'package:flutter_ev_concept_app/entities/user.dart';

abstract class UsersRepository {
  Future<List<User>> getUsers();
  Future<User?> getUserById(int id);
}