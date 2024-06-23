
import 'package:flutter_ev_concept_app/entities/ev.dart';

abstract class EvsRepository{

  Future<List<Ev>> getEvs         ();
  Future<Ev?> getEvById           (String id);

  Future<Ev?> deleteEvById        (String id);

  Future<void> updateEv            (Ev ev  );
  Future<Ev?> updateEvPatentById  (String id, String patent  );
  Future<Ev?> updateEvModelById   (String id, String model   );
  Future<Ev?> updateEvImageById   (String id, String image   );

  Future<List<Ev>> getEvsByUserId (String uid);

  Future<String> insertEv(Ev newEv);

}