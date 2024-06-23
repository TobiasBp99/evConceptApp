import 'package:flutter_riverpod/flutter_riverpod.dart';

class InsideState {
  final double tempSetPoint;
  final double airSpeed;
  final double tempHVAC;

  InsideState({
    required this.tempSetPoint,
    required this.airSpeed,
    required this.tempHVAC,
  });

  InsideState copyWith({
    double? tempSetPoint,
    double? airSpeed,
    double? tempHVAC,
  }) {
    return InsideState(
      tempSetPoint: tempSetPoint  ?? this.tempSetPoint,
      airSpeed    : airSpeed      ?? this.airSpeed,
      tempHVAC    : tempHVAC      ?? this.tempHVAC,
    );
  }
}


var insideStateProvider = StateProvider<InsideState>((ref) {
  
  return InsideState(
    tempSetPoint: 20,
    airSpeed    : 0 ,
    tempHVAC    : 18,
  );
});
