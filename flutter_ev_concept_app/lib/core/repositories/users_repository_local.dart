import 'package:flutter_ev_concept_app/core/repositories/users_repository.dart';
import 'package:flutter_ev_concept_app/data/user_dao.dart';
import 'package:flutter_ev_concept_app/entities/user.dart';
import 'package:flutter_ev_concept_app/main.dart';

class LocalUsersRepository implements UsersRepository{
  //final UserDao _userDao = appDB.userDao;
  late UserDao _userDao ;
  @override
  Future<List<User>> getUsers() {
    return _userDao.findAllUsers();
  }

  @override
  Future <User?> getUserById(int id) {
    return _userDao.findUsersById(id);
  }

}