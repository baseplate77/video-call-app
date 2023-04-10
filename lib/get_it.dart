import 'package:get_it/get_it.dart';
import 'package:video_call_webrtc/service/signaling.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerLazySingleton<Signaling>(() => Signaling());
}
