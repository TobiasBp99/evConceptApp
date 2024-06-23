import 'package:floor/floor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@Entity()
class Ev {

  @PrimaryKey(autoGenerate:true)
  final String?     id;

  //final int?     idUser;
  final String?    uidUser;
  
  final String?  model  ;
  final String?  patent ;
  final String?   image ;

  Ev({
    this.id,
    required this.uidUser ,
    required this.model   ,
    required this.patent  ,
    required this.image   ,
  });

  factory Ev.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Ev(
      //id: data['id'],
      id      : doc.id          ,
      uidUser : data['uidUsers'],
      patent  : data['patent']  ,
      model   : data['model']   ,
      image   : data['image']   ,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uidUsers': uidUser  ,
      'patent': patent    ,
      'model': model      ,
      'image': image      ,
    };
  }

}