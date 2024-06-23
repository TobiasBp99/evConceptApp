// ev_provider.dart

import 'package:flutter_ev_concept_app/core/repositories/evs_repository_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_ev_concept_app/entities/ev.dart';
import 'package:flutter_ev_concept_app/core/repositories/evs_repository.dart';


class EvNotifier extends StateNotifier<List<Ev>> {
  final EvsRepository evsRepository;
  final String uid;

  EvNotifier({required this.evsRepository, required this.uid}) : super([]) {
    _loadEvs();
  }

  Future<void> _loadEvs() async {
    state = await evsRepository.getEvsByUserId(uid);
  }

  Future<void> refreshEvs() async {
    await _loadEvs();
  }

  Future<void> updatePatent(String newPatent) async {
    evsRepository.updateEvPatentById(uid, newPatent);
    await refreshEvs();
  }

}

final evProvider = StateNotifierProvider<EvNotifier, List<Ev>>((ref) {
  return EvNotifier(evsRepository: LocalEvsRepository(), uid: '1'); // Ajusta esto según sea necesario
});


/*
final evNotifierProvider = StateNotifierProvider<EvNotifier, List<Ev>>((ref) {
  return EvNotifier(evsRepository: LocalEvsRepository(), userId: 1); // Ajusta según sea necesario
});

class EvNotifier extends StateNotifier<List<Ev>> {
  final EvsRepository evsRepository;
  final int userId;

  EvNotifier({required this.evsRepository, required this.userId}) : super([]) {
    _loadEvs();
  }

  Future<void> _loadEvs() async {
    state = await evsRepository.getEvsByUserId(userId);
  }

  Future<void> refreshEvs() async {
    await _loadEvs();
  }
}
*/