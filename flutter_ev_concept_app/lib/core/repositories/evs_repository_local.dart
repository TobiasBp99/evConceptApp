import 'package:flutter_ev_concept_app/core/repositories/evs_repository.dart';
import 'package:flutter_ev_concept_app/data/ev_dao.dart';
import 'package:flutter_ev_concept_app/entities/ev.dart';
import 'package:flutter_ev_concept_app/main.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class LocalEvsRepository implements EvsRepository{
  
  //final CollectionReference evsCollection = FirebaseFirestore.instance.collection('evsCollection');

  final evsCollection = db.collection('evsCollection');

  @override
  Future<List<Ev>> getEvs() async {
    QuerySnapshot querySnapshot = await evsCollection.get();
    return querySnapshot.docs.map((doc) => Ev.fromFirestore(doc)).toList();
  }

  @override
  Future<Ev?> getEvById(String id) async {
    DocumentSnapshot docSnapshot = await evsCollection.doc(id.toString()).get();
    return docSnapshot.exists ? Ev.fromFirestore(docSnapshot) : null;
  }

  @override
  Future<Ev?> deleteEvById(String id) async {
    await evsCollection.doc(id).delete();
  }

  @override
  Future<void> updateEv(Ev ev) async {
    await evsCollection.doc(ev.id.toString()).set(ev.toFirestore());
  }

  @override
  Future<Ev?> updateEvPatentById(String id, String patent) async {
    await evsCollection.doc(id.toString()).update({'patent': patent});
    return getEvById(id);
  }

  @override
  Future<Ev?> updateEvModelById(String id, String model) async {
    await evsCollection.doc(id.toString()).update({'model': model});
    return getEvById(id);
  }

  @override
  Future<Ev?> updateEvImageById(String id, String image) async {
    await evsCollection.doc(id.toString()).update({'image': image});
    return getEvById(id);
  }

  @override
  Future<List<Ev>> getEvsByUserId(String uid) async {
    QuerySnapshot querySnapshot = await evsCollection.where('uidUsers', isEqualTo: uid).get();
    return querySnapshot.docs.map((doc) => Ev.fromFirestore(doc)).toList();
  }

  @override
  Future<String> insertEv(Ev newEv) async {
    try {
      DocumentReference docRef = evsCollection.doc(); // Genera un ID único
      String newEvId = docRef.id;
      await docRef.set(newEv.toFirestore());
      return newEvId;
    } catch (e) {
      print('Error adding new EV: $e');
      return '';
    }
  }



  /*
  final EvDao _evDao = appDB.evDao;

  @override
  Future<List<Ev>> getEvs() {
    return _evDao.findAllEvs();
  }

  @override
  Future <Ev?> getEvById(int id) {
    return _evDao.findEvsById(id);
  }

  @override
  Future <Ev?> deleteEvById(int id) {
    return _evDao.deleteEvById(id);
  }

  @override
  Future<void> updateEv (Ev ev  ){
    return _evDao.updateEv(ev);
  }
  @override
  Future<Ev?> updateEvPatentById (int id, String patent  ){
    return _evDao.updateEvPatentById(id, patent);
  }
  @override
  Future<Ev?> updateEvModelById  (int id, String model   ){
    return _evDao.updateEvModelById(id, model);
  }
  @override
  Future<Ev?> updateEvImageById  (int id, String image  ){
    return _evDao.updateEvImageById(id, image);
  }
  @override
  Future<List<Ev>> getEvsByUserId(int idUser){
    return _evDao.findEvsByUserId(idUser);
  }
  */

}