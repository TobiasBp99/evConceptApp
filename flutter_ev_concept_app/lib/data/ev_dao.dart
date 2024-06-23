import 'package:flutter_ev_concept_app/entities/ev.dart';
import 'package:floor/floor.dart';

@dao
abstract class EvDao{
  @Query('SELECT * FROM Ev')
  Future<List<Ev>> findAllEvs();

  @Query('SELECT * FROM Ev where id =:id')
  Future<Ev?> findEvsById(String id);

  @Query('SELECT * FROM Ev WHERE idUser = :idUser')
  Future<List<Ev>> findEvsByUserId(String idUser);

  @Query('DELETE FROM Ev WHERE id = :id')
  Future<Ev?> deleteEvById(String id);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateEv(Ev ev);
  @Query('UPDATE Ev SET patent = :patent WHERE id = :id')
  Future<Ev?> updateEvPatentById(String id, String patent);
  @Query('UPDATE Ev SET model = :model WHERE id = :id')
  Future<Ev?> updateEvModelById(String id, String model);
  @Query('UPDATE Ev SET image = :image WHERE id = :id')
  Future<Ev?> updateEvImageById(String id, String image);


  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertEv(Ev ev);
}